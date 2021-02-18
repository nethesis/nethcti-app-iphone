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
    
    /**
     Get a string from the info.plist resource file.
     */
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
    private func baseCall(url: URL, method: String, headers: [String: Any]?, body: [String: Any]?,
                          successHandler: @escaping (Data?, URLResponse?) -> Void,
                          errorHandler: @escaping(Int) -> Void) -> Void {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        // Headers handling.
        if let h = headers {
            urlRequest.allHTTPHeaderFields = h as? [String : String]
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        
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
        let task = session.dataTask(with: urlRequest) {
            data, response, error in
            if let e = error {
                Log.directLog(BCTBX_LOG_ERROR, text: e.localizedDescription)
                errorHandler(-1)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                errorHandler(httpResponse.statusCode)
                return;
            }
            else {
                successHandler(data, response)
            }
        }
        task.resume()
    }
    
    @objc public func saveCredentials(username:String, password:String, domain:String) -> Void {
        ApiCredentials.Username = username
        ApiCredentials.Domain = domain
        ApiCredentials.Password = password
    }
    
    /**
     Make a request with the new request handler above this function.
     This may be the only call that don't need authentication.
     */
    @objc public func postLogin(_ successHandler: @escaping (String?) -> Void, errorHandler: @escaping (Int, String?) -> Void) -> Void {
        if !ApiCredentials.checkCredentials() {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        guard let domain = ApiCredentials.Domain as String?,
              let transformedDomain = self.transformDomain(domain) as String?,
              let loginEndpoint = "\(transformedDomain)/authentication/login" as String?,
              let url = URL(string: loginEndpoint) else {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        guard let password = ApiCredentials.Password as String?,
              let postStr = ApiCredentials.getAuthenticationCredentials(password: password) else {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        self.baseCall(url: url, method: "POST", headers: nil, body: postStr, successHandler: {
            data, response in
            
            // Responde handling.
            guard let httpResponse = response as? HTTPURLResponse else {
                errorHandler(-2, "Did not receive response.")
                return
            }
            
            // Digest handling.
            guard let digest = httpResponse.allHeaderFields[AnyHashable("Www-Authenticate")] as? String else {
                errorHandler(-2, "AUTHENTICATE-HEADER-MISSING.")
                return
            }
            
            // I return to caller method.
            successHandler(ApiCredentials.setToken(password: password, digest: digest))
        }, errorHandler: {
            error in
            // Error handling.
            errorHandler(error, "Error calling POST on /authentication/login.")
        })
    }
    
    /**
     Make a POST logout request to NethCTI server.
     */
    @objc public func postLogout(successHandler: @escaping (String?) -> Void) -> Void {
        if !ApiCredentials.checkCredentials() {
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        // Before unregister from notificatore.
        registerPushToken(ApiCredentials.DeviceToken, unregister: true, success: {
            result in
            // Check result.
            if (result) {
                // After clear credentials.
                ApiCredentials.clear()
                successHandler("Logged out.")
            } else {
                print("[WEDO PUSH] Error unloading notificatore.")
                successHandler("Not logged out.")
            }
        })
        ApiCredentials.clear()
        return
        
        // Logout from Nethesis. Dosen't need anymore.
        // Set the url.
        /* let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/authentication/logout"
         guard let url = URL(string: endPoint) else {
         print(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
         return
         }
         
         let postArgs = ApiCredentials.getAuthenticatedCredentials()
         self.baseCall(url: url, method: "POST", headers: postArgs, body: nil)
         {
         data, response, error in
         // Error handling.
         guard error == nil else {
         print(error!)
         return
         }
         
         // Responde handling.
         guard let httpResponse = response as? HTTPURLResponse else {
         return
         }
         
         successHandler("Logged out.")
         }*/
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
    @objc public func getMe(successHandler: @escaping (PortableNethUser?) -> Void, errorHandler: @escaping (Int, String?) -> Void) -> Void {
        if !ApiCredentials.checkCredentials() {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/me" // Set the endpoint URL.
        guard let url = URL(string: endPoint) else {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil, successHandler: {
            data, response in
            guard let responseData = data else { // Responde handling.
                errorHandler(-2, "No data provided.")
                return
            }
            
            do{
                let userDict = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                let nethUser = try NethUser(from: userDict)
                
                self.registerPushToken(ApiCredentials.DeviceToken, unregister: false) { success in
                    //ignored
                }
                
                successHandler(PortableNethUser(from: nethUser!))
            } catch (let errorThrown) {
                errorHandler(-2, "json error: \(errorThrown.localizedDescription)")
                return
            }
        }, errorHandler: {
            error in // Error handling.
            errorHandler(error, "Error calling GET on /user/me")
            return
        })
    }
    
    @objc public func registerPushToken(_ deviceId: String, unregister: Bool, success:@escaping (Bool) -> Void) -> Void {
        // Check input values.
        guard
            let d = deviceId as String?,
            let user = ApiCredentials.Username as String?,
            let domain = ApiCredentials.Domain as String?,
            !user.isEmpty && !domain.isEmpty else {
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
        headers["X-AuthKey"] = self.authKeyForProdNot
        let endpointUrl = "\(self.baseUrlForProdNot)/NotificaPush"
        let mode = "Production";
        #endif
        
        // Generate the necessary bodies.
        var body: [String: Any] = [:]
        body["Os"] = 1
        body["DevToken"] = d
        body["RegID"] = d
        body["User"] = unregister ? "" : "\(user)@\(domain)"
        body["Language"] = ""
        body["Custom"] = ""
        
        // Build the final endpoint to notificator.
        print("[WEDO] [APNS SERVER]: You are in \(mode) Notification endpoint url \(endpointUrl) sending \(d)")
        guard let url = URL(string: endpointUrl) else {
            return
        }
        
        self.baseCall(url: url, method: "POST", headers: headers, body: body, successHandler: {
            data, response in
            guard let responseData = data as Data? else {
                print("[WEDO] [APNS SERVER]: No data provided")
                success(false)
                return
            }
            
            let dataString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
            print("[WEDO] [APNS SERVER]: response: \(String(describing: dataString))")
            success(true)
        }, errorHandler: { error in
            success(false)
        })
    }
    
    @objc public func getPresence(successHandler: @escaping() -> Void, errorHandler: @escaping(Int, String?) -> Void) -> Void { // Ready for the second release.
        if !ApiCredentials.checkCredentials() {
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endPoint = "\(ApiCredentials.Domain)/user/me" // Set the endpoint URL.
        guard let url = URL(string:endPoint) else {
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil, successHandler: {
            data, response in
            
            guard let responseData = data else { // Response handling.
                errorHandler(-2, "No data provided.")
                return
            }
            
            do{
                // Nothing here atm.
                _ = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                successHandler()
            } catch {
                errorHandler(-2, "json error: \(error.localizedDescription)")
                return
            }
        }, errorHandler: {error in
            errorHandler(error, "Error calling GET on /user/presence")
            return
        })
    }
    
    /**
     Make a request to proxy to get contacts by some parameters.
     View: Name or Company;
     Limit: Number of contacts to take;
     Offset: Starting point from taking contacts;
     Term: Search term to filter by;
     */
    @objc public func getContacts(view:String, limit:Int, offset:Int, term:String, successHandler: @escaping(NethPhoneBookReturn) -> Void, errorHandler: @escaping(Int, String?) -> Void) -> Void {
        // Build the request.
        if !ApiCredentials.checkCredentials() {
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            return
        }
        
        let endpoint = "\(self.transformDomain(ApiCredentials.Domain))/phonebook/search/\(term)?view=\(view)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string:endpoint) else {
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        // Make the request.
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil, successHandler: {
            data, response in
            guard let responseData = data else { // Response handling.
                errorHandler(1, "No data provided.")
                return
            }
            
            // Receive the results.
            do{
                // Convert to phonebook.
                let rawContacts = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                let contacts = try NethPhoneBookReturn(raw: rawContacts)
                successHandler(contacts)
            } catch {
                errorHandler(1, "json error: \(error.localizedDescription)")
                return
            }
        }, errorHandler: { error in
            errorHandler(error, "Error calling GET on /phonebook/search: Unauthorized exception")
            return
        })
    }
    
    let cLimit = 50
    
    @objc public func fetchContacts(_ v: String, t: String, success:@escaping([Contact]) -> Void, error:@escaping(Int, String?) -> Void) {
        let index = NethPhoneBook.instance().rows
        getContacts(view: v, limit: cLimit, offset: index, term: t, successHandler:  {
            phoneBookReturn in
            NethPhoneBook.instance().load(phoneBookReturn.rows.count, max: phoneBookReturn.count)
            success(phoneBookReturn.rows.map({ (NethContact) -> Contact in
                NethContact.toLinphoneContact()
            }))
        }, errorHandler: error)
    }
}
