![Caravel Logo](https://raw.githubusercontent.com/coshx/caravel/master/logo.png)

[![CocoaPods](https://img.shields.io/cocoapods/v/Caravel.svg?style=flat-square)](https://cocoapods.org/pods/Caravel)

[![Join the chat at https://gitter.im/coshx/caravel](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/coshx/caravel?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**An event bus for sending messages between UIWebView/WKWebView and embedded JS. Made with pure Swift.**

## Features

* Easy, fast and reliable event bus system
* Multiple bus support
* Multithreading support
* `WKWebView` support
* iOS ~> JavaScript supported types:
  - `Bool`
  - `Int`
  - `Float`
  - `Double`
  - `String`
  - Any array (using types in this list, including dictionaries)
  - Any dictionary (using types in this list, including arrays)
* JavaScript ~> iOS supported types:
  - `Boolean`
  - `Int`
  - `Float` (available as a `Double`)
  - `String`
  - `Array` (available as a `NSArray`)
  - `Object` (available as a `NSDictionary`)

## Installation

### Using CocoaPods

Add this line to your Podfile:

```ruby
pod 'Caravel'
```

And run `pod install`. Once installed, open the `Pods` folder. Navigate to `caravel/caravel/js`. In this folder, drag and drop `caravel.min.js` into your Xcode project. You should load this JS script in any webpage you use Caravel.

### Using Carthage

Add this line to your Cartfile:

```
github "coshx/caravel"
```

And run `carthage update`. Once installed, open the `Carthage/Checkouts` folder. Navigate to `caravel/caravel/js`. In this folder, drag and drop `caravel.min.js` into your Xcode project. You should load this JS script in any webpage you use Caravel.

### Using as a submodule

Clone this repo and add `Caravel.xcodeproj` into your workspace. 

## Might be useful 

* [Engineer a TODO list using Caravel and Framework7](http://www.coshx.com/blog/2015/12/04/engineer-a-todo-list-using-caravel-and-framework7/)
* [Migrate from 0.* to 1.*](http://www.coshx.com/blog/2015/11/19/releasing-caravel-1-0-0/)

## Get started

Caravel allows developers to communicate between their `UIWebView` and the embedded JS. You can send any kind of message between those two folks.

Have a glance at this super simple sample. Let's start with the iOS part:

```swift
class MyController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare your bus before loading your web view's content
        Caravel.getDefault(self, webView: webView, whenReady: { bus in
            // In this scope, the JS endpoint is ready to handle any event.
            // Register and post your events here
            bus.post("MyEvent", data: [1, 2, 3])
            
            self.bus = bus // You can save your bus for firing events later
        })
        
        // ... Load web view's content there
    }
}
```

And now, in your JS:

```javascript
Caravel.getDefault().register("AnEventWithAString", function(name, data) {
    alert('I received this string: ' + data);
});
```

And voilà!

## WKWebView

Caravel 1.1.0 supports `WKWebView`. Keep in mind this class is still in beta and might not work as expected. We won't ship you a 🍕 if your app does not work. 

Anyway. If you're this kind of guy involved in some risky business, here how to use Caravel with this object. Be careful, it is a two-step process.

```swift
class MyController: UIViewController {
    private var wkWebView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        // First generate a draft using your custom configuration
        let draft = Caravel.getDraft(config)

        // Build your WKWebView as usual then
        self.wkWebView = WKWebView(frame: self.view.bounds, configuration: config)

        // Then initiate Caravel
        Caravel.getDefault(self, wkWebView: self.wkWebView!, draft: draft, whenReady: {
            // Do whatever you've got to do here
        })

        // ... Load content into your WKWebView there
    }
}
```

## Troubleshooting

### I want to use my custom UIWebViewDelegate. What should I do?

To raise iOS events, Caravel must be the delegate of the provided `UIWebView`. However, if there is any existing delegate, Caravel saves it before setting its own. So, if you would like to use your custom one, simply set it **before** any call to Caravel.

### I want to use my custom WKUserContentController. What should I do?

To raise iOS events, Caravel adds a custom `WKScriptMessageHandler` to the current content controller. If you would like to use your custom one, simply set it **before** any call to Caravel.

### What object should I use as a subscriber?

A subscriber could be any object **except the watched target** (either the `UIWebView` or the `WKWebView`). We recommend to use the controller as a subscriber (it is a common pattern).

### Reserved names

`CaravelInit` is an internal event, sent by the JS part for triggering the `whenReady` method.

Also, the default bus is named `default`. If you use that name for a custom bus, Caravel will automatically switch to the default one.

### Keep in mind event and bus names are case-sensitive.

