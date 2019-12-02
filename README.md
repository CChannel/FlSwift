# Swifty_Flux
- [Flux](https://facebook.github.io/flux/) is the application architecture that Facebook uses for building client-side web applications.
- Swifty_Flux is Flux like architecture library written in Swift.
- Using one-way data flow makes it easier to understand state management.

<img src="https://github.com/CChannel/Swifty_Flux/blob/master/assets/Flux_%20Figure.png" width = "360" title="Flux_%20Figure">

## Usage

### Action
- Action to handle value increase / decrease
```swift
enum NumberAction: Action {
    case increase(Int)
    case decrease(Int)
}

```
### Dispatcher
- Dipatcher to handle actions.
- This sample defines dispatcher as ActionCreator
```swift
class NumberActionCreator {
    static let shared = NumberActionCreator()
    private init() {}
    let dispatcher = Swifty_Flux.Dispatcher<NumberAction>.shared
}
```

### State
- You can define the state of the app that handles increasing and decreasing values as follows.
```swift
class NumberState: State {
    typealias ActionType = NumberAction
    
    func reduce(action: NumberAction) {
        switch action {
        case .increase(let value):
            number.accept(number.value + value)
        case .decrease(let value):
            number.accept(number.value - value)
        }
    }
    
    var number = BehaviorRelay<Int>(value: 0)
}
```

### Store
- Reflect the change in the value in the view.
- This sample uses Rxswift to bind to the view
```swift
final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.state.number
            .asObservable()
            .map({ String($0) })
            .bind(to: numberLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    @IBAction private func plusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.increase(1))
    }
    
    @IBAction private func  minusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.decrease(1))
    }
    
    private let disposeBag = DisposeBag()
    @IBOutlet private weak var numberLabel: UILabel!
    private lazy var store: Store<NumberState> = {
        let state = NumberState()
        let store = Store(state: state)
        store.subscribe()
        return store
    }()
}
```

## Requirements
- Xcode 10.3
- Swift 5.0

## Installation
### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add the pod Swifty_Flux
```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'Swifty_Flux'
end
```
```sh
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

Add this to Cartfile
```
git "git@github.com:CChannel/Swifty_Flux.git"
```
```sh
$ carthage update
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)
Add this to Package.swift
```
dependencies: [
    .package(url: "https://github.com/CChannel/Swifty_Flux.git", from: "0.0.1")
]
```
```sh
$ swift build
```

## CONTRIBUTING
There's still a lot of work to do here.
We would love to see you involved.
You can find all the details on how to get started in the [Contributing Guide.](https://github.com/CChannel/Swifty_Flux/blob/master/CONTRIBUTING.md)

## License
Swifty_Flux is released under the MIT license. See LICENSE for details.
