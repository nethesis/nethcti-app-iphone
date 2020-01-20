//
//  NethApiCalls.swift
//  linphone
//  Evaluate to move the error handling inside the base call.
//
//  Created by Administrator on 07/11/2019.
//

import Foundation

@objc class NethCTIAPI : NSObject{
    fileprivate var credentials: ApiCredentials?
    fileprivate var server: String?
    
    @objc init(user:String?, pass:String?, url:String){
        // Here I check if user have some credentials.
        guard let c = ApiCredentials.init(username: user, password: pass) as ApiCredentials? else {
            print("API_ERROR: No credentials provided.");
            self.credentials = nil
        }
        self.credentials = c
        
        // I ensure that baseurl have a value.
        guard let u = url as String? else {
            print("API_ERROR: No server provided.")
            return;
        }
        self.server = "https://\(u)/webrest"
    }
    
    private func getDefaultHeaders() -> [String: String] {
        return ["Content-type": "application/json"];
    }
    
    private func checkCredentials() -> Bool {
        return credentials != nil && server != nil
    }
    
    public var authKeyForNotificatore : String {
        return getStringFromInfo(keyString: "AppApnsAuthKey")
    }
    
    public var baseUrlForNotificatore : String {
        return getStringFromInfo(keyString:"AppApnsBaseUrl")
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
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: successHandler)
        task.resume()
    }
    
    /**
     Make a request with the new request handler above this function.
     This may be the only call that don't need authentication.
     */
    @objc public func postLogin(successHandler: @escaping (String?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        let todoEndpoint: String = "\(server!)/authentication/login"
        guard let url = URL(string: todoEndpoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postStr = credentials!.getAuthenticationCredentials()
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
            _ = self.credentials!.setToken(digest:digest)
            
            // I return to caller method.
            successHandler(digest)
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
        let endPoint = "\(server!)/authentication/logout"
        guard let url = URL(string: endPoint) else {
            print(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postArgs = credentials!.getAuthenticatedCredentials()
        self.baseCall(url: url, method: "POST", headers: postArgs, body: nil, successHandler: successHandler)
    }
    
    @objc public func setAuthToken(token: String) -> Void {
        guard let t = token as String? else {
            print("API_ERROR: No token provided.")
            return
        }
        
        _ = self.credentials?.setToken(token: t)
    }
    
    /**
     Make a GET me request to NethCTI server.
     */
    @objc public func getMe(successHandler: @escaping (PortableNethUser?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        let b = self.checkCredentials() as Bool?
        if b != nil && !b! {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endPoint = "\(server!)/user/me" // Set the endpoint URL.
        guard let url = URL(string: endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let getHeaders = credentials!.getAuthenticatedCredentials()
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
            } catch {
                errorHandler("json error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    @objc public func registerDeviceId(deviceToken: String, withUser user: String, successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        guard let d = deviceToken as String? else {
            return // Device Token and User have to be not null.
        }
        guard let u = user as String? else {
            return
        }
        let endpointBaseUrl = "http://notificatore.apexnet.it/Notificatore.aspx"
        let plistEndpoint = self.baseUrlForNotificatore
        let apnsAppKey = "NETHCTI_APP"
        let plistAppKey = self.authKeyForNotificatore
        let endpointUrl = "\(endpointBaseUrl)?CMD=initapp&os=1&appkey=\(apnsAppKey)&devtoken=\(d)&user=\(u)"
        print("API CALL: Notification endpoint url: \(endpointUrl)")
        
        let url = URL(string: endpointUrl)
        
        self.baseCall(url: url!, method: "GET", headers: nil, body: nil, successHandler: successHandler)
    }
    
    @objc public func getPresence(successHandler: @escaping() -> Void, errorHandler: @escaping(String?) -> Void) -> Void { // Ready for the second release.
        let b = self.checkCredentials() as Bool?
        if b != nil && !b! {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue);
            return
        }
        
        let endPoint = "\(server!)/user/me" // Set the endpoint URL.
        guard let url = URL(string:endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = credentials!.getAuthenticatedCredentials()
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
