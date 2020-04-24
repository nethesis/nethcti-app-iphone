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
    
    private func transformDomain(_ domain:String) -> String {
        return "https://\(domain)/webrest"
    }
    
    private var authKeyForSandNot : String {
        return getStringFromInfo(keyString: "AppApnsAuthKeyDev")
    }
    
    private var authKeyForProdNot : String {
        return getStringFromInfo(keyString: "AppApnsAuthKey")
    }
    
    private var baseUrlForSandNot : String {
        return getStringFromInfo(keyString: "AppApnsBaseUrl_Dev")
    }
    
    private var baseUrlForProdNot : String {
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
    private func baseCall(url: URL, method: String, headers: [String: Any]?, body: [String: Any]?, successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        // Headers handling.
        if let h = headers {
            urlRequest.allHTTPHeaderFields = h as? [String : String]
        } else {
            urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        }
        
        // Body handling.
        if let b = body {
            do { // I try to use data.
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: b, options: .prettyPrinted)
            } catch {
                return
            }
        } else {
            urlRequest.httpBody = nil // I don't need data.
        }
        
        let myDefault = URLSessionConfiguration.default
        myDefault.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        if #available(iOS 11.0, *) { myDefault.waitsForConnectivity = true }
        let session = URLSession(configuration: myDefault)
        let task = session.dataTask(with: urlRequest, completionHandler: successHandler)
        task.resume()
    }
    
    /**
     Make a request with the new request handler above this function.
     This may be the only call that don't need authentication.
     */
    @objc public func postLogin(username:String, password:String, domain:String, successHandler: @escaping (String?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        ApiCredentials.Username = username
        ApiCredentials.Domain = domain
        let loginEndpoint = "\(self.transformDomain(domain))/authentication/login"
        guard let url = URL(string: loginEndpoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postStr = ApiCredentials.getAuthenticationCredentials(password: password)
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
            successHandler(ApiCredentials.setToken(password: password, digest: digest))
        }
    }
    
    /**
     Make a POST logout request to NethCTI server.
     */
    @objc public func postLogout(successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        let b = ApiCredentials.checkCredentials() as Bool?
        if b != nil && b! {
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        // Set the url.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/authentication/logout"
        guard let url = URL(string: endPoint) else {
            print(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let postArgs = ApiCredentials.getAuthenticatedCredentials()
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
        
        ApiCredentials.Username = u
        ApiCredentials.NethApiToken = t
        ApiCredentials.Domain = d
    }
    
    /**
     Make a GET me request to NethCTI server.
     */
    @objc public func getMe(successHandler: @escaping (PortableNethUser?) -> Void, errorHandler: @escaping (String?) -> Void) -> Void {
        if !ApiCredentials.checkCredentials() {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/me" // Set the endpoint URL.
        guard let url = URL(string: endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
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
    
    @objc public func registerPushToken(_ deviceId: String, success:@escaping (String?) -> Void) -> Void {
        // Check input values.
        guard
            let d = deviceId as String?,
            let user = ApiCredentials.Username as String?,
            let domain = ApiCredentials.Domain as String? else {
                print("[WEDO] Missing information for notificator.")
                return
        }
        
        // Generate the necessary headers. Content type is already in the header.
        var headers: [String: Any] = [:]
        headers["X-HTTP-Method-Override"] = "Register"
        #if DEBUG
        headers["X-AuthKey"] = self.authKeyForSandNot
        let endpointUrl = "\(self.baseUrlForSandNot)/NotificaPush"
        let mode = "Sandbox";
        #else
        headers["X-AuthKey"] = self.authKeyForSandNot
        let endpointUrl = "\(self.baseUrlForSandNot)/NotificaPush"
        let mode = "Production";
        #endif
        
        // Generate the necessary bodies.
        var body: [String: Any] = [:]
        body["Os"] = 1
        body["DevToken"] = d
        body["RegID"] = d
        body["User"] = "\(user)@\(domain)" // Nethesis user with domain.
        body["Language"] = ""
        body["Custom"] = ""
        
        // Build the final endpoint to notificator.
        print("APNS SERVER: You are in \(mode) Notification endpoint url: \(endpointUrl)")
        guard let url = URL(string: endpointUrl) else {
            return
        }
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body) {
            data, response, error in
            guard
                error == nil,
                let responseData = data as Data? else {
                    print("APNS SERVER: No data provided, error: \(error!)")
                    return
            }
            
            let dataString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
            let logString = "[WEDO] response: \(String(describing: dataString))"
            success(logString)
        }
    }
    
    @objc public func getPresence(successHandler: @escaping() -> Void, errorHandler: @escaping(String?) -> Void) -> Void { // Ready for the second release.
        let b = ApiCredentials.checkCredentials() as Bool?
        if b != nil && !b! {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue);
            return
        }
        
        let endPoint = "\(ApiCredentials.Domain)/user/me" // Set the endpoint URL.
        guard let url = URL(string:endPoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
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
                // Nothing here atm.
                _ = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                successHandler()
            } catch {
                errorHandler("json error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    /**
     Make a request to proxy to get contacts by some parameters.
     View: Name or Company;
     Limit: Number of contacts to take;
     Offset: Starting point from taking contacts;
     Term: Search term to filter by;
     */
    @objc public func getContacts(view:String, limit:Int, offset:Int, term:String, successHandler: @escaping(NethPhoneBookReturn) -> Void, errorHandler: @escaping(String?) -> Void) -> Void {
        // Build the request.
        let b = ApiCredentials.checkCredentials() as Bool?
        if b != nil && !b! {
            errorHandler(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue);
            return
        }
        
        let endpoint = "\(self.transformDomain(ApiCredentials.Domain))/phonebook/search/\(term)?view=\(view)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string:endpoint) else {
            errorHandler(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        // Make the request.
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

            // Receive the results.
            do{
                // Convert to phonebook.
                let rawContacts = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                let contacts = try NethPhoneBookReturn(raw: rawContacts)
                successHandler(contacts)
            } catch {
                errorHandler("json error: \(error.localizedDescription)")
                return
            }
        }
    }
}
