//
//  NethApiCalls.swift
//  linphone
//  Evaluate to move the error handling inside the base call.
//
//  Created by Administrator on 07/11/2019.
//

import Foundation

@objc class NethCTIAPI : NSObject {
    private override init(){}
    private static let _singletonInstance = NethCTIAPI()
    @objc public class func sharedInstance() -> NethCTIAPI {
        return NethCTIAPI._singletonInstance;
    }
    
    private func getDefaultHeaders() -> [String: String] {
        return ["Content-type": "application/json"];
    }
    
    private func checkCredentials() -> Bool {
        let credentials = ApiCredentials.sharedInstance()
        return credentials.Username != "No username." && credentials.Domain != "No domain."
    }
    
    private func transformDomain(_ domain:String) -> String {
        return "https://\(domain)/webrest"
    }
    
    private var authKeyForNotificatore : String {
        return getStringFromInfo(keyString: "AppApnsAuthKey")
    }
    
    private var baseUrlForNotificatore : String {
        return getStringFromInfo(keyString: "AppApnsBaseUrl")
    }
    
    private func getStringFromInfo(keyString:String) -> String {
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        let keyValue: AnyObject? = dict?.value(forKey: keyString) as AnyObject?
        var stringNative :String = String()
        if let nsString:NSString = keyValue as? NSString {
            stringNative = nsString as String
        }
        return stringNative;
    }
    
    /**
     This is a basic call that have to be configured.
     */
    private func baseCall(url: URL, method: String, headers: [String: String]?, body: [String: String]?, successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        // Headers handling.
        if let h = headers {
            urlRequest.allHTTPHeaderFields = h
        } else {
            urlRequest.allHTTPHeaderFields = getDefaultHeaders()
        }
        
        // Body handling.
        if let b = body {
            do { // I try to use data.
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: b, options: [JSONSerialization.WritingOptions.prettyPrinted])
            } catch {
                return
            }
        } else {
            urlRequest.httpBody = nil // I don't need data.
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: urlRequest, completionHandler: successHandler)
        task.resume()
    }
    
    /**
     Make a request with the new request handler above this function.
     This may be the only call that don't need authentication.
     */
    @objc public func postLogin(username:String, password:String, domain:String, successHandler: @escaping (String?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        ApiCredentials.sharedInstance().Username = username
        ApiCredentials.sharedInstance().Domain = domain
        let loginEndpoint = "\(self.transformDomain(domain))/authentication/login"
        guard let url = URL(string: loginEndpoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postStr = ApiCredentials.sharedInstance().getAuthenticationCredentials(password: password)
        self.baseCall(url: url, method: "POST", headers: nil, body: postStr) {
            data, response, error in
            // Error handling.
            guard error == nil else {
                errorHandler("Error calling POST on /authentication/login.")
                print(error!)
                return
            }
            
            // Responde handling.
            guard let httpResponse = response as? HTTPURLResponse else {
                errorHandler("Did not receive response.")
                return
            }
            
            // Digest handling.
            guard let digest = httpResponse.allHeaderFields[AnyHashable("Www-Authenticate")] as? String else {
                errorHandler("AUTHENTICATE-HEADER-MISSING.")
                return
            }
            // I return to caller method.
            successHandler(ApiCredentials.sharedInstance().setToken(password: password, digest: digest))
        }
    }
    
    /**
     Make a POST logout request to NethCTI server.
     */
    @objc public func postLogout(successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        let b = self.checkCredentials() as Bool?
        if b != nil && b! {
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        // Set the url.
        let endPoint = "\(self.transformDomain(ApiCredentials.sharedInstance().Domain))/authentication/logout"
        guard let url = URL(string: endPoint) else {
            print(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postArgs = ApiCredentials.sharedInstance().getAuthenticatedCredentials()
        self.baseCall(url: url, method: "POST", headers: postArgs, body: nil, successHandler: successHandler)
    }
    
    @objc public func setAuthToken(username:String, token: String, domain: String) -> Void {
        guard let u = username as String? else {
            print("API_ERROR: No username provided.")
            return
        }
        guard let t = token as String? else {
            print("API_ERROR: No token provided.")
            return
        }
        guard let d = domain as String? else {
            print("API_ERROR: No domain provided.")
            return
        }
        
        ApiCredentials.sharedInstance().Username = u
        ApiCredentials.sharedInstance().NethApiToken = t
        ApiCredentials.sharedInstance().Domain = d
    }
    
    /**
     Make a GET me request to NethCTI server.
     */
    @objc public func getMe(successHandler: @escaping (PortableNethUser?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        if !self.checkCredentials() {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.sharedInstance().Domain))/user/me" // Set the endpoint URL.
        guard let url = URL(string: endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let getHeaders = ApiCredentials.sharedInstance().getAuthenticatedCredentials()
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil) {
            data, response, error in
            guard error == nil else { // Error handling.
                errorHandler("Error calling GET on /user/me")
                print(error!)
                return
            }
            
            guard let responseData = data else { // Responde handling.
                errorHandler("No data provided.")
                return
            }
            
            do{
                let userDict = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                let nethUser = try NethUser(from: userDict)
                successHandler(PortableNethUser(from: nethUser!))
            } catch (let errorThrown) {
                errorHandler("json error: \(errorThrown.localizedDescription)")
                return
            }
        }
    }
    
    /**
     Use this function to register at any time the device token to Notificatore.
     */
    @objc public func registerDeviceId(_ deviceId: String, successHandler: @escaping (String?) -> Void) -> Void {
        guard let d = deviceId as String? else {
            return
        }
        guard let user = ApiCredentials.sharedInstance().Username as String? else {
            return
        }
        guard let domain = ApiCredentials.sharedInstance().Domain as String? else {
            return
        }
        
        let plistEndpoint = self.baseUrlForNotificatore
        let plistAppKey = self.authKeyForNotificatore
        var endpointUrl = "\(plistEndpoint)?CMD=initapp&os=1&appkey=\(plistAppKey)&devtoken=\(d)"
        if(user != "" && domain != "") {
            endpointUrl += "&user=\(user)@\(domain)";
        }
        
        print("APNS SERVER: Notification endpoint url: \(endpointUrl)")
        let url = URL(string: endpointUrl)
        self.baseCall(url: url!, method: "GET", headers: nil, body: nil) {
            data, response, error in
            guard error == nil else {
                print("APNS SERVER: %s", error!)
                return
            }
            guard let responseData = data as Data? else {
                print("APNS SERVER: No data provided.")
                return
            }
            
            let dataString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
            let logString = "APNS SERVER response: \(String(describing: dataString))"
            successHandler(logString)
        }
    }
    
    @objc public func getPresence(successHandler: @escaping() -> Void, errorHandler: @escaping(String?) -> Void) -> Void { // Ready for the second release.
        let b = self.checkCredentials() as Bool?
        if b != nil && !b! {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue);
            return
        }
        
        let endPoint = "\(ApiCredentials.sharedInstance().Domain)/user/me" // Set the endpoint URL.
        guard let url = URL(string:endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = ApiCredentials.sharedInstance().getAuthenticatedCredentials()
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil) {
            data, response, error in
            guard error == nil else {
                errorHandler("Error calling GET on /user/presence")
                print(error!)
                return
            }
            
            guard let responseData = data else { // Response handling.
                errorHandler("No data provided.")
                return
            }
            
            do{
                _ = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                successHandler()
            } catch {
                errorHandler("json error: \(error.localizedDescription)")
                return
            }
        }
    }
}
