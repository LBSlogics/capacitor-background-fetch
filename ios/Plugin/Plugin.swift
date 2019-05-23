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
  
  @objc func fetch(_ call: CAPPluginCall) {
    print("CAPPluginCall")
    print(call.options)
    guard let address = call.getString("address") else {
      print("BackgroundFetch: URL is needed to fetch")
      call.error("BackgroundFetch: URL is needed to fetch")
      return
    }
    guard let url = URL(string: address) else {
      print("BackgroundFetch: " + address + " is not a valid url")
      call.error(address + " is not a valid url")
      return
    }
    var urlRequest = URLRequest(url: url)
    
    let headers = call.getObject("headers")
    if let headers = headers {
      for (key, value) in headers {
        if let value = value as? String {
          print("BackgroundFetch: Founder Header " + key + ": " +  value)
          urlRequest.addValue(key, forHTTPHeaderField: value)
        }
      }
      
    } else {
      print("BackgroundFetch: Fetch from " + address + " without headers")
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    var result: String = ""
    var responseCode: Int = -1
    var error: Error? = nil
    var task: URLSessionTask
    let httpMethod = call.getString("httpMethod") ?? "GET"
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 10.0
    sessionConfig.timeoutIntervalForResource = 20.0
    let session = URLSession(configuration: sessionConfig)
    
    if httpMethod == "POST" {
      var jsonData: Data? = nil
      
      if let json = call.getObject("body") {
        jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
      }
      
      task = session.uploadTask(with: urlRequest, from: jsonData) { (data, response, httpError) in
        if let err = httpError {
          error = err
          semaphore.signal()
          return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
          responseCode = httpResponse.statusCode
        }
        result = String(data: data!, encoding: String.Encoding.utf8)!
        semaphore.signal()
      }
    } else {
      task = session.dataTask(with: urlRequest) {(data, response, httpError) in
        if let err = httpError {
          error = err
          semaphore.signal()
          return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
          responseCode = httpResponse.statusCode
        }
        result = String(data: data!, encoding: String.Encoding.utf8)!
        semaphore.signal()
      }
    }
    
    task.resume()
    semaphore.wait()
    
    if let err = error {
      print("BackgroundFetch: Error while executing http request: " + error.debugDescription)
      call.reject("HTTP Error", err, [:])
    } else {
      print("BackgroundFetch: Successful http request:  \(responseCode)")
      print("BackgroundFetch: Response: " + result)
      call.success(["response": result, "code": responseCode])
    }
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
