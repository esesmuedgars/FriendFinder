//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import Network

// MARK: TCPConnectionServiceDelegate

protocol TCPConnectionServiceDelegate: AnyObject {
    func connection(
        _ connection: NWConnection,
        receivedUserMessage userMessage: UserMessage
    )
    func connection(
        _ connection: NWConnection,
        receivedUpdateMessage updateMessage: UpdateMessage
    )
    func connection(
        _ connection: NWConnection,
        didUpdateState state: NWConnection.State
    )
    func connection(
        _ connection: NWConnection,
        failedWithError error: NWError
    )
}

extension TCPConnectionServiceDelegate {
    func connection(
        _ connection: NWConnection,
        didUpdateState state: NWConnection.State
    ) { /* Optional */ }
}

// MARK: TCPConnectionService

protocol TCPConnectionService: AnyObject {
    var delegate: TCPConnectionServiceDelegate? { get set }

    func connect()

    // Exposed for unit testing of parsing logic
    func parse(_ data: Data)
}

// MARK: TCPConnectionServiceImpl

final class TCPConnectionServiceImpl: TCPConnectionService {

    weak var delegate: TCPConnectionServiceDelegate?

    private lazy var tcpConnectionServiceQueue = DispatchQueue(
        label: "TCPConnectionServiceQueue",
        qos: .utility,
        attributes: .concurrent,
        autoreleaseFrequency: .workItem
    )

    private let credentials: Credentials
    private let connection: NWConnection

    init(credentials: Credentials, host: String, port: UInt16) {
        self.credentials = credentials

        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 2

        connection = NWConnection(
            to: .hostPort(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(integerLiteral: port)
            ),
            using: NWParameters(tls: nil, tcp: tcpOptions)
        )
    }

    func connect() {
        defer {
            receiveBytes()
        }

        connection.stateUpdateHandler = stateUpdateHandler
        connection.start(queue: tcpConnectionServiceQueue)
    }

    private func stateUpdateHandler(_ state: NWConnection.State) {
        delegate?.connection(connection, didUpdateState: state)

        switch state {
        case .ready:
            authorize()

        case .failed(let error),
             .waiting(let error):
            delegate?.connection(connection, failedWithError: error)

        default:
            break
        }
    }

    private func receiveBytes() {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [unowned self] data, _, isComplete, error in
            guard let data = data else {
                self.delegate?.connection(
                    self.connection,
                    failedWithError: .posix(.ENODATA)
                )

                return
            }

            self.parse(data)

            if isComplete {
                self.connection.stateUpdateHandler = nil
                self.connection.cancel()
            } else if let error = error {
                self.delegate?.connection(self.connection, failedWithError: error)
            } else {
                self.receiveBytes()
            }
        }
    }

    func parse(_ data: Data) {
        do {
            guard let string = String(data: data, encoding: .utf8) else {
                throw NWError.posix(.ENOMSG)
            }

            let trimmedString = string
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)

            switch trimmedString {
            case let string where string.contains("USERLIST"):
                parseUserList(from: string) { [delegate, connection] userMessage in
                    delegate?.connection(
                        connection,
                        receivedUserMessage: userMessage
                    )
                }

            case let string where string.contains("UPDATE"):
                parseUpdate(from: string) { [delegate, connection] updateMessage in
                    delegate?.connection(
                        connection,
                        receivedUpdateMessage: updateMessage
                    )
                }

            case _ where string.contains("UNAUTHORIZED"):
                throw NWError.posix(.EAUTH)

            default:
                throw NWError.posix(.EBADMSG)
            }
        } catch {
            delegate?.connection(
                connection,
                failedWithError: error as! NWError
            )
        }
    }

    private func parseUserList(
        from string: String,
        completionHandler: (UserMessage) -> Void
    ) {
        string.replacingOccurrences(of: "USERLIST ", with: "")
            .split(separator: .semicolon)
            .splitMap(separator: .comma)
            .filterContainsIndex(4)
            .forEach { message in
                guard let id = Int(message[0]),
                      let imageURL = URL(string: String(message[2])),
                      let latitude = Double(message[3]),
                      let longitude = Double(message[4]) else {
                    return
                }

                let fullName = String(message[1])
                let userMessage = UserMessage(
                    id: id,
                    fullName: fullName,
                    imageURL: imageURL,
                    latitude: latitude,
                    longitude: longitude
                )

                completionHandler(userMessage)
            }
    }

    private func parseUpdate(
        from string: String,
        completionHandler: (UpdateMessage) -> Void
    ) {
        string.replacingOccurrences(of: "UPDATE ", with: "")
            .split(separator: .newline)
            .splitMap(separator: .comma)
            .filterContainsIndex(2)
            .forEach { message in
                guard let id = Int(message[0]),
                      let latitude = Double(message[1]),
                      let longitude = Double(message[2]) else {
                    return
                }

                let updateMessage = UpdateMessage(
                    id: id,
                    latitude: latitude,
                    longitude: longitude
                )

                completionHandler(updateMessage)
            }
    }

    func authorize() {
        send(String(format: "AUTHORIZE %@\n", credentials.email))
    }

    private func send(_ message: String) {
        connection.send(
            content: message.data(using: .utf8)!,
            completion: .contentProcessed { [unowned self] error in
                guard let error = error else {
                    return
                }

                self.delegate?.connection(connection, failedWithError: error)
            }
        )
    }
}

// MARK: Character

fileprivate extension Character {
    static var newline: Character {
        "\n"
    }

    static var comma: Character {
        ","
    }

    static var semicolon: Character {
        ";"
    }
}

// MARK: Sequence

fileprivate extension Sequence where Element: StringProtocol {
    func splitMap(separator: Character) -> [[Element.SubSequence]] {
        map { $0.split(separator: separator) }
    }
}

fileprivate extension Sequence where Element: Collection {
    func filterContainsIndex(_ index: Element.Index) -> [Element] {
        filter { $0.indices.contains(index) }
    }
}
