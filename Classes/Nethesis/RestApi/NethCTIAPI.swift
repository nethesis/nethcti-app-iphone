//
//  NethApiCalls.swift
//  linphone
//  Evaluate to move the error handling inside the base call.
//
//  Created by Administrator on 07/11/2019.
//

import Foundation
//import Alamofire
import FirebaseMessaging


@objc class NethCTIAPI : NSObject, URLSessionTaskDelegate {
    
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
    private func baseCall(url: URL,
                          method: String,
                          headers: [String: Any]?,
                          body: [String: Any]?,
                          successHandler: @escaping (Data?, URLResponse?) -> Void,
                          errorHandler: @escaping(Error?, URLResponse?) -> Void) -> Void {
        
        //print("baseCall url: \(url), method: \(method), body: \(String(describing: body))")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        // Headers handling.
        if let h = headers {
            
            urlRequest.allHTTPHeaderFields = h as? [String : String]
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.addValue("no-exp", forHTTPHeaderField: "Auth-Exp") // Header for mobile calls.
        
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
        
        let session = URLSession(configuration: myDefault, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: urlRequest) {
            
            data, response, error in
            
            if let e = error {
                
                Log.directLog(BCTBX_LOG_ERROR, text: e.localizedDescription)
                errorHandler(e, response)
                
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                
                errorHandler(error, response)
                
                return;
            }
            
            successHandler(data, response)
        }
        
        task.resume()
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        
        // waiting for connectivity, update UI, etc.
        NotificationCenter.default.post(name: Notification.Name("NethesisPhonebookPermissionRejection"), object: self, userInfo:["code": 2])
    }
    
    /**
     Make a request with the new request handler above this function.
     This may be the only call that don't need authentication.
     */
    @objc public func postLogin(_ username: String,
                                password: String,
                                domain: String,
                                successHandler: @escaping (String?) -> Void,
                                errorHandler: @escaping (Int, String?) -> Void) -> Void {
        
        guard let username = username as String?,
              let domain = domain as String?,
              let transformedDomain = self.transformDomain(domain) as String?,
              let loginEndpoint = "\(transformedDomain)/authentication/login" as String?,
              let url = URL(string: loginEndpoint) else {
            
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            
            return
        }
        
        ApiCredentials.Username = username
        ApiCredentials.Domain = domain
        
        guard let postStr = ApiCredentials.getAuthenticationCredentials(password: password) else {
            
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: nil,
                      body: postStr,
                      successHandler: { data, response in
                        
                        errorHandler(-2, "Why am I here? Post Login need to return a 401 status code, not 200.")
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error and Digest handling.
                        guard let httpResponse = response as? HTTPURLResponse,
                              let digest = httpResponse.allHeaderFields[AnyHashable("Www-Authenticate")] as? String else {
                            
                            errorHandler(-2, "AUTHENTICATE-HEADER-MISSING")
                            
                            return
                        }
                        
                        successHandler(ApiCredentials.setToken(password: password, digest: digest))
                      })
    }
    
    
    /**
     Make a POST logout request to NethCTI server.
     */
    @objc public func postLogout(successHandler: @escaping (String?) -> Void) -> Void {
        
        print("postLogout")

        if !ApiCredentials.checkCredentials() {
            
            print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        // Before unregister from notificatore push.
        registerPushToken(ApiCredentials.DeviceToken,
                          unregister: true,
                          success: { result in
                            
                            // Check result.
                            if (result) {
                                // Logout from asterisk.
                                
                                let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/authentication/logout"
                                
                                guard let url = URL(string: endPoint) else {
                                    
                                    print(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
                                    
                                    return
                                }
                                
                                let postArgs = ApiCredentials.getAuthenticatedCredentials()
                                //print("postArgs: \(String(describing: postArgs))")

                                self.baseCall(url: url,
                                              method: "POST",
                                              headers: postArgs,
                                              body: nil,
                                              successHandler: { data, response in
                                                // Ok handling.
                                                
                                                // Rimozione username, dominio, token nethesis e preferiti
                                                self.unsubscribeFromNotificationTopics()
                                                ApiCredentials.clear()
                                                
                                                successHandler("Logged out.")
                                                
                                              },
                                              errorHandler: { error, response in
                                                // Error handling.
                                                
                                                guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                                                    
                                                    successHandler("Unknown error: Not logged out.")
                                                    
                                                    return
                                                }
                                                
                                                successHandler("\(httpResponse.statusCode): Not logged out.")
                                                
                                                return
                                              })
                                
                            } else {
                                
                                print("ERRORE rimozione registrazione alle Notifiche Push.")
                                
                                successHandler("Not logged out.")
                            }
                          })
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
    @objc public func getMe(successHandler: @escaping (PortableNethUser?) -> Void,
                            errorHandler: @escaping (Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/me" // Set the endpoint URL.
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: { data, response in
                        
                        guard let responseData = data else { // Responde handling.
                            
                            errorHandler(-2, "No user information provided, contact an administrator.")
                            
                            return
                        }
                        
                        do{
                            let userDict = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                            let nethUser = try NethUser(from: userDict)
                            
                            // Set the right username if obtained (even with QrCode login too).
                            ApiCredentials.Username = nethUser?.username ?? ApiCredentials.Username
                            ApiCredentials.MainExtension = nethUser?.endpoints.mainExtension ?? ""
                            ApiCredentials.NethUserExport = nethUser?.export()
                            
                            self.registerPushToken(ApiCredentials.DeviceToken, unregister: false) { success in
                                //ignored
                            }
                            
                            successHandler(nethUser?.portable())
                            
                        } catch (let errorThrown) {
                            
                            errorHandler(-2, "json error: \(errorThrown.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/me: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "No user information provided, contact an administrator.")
                        
                        return
                      })
    }
    
    
    @objc public func isUserAuthenticated() -> Bool {
        
        return ApiCredentials.checkCredentials()
    }
    
    
    @objc public func registerPushToken(_ deviceId: String,
                                        unregister: Bool,
                                        success:@escaping (Bool) -> Void) -> Void {
        
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
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: {
                        
                        data, response in
                        guard let responseData = data as Data? else {
                            
                            print("[WEDO] [APNS SERVER]: No data provided")
                            
                            success(false)
                            
                            return
                        }
                        
                        let dataString = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)
                        
                        print("[WEDO] [APNS SERVER]: response: \(String(describing: dataString))")
                        
                        success(true)
                        
                      },
                      errorHandler: { error, response in
                        
                        success(false)
                      })
    }
    
    /*
    @objc public func getPresence(successHandler: @escaping() -> Void,
                                  errorHandler: @escaping(Int, String?) -> Void) -> Void { // Ready for the second release.
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(ApiCredentials.Domain)/user/me" // Set the endpoint URL.
        
        guard let url = URL(string:endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: {
                        
                        data, response in
                        
                        guard let responseData = data else {
                            
                            // Response handling.
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
                        
                      },
                      errorHandler: {
                        
                        error, response in
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/presence: missing response data.")
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling GET on /user/presence")
                        
                        return
                      })
    }
    */
    
    
    let cLimit = 100
    
    /// Make a request to proxy to get contacts by some parameters.
    /// - Parameters:
    ///   - v: Person, Company or All (fetch both)
    ///   - t: Search term to filter by;
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func fetchContacts(_ v: String,
                                    t: String?,
                                    success:@escaping([Contact]) -> Void,
                                    errorHandler:@escaping(Int, String?) -> Void) {
        // Build the request.
        if !ApiCredentials.checkCredentials() {
            
            //print(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        var endpoint: String? = ""
        let index = NethPhoneBook.instance().rows
        
        if let term = t, term != "" {
            
            //Returns all the phonebook contacts founded in the centralized and NethCTI phonebooks.
            endpoint = "/phonebook/search/\(term)?view=all&limit=\(cLimit)&offset=\(index)" // \(term)?view=\(view)&
            
        }else {
            
            endpoint = "/phonebook/getall/?limit=\(cLimit)&offset=\(index)"
        }
        
        guard let domain = self.transformDomain(ApiCredentials.Domain) as String?,
              let complete = "\(domain)\(endpoint!)" as String?,
              let sanitized = complete.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string:sanitized) else {
            
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        //print("url: \(url)")

        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        // Make the request.
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: { data, response in
            
            guard let responseData = data else { // Response handling.
                
                errorHandler(1, "No data provided.")
                
                return
            }
            
            do { // Receive the results.
                let rawContacts = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                
                // Convert to phonebook.
                let contacts = try NethPhoneBookReturn(raw: rawContacts)
                
                // NethPhoneBook.instance().load(phoneBookReturn.rows.count, max: phoneBookReturn.count)
                NethPhoneBook.instance().load(contacts.rows.count, more: contacts.rows.count >= self.cLimit)
                
                success(contacts.rows.map({ (NethContact) -> Contact in
                    
                    NethContact.toLinphoneContact()
                }))
                
            } catch SerializationError.missing(let obj) {
                
                errorHandler(1, "Missing json fields: \(obj)")
                
            } catch {
                
                errorHandler(1, "Unknown error: \(error.localizedDescription)") // error refer to catched error.
            }
            
        },
                      errorHandler: { error, response in // Error handling.
            
            guard let httpResponse = response as? HTTPURLResponse else {
                
                errorHandler(-2, "Error calling GET on /phonebook/search: missing response data.")
                
                return
            }
            
            errorHandler(httpResponse.statusCode, "Error calling GET on /phonebook/search")
            
            return
        })
    }
    
    
    
    /// Ottengo le info dell'utente loggato nell'app
    /// - Parameters:
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func getUserMe(successHandler: @escaping (PortableNethUser?) -> Void,
                                errorHandler: @escaping (Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/me" // Set the endpoint URL.
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: { data, response in
                        
                        guard let responseData = data else { // Responde handling.
                            
                            errorHandler(-2, "No information provided, contact an administrator.")
                            
                            return
                        }
                        
                        do{
                            
                            let resultJson = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                            //print("resultJson: \(resultJson)")
                            
                            let nethUser = try NethUser(from: resultJson)
                                                        
                            successHandler(nethUser?.portable())
                            
                            
                        } catch (let errorThrown) {
                            
                            errorHandler(-2, "json error: \(errorThrown.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        //print("error: \(String(describing: error?.localizedDescription))")
                        //print("response: \(String(describing: response)))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/me: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "No user information provided, contact an administrator.")
                        
                      })
    }
    
    
    /// Ottengo la lista di tutti i gruppi associati all'utente loggato nell'app
    /// - Parameters:
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func getGroups(successHandler: @escaping(Array<GroupObjc>) -> Void,
                                errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/opgroups" // Set the endpoint URL.
        
        guard let url = URL(string:endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: { data, response in
                        
                        guard let responseData = data else { // Response handling.
                            
                            errorHandler(-2, "No data provided.")
                            
                            return
                        }
                        
                        do {
                            
                            let resultJson = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                            //print("resultJson: \(resultJson)")
                            
                            var arrayGroups: [GroupObjc] = []
                            
                            for (key, value) in resultJson {
                                
                                let currentGroup: Group = Group(key: key, value: value as! [String: Any])!
                                //print("currentGroup.id_group: \(String(describing: currentGroup.id_group))")
                                
                                arrayGroups.append(currentGroup.exportObjc() as GroupObjc)
                            }
                                                        
                            successHandler(arrayGroups)
                            
                        } catch {
                            
                            errorHandler(-2, "json error: \(error.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /astproxy/opgroups: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling GET on /astproxy/opgroups")
                        
                        return
                      })
    }
    
    
    /// Ottengo la lista di tutti gli utenti
    /// - Parameters:
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func getUserAll(successHandler: @escaping(Array<PresenceUserObjc>) -> Void,
                                 errorHandler: @escaping (Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/endpoints/all" // Set the endpoint URL.
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: {data, response in
                        
                        guard let responseData = data else { // Responde handling.
                            
                            errorHandler(-2, "No information provided, contact an administrator.")
                            
                            return
                        }
                        
                        do{
                            
                            let resultJson = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                            //print("resultJson: \(resultJson)")
                            
                            var arrayUsers: [PresenceUserObjc] = []
                            
                            for (_, value) in resultJson {
                                
                                //print("current key: \(key)")
                                //print("current value: \(value)")
                                
                                if let valueDictionary = value as? [String: Any] {
                                    
                                    let currentPresenceUser = try PresenceUser(from: valueDictionary)
                                    //print("currentPresenceUser: \(String(describing: currentPresenceUser))")
                                    
                                    arrayUsers.append((currentPresenceUser?.exportObjc())!)
                                }
                            }
                            
                            //print("arrayUsers: \(arrayUsers)")
                            
                            successHandler(arrayUsers)
                            
                            
                        } catch (let errorThrown) {
                            
                            errorHandler(-2, "json error: \(errorThrown.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/endpoints/all: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "No users information provided, contact an administrator.")
                        
                        return
                      })
    }
    
    
    
    /// Ottengo la lista delle presence impostabili per l'utente loggato nell'app
    /// - Parameters:
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func getPresenceList(successHandler: @escaping(Array<String>) -> Void,
                                      errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/presencelist"
        
        guard let url = URL(string:endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: headers,
                      body: nil,
                      successHandler: { data, response in
                        
                        // Response handling.
                        guard let responseData = data else {
                            
                            errorHandler(-2, "No data provided.")
                            
                            return
                        }
                        
                        do {
                            
                            let resultJson = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String]
                            //print("resultJson: \(resultJson)")
                            
                            successHandler(resultJson)
                            
                        }catch {
                            
                            errorHandler(-2, "json error: \(error.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/presencelist: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling GET on /user/presencelist")
                        
                        return
                      })
        
    }
    
    
    
    /// Imposta la presence dell'utente loggato nell'App
    /// - Parameters:
    ///   - status: tipologia di presence
    ///   - number: parametro opzionale che nel caso di Inoltro contiene il numero inserito dall'utente a ciu viene inoltrata la chiamata in arrivo
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postSetPresence(status: String,
                                      number: String,
                                      successHandler: @escaping (String?) -> Void,
                                      errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/user/presence"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        
        var body: [String: Any] = [:]
        
        body["status"] = status
        
        if (number != "") {
            
            body["to"] = number
        }
        print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post impostazione presence SUCCESS")
                            
                            return
                        }
                        
                        successHandler("Post impostazione presence SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on /user/presence: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on /user/presence")
                      })
        
    }
    
    
        
    /// Ottengo le informazioni di tutti gli interni e lo stato telefonico di ognuno
    /// - Parameters:
    ///   - arrayExtensionsId: lista di Extension da controllare
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func getExtensions(arrayExtensionsId: Array<String>,
                                      successHandler: @escaping(ConversationObjc?) -> Void,
                                        errorHandler: @escaping (Int, String?) -> Void) -> Void {
        
        //print("arrayExtensionsId: \(arrayExtensionsId)")

        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/extensions" // Set the endpoint URL.
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let getHeaders = ApiCredentials.getAuthenticatedCredentials()
        
        self.baseCall(url: url,
                      method: "GET",
                      headers: getHeaders,
                      body: nil,
                      successHandler: {data, response in
                        
                        guard let responseData = data else { // Responde handling.
                            
                            errorHandler(-2, "No information provided, contact an administrator.")
                            
                            return
                        }
                        
                        do{
                            
                            let resultJson = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                            //print("resultJson: \(resultJson)")
                            
                            //print("arrayExtensionsId.count: \(arrayExtensionsId.count)")

                            for currentExtension: String in arrayExtensionsId {
                                
                                //print("currentExtension: \(currentExtension)")
                                
                                if let dictConversation = resultJson[currentExtension] as? [String: Any] {
                                    
                                    //print("dictConversation: \(dictConversation)")
                                    
                                    let astproxyExtension = Extension(from: dictConversation)
                                    //print("astproxyExtension: \(String(describing: astproxyExtension))")
                                    
                                    //print("conversations: \(String(describing: astproxyExtension?.conversations))")

                                    if astproxyExtension?.conversations != nil {
                                                                                                                        
                                        successHandler((astproxyExtension?.conversations?.exportObjc())!)
                                        
                                        return
                                        
                                    }else {
                                        
                                        print("conversations nil! -> continue")
                                        
                                        continue
                                    }
                                    
                                }else {
                                    
                                    print("chiave non trovata!")
                                    
                                    errorHandler(-2, "No information provided, contact an administrator.")
                                    
                                    return
                                }
                            }
                            
                            print("Nessuna conversation trovata!")
                            
                            errorHandler(-2, "No information provided, contact an administrator.")
                            
                            return
                            
                            
                        } catch (let errorThrown) {
                            
                            errorHandler(-2, "json error: \(errorThrown.localizedDescription)")
                            
                            return
                        }
                        
                      },
                      errorHandler: { error, response in
                        
                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling GET on /user/endpoints/all: missing response data.")
                            
                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "No users information provided, contact an administrator.")
                        
                        return
                      })
    }
    
    
    
    /// Prenota la chiamata per un utente momentaneamente occupato.
    /// - Parameters:
    ///   - caller: mainExtension di chi prenota la richiamata
    ///   - called: mainExtension del destinatario della richiamata
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postRecallOnBusy(caller: String,
                                       called: String,
                                       successHandler: @escaping (String?) -> Void,
                                       errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/recall_on_busy"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        
        var body: [String: Any] = [:]
        
        body["caller"] = caller
        body["called"] = called
        
        //print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post prenota OK!")
                            
                            return
                        }
                        
                        successHandler("Post prenota SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/recall_on_busy: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/recall_on_busy")
                      })
        
    }
    
    
    
    /// Invia al server la richiesta per spiare la chiamata di un utente.
    /// - Parameters:
    ///   - conversationsId: l’id della conversazione in corso
    ///   - conversationOwner: l’estensione che ha la conversazione in corso
    ///   - extensionId: l’estensione dell'utente loggato sull’app
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postStartSpy(conversationsId: String,
                                   conversationOwner: String,
                                   extensionId: String,
                                   successHandler: @escaping (String?) -> Void,
                                   errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/start_spy"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        
        var body: [String: Any] = [:]
        
        body["convid"] = conversationsId
        body["endpointId"] = conversationOwner
        body["destId"] = extensionId

        //print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post spina OK!")
                            
                            return
                        }
                        
                        successHandler("POST spina SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/start_spy: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/start_spy")
                      })
        
    }
    
    
    
    /// Invia al server la richiesta per intromettersi nella chiamata di un utente.
    /// - Parameters:
    ///   - conversationsId: l’id della conversazione in corso
    ///   - conversationOwner: l’estensione che ha la conversazione in corso
    ///   - extensionId: l’estensione dell'utente loggato sull’app
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postIntrude(conversationsId: String,
                                  conversationOwner: String,
                                  extensionId: String,
                                  successHandler: @escaping (String?) -> Void,
                                  errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/intrude"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        
        var body: [String: Any] = [:]
        
        body["convid"] = conversationsId
        body["endpointId"] = conversationOwner
        body["destId"] = extensionId

        //print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post intromettiti OK!")
                            
                            return
                        }
                        
                        successHandler("POST intromettiti SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/intrude: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/intrude")
                      })
        
    }
    
    
    /// Invia al server la richiesta per registrare una chiamata in corso di un utente.
    /// - Parameters:
    ///   - conversationsId: l’id della conversazione in corso
    ///   - conversationOwner: l’estensione che ha la conversazione in corso
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postAdRecording(conversationsId: String,
                                      conversationOwner: String,
                                      successHandler: @escaping (String?) -> Void,
                                      errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/unmute_record"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        
        var body: [String: Any] = [:]
        
        body["convid"] = conversationsId
        body["endpointId"] = conversationOwner

        //print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post Registra OK!")
                            
                            return
                        }
                        
                        successHandler("POST Registra SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/unmute_record: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/unmute_record")
                      })
        
    }
    
    
    
    /// Invia al server la richiesta per chiudere la chiamata di qualcun’altro.
    /// - Parameters:
    ///   - conversationsId: l’id della conversazione in corso
    ///   - conversationOwner: l’estensione che ha la conversazione in corso
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postChiudi(conversationsId: String,
                                 conversationOwner: String,
                                 successHandler: @escaping (String?) -> Void,
                                 errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/hangup"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        var body: [String: Any] = [:]
        
        body["convid"] = conversationsId
        body["endpointId"] = conversationOwner

        //print("body: \(body)")
        
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in
                                                

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post Chiudi OK!")
                            
                            return
                        }
                        
                        successHandler("POST Chiudi SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/hangup: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/hangup")
                      })
        
    }
    
    
    /// Invia al server la richiesta per prendere la chiamata di un utente che ha una chiamata in arrivo in stato ringing.
    /// - Parameters:
    ///   - mainExtensionId: l’id della la main extension dell'utente che ha la conversazione in corso
    ///   - extensionId: l’estensione dell'utente loggato sull’app
    ///   - successHandler: Handle success result
    ///   - errorHandler: Handle error result
    @objc public func postPickup(mainExtensionId: String,
                                 extensionId: String,
                                 successHandler: @escaping (String?) -> Void,
                                 errorHandler: @escaping(Int, String?) -> Void) -> Void {
        
        if !ApiCredentials.checkCredentials() {
            
            print("NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue: \(NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)")
            errorHandler(1, NethCTIAPI.ErrorCodes.MissingAuthentication.rawValue)
            
            return
        }
        
        
        // Set the endpoint URL.
        let endPoint = "\(self.transformDomain(ApiCredentials.Domain))/astproxy/pickup_conv"
        
        guard let url = URL(string: endPoint) else {
            
            print("NethCTIAPI.ErrorCodes.MissingServerURL.rawValue: \(NethCTIAPI.ErrorCodes.MissingServerURL.rawValue)")
            errorHandler(-2, NethCTIAPI.ErrorCodes.MissingServerURL.rawValue);
            
            return
        }
        /*
        if !self.isConnectedToInternet() {
            errorHandler(2, "Errore Connessione")
            return
        }
        */
        let headers = ApiCredentials.getAuthenticatedCredentials()
        
        var body: [String: Any] = [:]
        
        body["endpointId"] = mainExtensionId
        body["destId"] = extensionId

        //print("body: \(body)")
        
        self.baseCall(url: url,
                      method: "POST",
                      headers: headers,
                      body: body,
                      successHandler: { data, response in

                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            successHandler("Post Pickup OK!")
                            
                            return
                        }
                        
                        successHandler("POST Pickup SUCCESS with statusCode: \(httpResponse.statusCode)")
                                                
                      },
                      errorHandler: { error, response in
                        
                        print("error: \(String(describing: error?.localizedDescription))")

                        // Error handling.
                        guard let httpResponse = response as? HTTPURLResponse else {
                            
                            errorHandler(-2, "Error calling POST on ../astproxy/pickup_conv: missing response data.")

                            return
                        }
                        
                        errorHandler(httpResponse.statusCode, "Error calling POST on ../astproxy/pickup_conv")
                      })
        
    }
    
    /*
    func isConnectedToInternet() -> Bool {
        
        return NetworkReachabilityManager()!.isReachable
    }
    */
    // MARK: - Notifications Handlers
    private var didSubscribeToNotificationTopics: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didSubscribeToNotificationTopics")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "didSubscribeToNotificationTopics")
        }
    }
    
    @objc func subscribeToNotificationTopics() {
        guard
            let user = ApiCredentials.Username as String?,
            let domain = ApiCredentials.Domain as String?,
            let appName = Bundle.main.appName,
            !user.isEmpty && !domain.isEmpty,
            !didSubscribeToNotificationTopics else {
            return
        }
        Messaging.messaging().subscribe(toTopic: appName)
        Messaging.messaging().subscribe(toTopic: "\(user)%\(domain)")
        Messaging.messaging().subscribe(toTopic: domain)
        didSubscribeToNotificationTopics = true
        print("[NethCTIAPI] Subscribed to notification topics")
    }
    
    @objc func unsubscribeFromNotificationTopics() {
        guard
            let user = ApiCredentials.Username as String?,
            let domain = ApiCredentials.Domain as String?,
            let appName = Bundle.main.appName,
            !user.isEmpty && !domain.isEmpty else {
            return
        }
        Messaging.messaging().unsubscribe(fromTopic: appName)
        Messaging.messaging().unsubscribe(fromTopic: "\(user)%\(domain)")
        Messaging.messaging().unsubscribe(fromTopic: domain)
        didSubscribeToNotificationTopics = false
        print("[NethCTIAPI] Unsubscribed from notification topics")
    }
}


extension Bundle {
    var appName: String? {
        if let displayName = self.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        } else if let name = self.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return nil
    }
}
