import WebKit

internal class WKScriptMessageHandlerProxy: NSObject, WKScriptMessageHandler {
    private static let subscriberLock = NSObject()
    
    /**
     * All the subscribers.
     */
    private lazy var subscribers: [IWKWebViewObserver] = []
    
    init(configuration: WKWebViewConfiguration) {
        super.init()
        
        configuration.userContentController.addScriptMessageHandler(self, name: "caravel")
    }
    
    private func lockSubscribers(@noescape action: () -> Void) {
        synchronized(WKScriptMessageHandlerProxy.subscriberLock, action: action)
    }
    
    private func iterateOverDelegates(callback: (IWKWebViewObserver) -> Void) {
        self.lockSubscribers {
            for e in self.subscribers {
                callback(e)
            }
        }
    }
    
    func subscribe(subscriber: IWKWebViewObserver) {
        lockSubscribers {
            for s in self.subscribers {
                if s.hash == subscriber.hash {
                    return
                }
            }
            
            self.subscribers.append(subscriber)
        }
    }
    
    func unsubscribe(subscriber: IWKWebViewObserver) {
        lockSubscribers {
            var i = 0
            for e in self.subscribers {
                if e.hash == subscriber.hash {
                    self.subscribers.removeAtIndex(i)
                    return
                }
                i++
            }
        }
    }
    
    func hasSubscribers() -> Bool {
        return self.subscribers.count > 0
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let body = message.body as! Dictionary<String, AnyObject>
        let busName = body["busName"] as! String
        let eventName = body["eventName"] as! String
        let eventData = body["eventData"]
        
        iterateOverDelegates {e in
            background {e.onMessage(busName, eventName: eventName, eventData: eventData)}
        }
    }
}