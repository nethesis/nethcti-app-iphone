//
//  ApiCredentials.swift
//  Wedo S.R.L.
//
//  Use this class to manage the credentials of the user to access to Nethesis APIs.
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
        case DeviceIdDefaultKey = "DeviceIdDefaultKey"      // Logged deviceId for Notificatore.
        case DomainDefaultKey = "DomainDefaultKey"          // Domain to call for neth apis.
        case MainExtensionKey = "NethesisMainExtension"
        case NethUserExport = "NethUserExport"
        case NethTokenDefaultKey = "NethTokenDefaultKey"    // Logged token for nethcti servers.
        case NotifTokenDefaultKey = "NotifTokenDefaultKey"  // Logged auth token for Notificatore.
        case UserDefaultKey = "UserDefaultKey"              // Logged username.
    }
    
    @objc public class ApiCredentials: NSObject {
        /**
         Get or set a username.
         */
        @objc public class var Username: String {
            get {
                return UserDefaults.standard.string(forKey: ApiClientIdentifier.UserDefaultKey.rawValue) ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
            }
        }
        
        /**
         Get or set a domain.
         */
        @objc public class var Domain: String {
            get {
                return UserDefaults.standard.string(forKey: ApiClientIdentifier.DomainDefaultKey.rawValue) ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.DomainDefaultKey.rawValue)
            }
        }
        
        /**
         Get or set the main extension.
         */
        @objc public class var MainExtension: String {
            get {
                return UserDefaults.standard.string(forKey: ApiClientIdentifier.MainExtensionKey.rawValue) ?? ""
            }
            set{
                UserDefaults.standard.setValue(newValue, forKey: ApiClientIdentifier.MainExtensionKey.rawValue)
            }
        }
        
        /**
         Get or set the main extension.
         */
        @objc public class var NethUserExport: PortableNethUser? {
            get {
                guard let userData = UserDefaults.standard.data(forKey: ApiClientIdentifier.NethUserExport.rawValue) else {
                    return nil;
                }
                let user = try? JSONDecoder().decode(PortableNethUser.self, from: userData)
                return user
            }
            set {
                if let encoded = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(encoded, forKey: ApiClientIdentifier.NethUserExport.rawValue)
                }
            }
        }
        
        /**
         Get or set the nethesis authorization token.
         */
        @objc public class var NethApiToken: String {
            get {
                return UserDefaults.standard.string(forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue) ?? "No token."
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue)
            }
        }
        
        /**
         Get or set deviceToken
         */
        @objc public class var DeviceToken: String {
            get {
                return UserDefaults.standard.string(forKey: ApiClientIdentifier.DeviceIdDefaultKey.rawValue) ?? ""
            }
            set {
                UserDefaults.standard.set(newValue, forKey: ApiClientIdentifier.DeviceIdDefaultKey.rawValue)
            }
        }
        
        /**
         Generate the authorization token.
         */
        public class func setToken(password: String, digest: String) -> String {
            guard let d = digest as String? else {
                let message = "No digest provided."
                print(message)
                return message;
            }
            
            // The token is in the "Digest 1234567890" form. Need to be split.
            let splitted = d.components(separatedBy: " ")
            let sum = "\(Username):\(password):\(splitted[1])"
            guard let t = sum.hmac(key: password) as String? else {
                let message = "No token generated."
                print(message)
                return message;
            }
            
            NethApiToken = t
            print("API_MESSAGE: Token setted from \(sum) to \(t).")
            return t;
        }
        
        
        /**
         Prepare the login credential as form-data.
         */
        public class func getAuthenticationCredentials(password: String) -> [String: String]? {
            
            return ["username": Username, "password": password] as [String: String]
        }
        
        
        /**
         Use this after a successful login.
         TODO: Make this function stronger.
         */
        public class func getAuthenticatedCredentials() -> [String: String]? {
            
            return ["Authorization": "\(Username):\(NethApiToken)"] as [String: String]
        }
        
        
        @objc public class func checkCredentials() -> Bool {
            
            return Username != "" && Domain != "" && NethApiToken != ""
        }
        
        
        public class func clear() -> Void {
            
            UserDefaults.standard.removeObject(forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
            UserDefaults.standard.removeObject(forKey: ApiClientIdentifier.DomainDefaultKey.rawValue)
            UserDefaults.standard.removeObject(forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue)
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
