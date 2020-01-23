//
//  RestApiManager.swift
//  linphone
//
//  Created by Administrator on 05/11/2019.
//

import Foundation
import Security

extension NethCTIAPI {
    /**
     Those enums was used for stored credentials. VERY IMPORTANT!
     */
    public enum ApiClientIdentifier : String {
        case SuiteNameKey = "it.nethesis.nethcti3"          // Name of the UserDefaults suite.
        case UserDefaultKey = "UserDefaultKey"              // Logged username.
        case DomainDefaultKey = "DomainDefaultKey"          // Domain to call for neth apis.
        case NethTokenDefaultKey = "NethTokenDefaultKey"    // Logged token for nethcti servers.
        case DeviceIdDefaultKey = "DeviceIdDefaultKey"      // Logged deviceId for Notificatore.
        case NotifTokenDefaultKey = "NotifTokenDefaultKey"  // Logged auth token for Notificatore.
    }
    
    @objc public class ApiCredentials: NSObject {
        /**
         Singleton init method.
         */
        private override init() {}
        private static let _singletonInstance = ApiCredentials()
        public class func sharedInstance() -> ApiCredentials {
            return ApiCredentials._singletonInstance
        }
        
        /**
         Get or set a username.
         */
        @objc public var Username: String {
            get {
                UserDefaults.standard.string(forKey: ApiClientIdentifier.UserDefaultKey.rawValue) ?? "No username."
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
            }
        }
        
        /**
         Get or set a domain.
         */
        @objc public var Domain: String {
            get {
                UserDefaults.standard.string(forKey: ApiClientIdentifier.DomainDefaultKey.rawValue) ?? "No domain."
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.DomainDefaultKey.rawValue)
            }
        }
        
        /**
         Get or set the nethesis authorization token.
         */
        @objc public var NethApiToken: String {
            get {
                UserDefaults.standard.string(forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue) ?? "No token."
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue)
            }
        }
        
        /**
         Generate the authorization token.
         */
        public func setToken(password: String, digest: String) -> String {
            guard let d = digest as String? else {
                let message = "No digest provided."
                print(message)
                return message;
            }
            
            let splitted = d.components(separatedBy: " ") // "Digest 1234567890"
            let sum = "\(self.Username):\(password):\(splitted[1])"
            guard let t = sum.hmac(key: password) as String? else {
                let message = "No token generated."
                print(message)
                return message;
            }
            
            self.NethApiToken = t
            print("API_MESSAGE: Token setted from \(sum) to \(t).")
            return t;
        }
        
        /**
         Prepare the login credential as form-data.
         */
        func getAuthenticationCredentials(password: String) -> [String: String]? {
            return ["username": self.Username, "password": password] as [String: String]
        }
        
        /**
         Use this after a successful login.
         TODO: Make this function stronger.
         */
        func getAuthenticatedCredentials() -> [String: String]? {
            return ["Authorization": "\(self.Username):\(self.NethApiToken)"] as [String: String]
        }
    }
}

extension String {
    /**
     Use this function to translate the string to an exadecimal string with HMAC-SHA1.
     */
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
