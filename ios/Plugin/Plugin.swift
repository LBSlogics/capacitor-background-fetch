import Foundation
import Capacitor

/**
 * Notificaton types for NSNotificationCenter
 */
public enum BackgroundNotifications: String {
  case FetchReceived = "CAPBackgroundFetchReceived"
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.performFetchWithcompletionHandler(notification:)), name: NSNotification.Name(BackgroundNotifications.FetchReceived.rawValue), object: nil)
  }
  
  @objc func setMinimumBackgroundFetchInterval(_ call: CAPPluginCall) {
    let value = call.getString("interval")
  
    var timeInterval: TimeInterval
    switch value {
    case "minimum":
      timeInterval = UIApplicationBackgroundFetchIntervalMinimum
    case "never":
      timeInterval = UIApplicationBackgroundFetchIntervalNever
    default:
      timeInterval = call.getDouble("seconds") ?? UIApplicationBackgroundFetchIntervalMinimum
    }
    
    UIApplication.shared.setMinimumBackgroundFetchInterval(timeInterval)
    
    call.success([:])
  }
  
  @objc func disableBackgroundFetch(_ call: CAPPluginCall) {
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
    
    call.success([:])
  }
  
  @objc func fetchCompleted(_ call: CAPPluginCall) {
    guard let completionHandler = self.completionHandler else {
      let message = "Background Fetch: No completion handler stored"
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
    call.success([:])
  }
  
  @objc private func performFetchWithcompletionHandler(notification: Notification) {
    guard let completionHandler = notification.object as? (UIBackgroundFetchResult) -> Void else {
      print("Background Fetch: Error getting completion handler")
      return
    }
    self.completionHandler = completionHandler
    notifyListeners(eventName, data: [:])
  }
}
