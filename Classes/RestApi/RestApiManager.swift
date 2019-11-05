//
//  RestApiManager.swift
//  linphone
//
//  Created by Administrator on 05/11/2019.
//

import Foundation

private enum ApiClientIdentifier : String {
    case UserDefaultKey = "UserDefaultKey"
    case PasswordDefaultKey = "PasswordDefaultKey"
}

@objc public class RestApiManager : NSObject {
    fileprivate let credentials: ApiCredentials?
    fileprivate let server: String
    fileprivate let default_url: String = "https://nethctiapp.nethserver.net/webrest"
    
    /**
     The base Url must be ever inizialized.
     */
    @objc init(user: String? = .none, pass: String? = .none, url: String?, userStoredCredentials: Bool = false) {
        // Here I check if user have some credentials.
        if let c = ApiCredentials.init(user: user, pass: pass) as ApiCredentials? {
            self.credentials = c
        } else {
            print("There's an error.");
            self.credentials = nil
        }
        
        // I ensure that baseurl have a value.
        if let u = url as String? {
            self.server = "https://\(u)/webrest"
        } else {
            self.server = default_url
        }
    }
    
    /**
     Use this to check if we are proud to do the rest call.
     */
    private func checkValidation() -> Bool {
        return credentials != nil
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
            print("API_CONFIRM: I send headers")
        } else {
            urlRequest.allHTTPHeaderFields = getDefaultHeaders()
            print("API_CONFIRM: I send default headers \(urlRequest.allHTTPHeaderFields!)")
        }
        
        // Body handling.
        if let b = body {
            do { // I try to use data.
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: b, options: [JSONSerialization.WritingOptions.prettyPrinted])
                print("API_CONFIRM: I send the body \(b)")
            } catch {
                print("API_ERROR: Fail body \(b)")
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
     */
    @objc public func postLogin(successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        let todoEndpoint: String = "\(server)/authentication/login"
        guard let url = URL(string: todoEndpoint) else {
            print("API_ERROR: cannot create URL.")
            return
        }
        
        let postStr = credentials!.getAuthenticationCredentials()
        // let postArgs = try JSONSerialization.jsonObject(with: credentials!, options: [])
        // let postArgs = Data.init(base64Encoded: self.credentials?.getLoginString() ?? "")
        self.baseCall(url: url, method: "POST", headers: nil, body: postStr, successHandler: successHandler)
    }
    
    @objc public func postLogout(successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        let endPoint = "\(server)/authentication/logout"
        guard let url = URL(string: endPoint) else {
            print("API_ERROR: cannot create URL.")
            return
        }
        
        let postArgs = credentials!.getAuthenticatedCredentials()
        self.baseCall(url: url, method: "POST", headers: postArgs, body: nil, successHandler: successHandler)
    }
    
    @objc public func getMe(successHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        let endPoint = "\(server)/user/me"
        guard let url = URL(string: endPoint) else {
            print("API_ERROR: cannot create URL.")
            return
        }
        
        let getHeaders = credentials!.getAuthenticatedCredentials()
        self.baseCall(url: url, method: "GET", headers: getHeaders, body: nil, successHandler: successHandler)
    }
    
    func getDefaultHeaders() -> [String: String] {
        return ["Content-type": "application/json"];
    }
}

extension RestApiManager {
    public struct ApiCredentials {
        private var username: String?
        private var password: String?
        fileprivate var token: String?
        
        public init(user: String? = .none, pass: String? = .none) {
            if let u = user, let p = pass {
                username = u
                password = p
            } else {
                print("This print have some problems.")
                username = ""
                password = ""
            }
        }
        
        public func getLoginString() -> String {
            // The ! ensure that the string is inizialized.
            return "{\"username\":\"\(username!)\",\"password\":\"\(password!)\"}";
        }
        
        /**
         Prepare the login credential as form-data.
         */
        public func getAuthenticationCredentials() -> [String: String]? {
            return ["username": username!, "password": password!] as [String: String]
        }
        
        /**
         Use this after a successful login.
         TODO: Make this function stronger.
         */
        public func getAuthenticatedCredentials() -> [String: String]? {
            return ["Authorization": "\(username!):\(token!)"] as [String: String]
        }
        
        /**
         Generate the authorization token.
         */
        public mutating func authenticateCredentials(digest: String) -> Bool {
            guard let d = digest as String? else {
                print("No digest provided.")
                return false;
            }
            
            self.token = d
            return true;
        }
    }
}
