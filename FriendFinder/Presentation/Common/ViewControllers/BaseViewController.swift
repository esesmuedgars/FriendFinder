//
//  MacOS 10.15
//  Swift 5.0
//  FriendFinder
//  @esesmuedgars
//

import UIKit

// MARK: ViewController

public protocol ViewController: NSObjectProtocol {
    associatedtype ViewModel

    var viewModel: ViewModel! { get set }

    func setup()
    func bind(to viewModel: ViewModel)
}

// MARK: BaseViewController

open class BaseViewController<ViewModel>: UIViewController, ViewController {

    public var viewModel: ViewModel!

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
    public override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        bind(to: viewModel)
    }

    /// Method for `ViewController` subclass setup.
    /// Called by `init(viewModel:)`.
    open func setup() { }

    /// Method to bind `ViewController` properties with `ViewModel` datasource.
    /// Called by `viewDidLoad()`.
    /// - Parameter viewModel: datasource of `ViewController` properties.
    open func bind(to viewModel: ViewModel) { }
}

