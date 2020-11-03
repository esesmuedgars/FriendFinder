//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import Foundation
import Network

// MARK: DataTransferError

enum DataTransferError: Error {
    case dns(DNSServiceErrorType)
    case tls(OSStatus)
    case posix(POSIXErrorCode)
}

// MARK: DataTransferService

protocol DataTransferService: AnyObject {
    func connect(
        receivedUserMessage: ((UserMessage) -> Void)?,
        receivedUpdateMessage: ((UpdateMessage) -> Void)?,
        failedWithError: ((DataTransferError) -> Void)?
    )
}

// MARK: DataTransferServiceImpl

final class DataTransferServiceImpl: DataTransferService {

    private var receivedUserMessage: ((UserMessage) -> Void)?
    private var receivedUpdateMessage: ((UpdateMessage) -> Void)?
    private var failedWithError: ((DataTransferError) -> Void)?

    private let tcpConnectionService: TCPConnectionService

    init(tcpConnectionService: TCPConnectionService) {
        self.tcpConnectionService = tcpConnectionService
    }

    func connect(
        receivedUserMessage: ((UserMessage) -> Void)?,
        receivedUpdateMessage: ((UpdateMessage) -> Void)?,
        failedWithError: ((DataTransferError) -> Void)?
    ) {
        self.receivedUserMessage = receivedUserMessage
        self.receivedUpdateMessage = receivedUpdateMessage
        self.failedWithError = failedWithError

        tcpConnectionService.delegate = self
        tcpConnectionService.connect()
    }

    private func resolveDomainError(errorType: DNSServiceErrorType) {
        failedWithError?(.dns(errorType))
    }

    private func resolveTransportSecurity(errorCode status: OSStatus) {
        #if DEBUG
        if let error = SecCopyErrorMessageString(status, nil) {
            print(error)
        }
        #endif

        failedWithError?(.tls(status))
    }

    private func resolvePOSIX(errorCode: POSIXErrorCode) {
        failedWithError?(.posix(errorCode))
    }
}

// MARK: TCPConnectionServiceDelegate

extension DataTransferServiceImpl: TCPConnectionServiceDelegate {
    func connection(
        _ connection: NWConnection,
        receivedUserMessage userMessage: UserMessage
    ) {
        receivedUserMessage?(userMessage)
    }

    func connection(
        _ connection: NWConnection,
        receivedUpdateMessage updateMessage: UpdateMessage
    ) {
        receivedUpdateMessage?(updateMessage)
    }

    func connection(
        _ connection: NWConnection,
        failedWithError error: NWError
    ) {
        switch error {
        case .dns(let errorType):
            resolveDomainError(errorType: errorType)

        case .tls(let status):
            resolveTransportSecurity(errorCode: status)

        case .posix(let errorCode):
            resolvePOSIX(errorCode: errorCode)

        @unknown default:
            #if DEBUG
            fatalError(
                "`TCPConnectionServiceDelegate.connection(:failedWithError)` returned unhandled error."
            )
            #endif
        }
    }
}
