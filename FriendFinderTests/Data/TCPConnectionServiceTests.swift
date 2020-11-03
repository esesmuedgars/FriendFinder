//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinderTests
//  @esesmuedgars
//

import XCTest
@testable import FriendFinder

final class TCPConnectionServiceTests: XCTestCase {

    private var tcpConnectionService: TCPConnectionService?
    private var delegate: TCPConnectionServiceTestDelegate?

    override func setUp() {
        super.setUp()

        let delegate = TCPConnectionServiceTestDelegate()
        let tcpConnectionService = TCPConnectionServiceImpl(
            credentials: Credentials(email: "email"),
            host: "host",
            port: 0
        )
        tcpConnectionService.delegate = delegate

        self.tcpConnectionService = tcpConnectionService
        self.delegate = delegate
    }

    override func tearDown() {
        super.tearDown()

        tcpConnectionService = nil
        delegate = nil
    }

    func testParseUserMessage() {
        let expectation = self.expectation(
            description: "Parsed `UserMessage` did not match expected `String`."
        )
        let testString = "USERLIST 1,Edgars Vanags,https://avatars3.githubusercontent.com/u/25123761?s=460&u=41217500c76c9f9ea4a4e8963f1c2bafe3b3d735&v=4,56.9496,24.1052;\n"
        let testUserMessage = UserMessage(
            id: 1,
            fullName: "Edgars Vanags",
            imageURL: URL(string: "https://avatars3.githubusercontent.com/u/25123761?s=460&u=41217500c76c9f9ea4a4e8963f1c2bafe3b3d735&v=4")!,
            latitude: 56.9496,
            longitude: 24.1052
        )

        delegate?.receivedUserMessage = { userMessage in
            XCTAssertEqual(
                userMessage,
                testUserMessage
            )
            expectation.fulfill()
        }

        let data = testString.data(using: .utf8)!
        tcpConnectionService?.parse(data)

        wait(for: [expectation], timeout: 1)
    }

    func testParseUpdateMessage() {
        let expectation = self.expectation(
            description: "Parsed `UpdateMessage` did not match expected `String`."
        )
        let testString = "UPDATE 1,56.9496,24.1052\n"
        let testUpdateMessage = UpdateMessage(
            id: 1,
            latitude: 56.9496,
            longitude: 24.1052
        )

        delegate?.receivedUpdateMessage = { updateMessage in
            XCTAssertEqual(
                updateMessage,
                testUpdateMessage
            )
            expectation.fulfill()
        }

        let data = testString.data(using: .utf8)!
        tcpConnectionService?.parse(data)

        wait(for: [expectation], timeout: 1)
    }

    func testParseBadMessageThrowsError() {
        let expectation = self.expectation(
            description: "Didn't throw expected POSIX `EBADMSG` error code."
        )

        delegate?.failedWithError = { error in
            guard case .posix(.EBADMSG) = error else {
                return
            }

            expectation.fulfill()
        }

        tcpConnectionService?.parse(Data())

        wait(for: [expectation], timeout: 1)
    }

    func testParseUnauthorizedThrowsError() {
        let expectation = self.expectation(
            description: "Didn't throw expected POSIX `EAUTH` error code."
        )

        delegate?.failedWithError = { error in
            guard case .posix(.EAUTH) = error else {
                return
            }

            expectation.fulfill()
        }

        let data = "UNAUTHORIZED\n".data(using: .utf8)!
        tcpConnectionService?.parse(data)

        wait(for: [expectation], timeout: 1)
    }
}
