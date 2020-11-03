//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinderTests
//  @esesmuedgars
//

@testable import FriendFinder
import Network

final class TCPConnectionServiceTestDelegate: TCPConnectionServiceDelegate {
    var receivedUserMessage: ((UserMessage) -> Void)?
    func connection(
        _ connection: NWConnection,
        receivedUserMessage userMessage: UserMessage
    ) {
        receivedUserMessage?(userMessage)
    }

    var receivedUpdateMessage: ((UpdateMessage) -> Void)?
    func connection(
        _ connection: NWConnection,
        receivedUpdateMessage updateMessage: UpdateMessage
    ) {
        receivedUpdateMessage?(updateMessage)
    }

    var failedWithError: ((NWError) -> Void)?
    func connection(
        _ connection: NWConnection,
        failedWithError error: NWError
    ) {
        failedWithError?(error)
    }
}
