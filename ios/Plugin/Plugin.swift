import Foundation
import Capacitor

/**
 * Notificaton types for NSNotificationCenter
 */
@objc public enum BackgroundNotifications: Int {
  case FetchReceived
  
  public func name() -> String {
    switch self {
    case .FetchReceived: return "CAPBackgroundFetchReceived"
    }
  }
}
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(BackgroundFetch)
public class BackgroundFetch: CAPPlugin {
  private var completionHandler: ((UIBackgroundFetchResult) -> Void)?
  private let eventName = "BACKGROUNDFETCHRECEIVED"
  
  public override init!(bridge: CAPBridge!, pluginId: String!, pluginName: String!) {
    super.init(bridge: bridge, pluginId: pluginId, pluginName: pluginName)
    print("BackgroundFetch initialized")
    NotificationCenter.default.addObserver(self, selector: #selector(self.performFetchWithcompletionHandler(notification:)), name: NSNotification.Name(BackgroundNotifications.FetchReceived.name()), object: nil)
  }
  
  @objc func performFetchWithcompletionHandler(notification: Notification) {
    print("BackgroundFetch: Notification Received");
    guard let completionHandler = notification.object as? (UIBackgroundFetchResult) -> Void else {
      print("BackgroundFetch: Error getting completion handler")
      return
    }
    self.completionHandler = completionHandler
    notifyListeners(eventName, data: [:])
  }
  
  @objc func setMinimumBackgroundFetchInterval(_ call: CAPPluginCall) {
    let value = call.getString("interval")
    
    var timeInterval: TimeInterval
    switch value {
    case "minimum":
      timeInterval = UIApplication.backgroundFetchIntervalMinimum
    case "never":
      timeInterval = UIApplication.backgroundFetchIntervalNever
    default:
      timeInterval = call.getDouble("seconds") ?? UIApplication.backgroundFetchIntervalMinimum
    }
    
    DispatchQueue.main.async {
      UIApplication.shared.setMinimumBackgroundFetchInterval(timeInterval)
    }
    
    print("BackgroundFetch: SetMinimumInterval")
    call.success([:])
  }
  
  @objc func disableBackgroundFetch(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
    }
    
    call.success([:])
  }
  
  @objc func fetchCompleted(_ call: CAPPluginCall) {
    guard let completionHandler = self.completionHandler else {
      let message = "BackgroundFetch: No fetch command received from iOS"
      print(message)
      call.error(message)
      return
    }
    
    let result = call.getString("result")
    var fetchResult: UIBackgroundFetchResult
    switch result {
    case "newData":
      fetchResult = UIBackgroundFetchResult.newData
    case "failed":
      fetchResult = UIBackgroundFetchResult.failed
    default:
      fetchResult = UIBackgroundFetchResult.noData
    }
    
    completionHandler(fetchResult)
    print("BackgroundFetch: Called completion handler");
    self.completionHandler = nil
    call.success([:])
  }
}
