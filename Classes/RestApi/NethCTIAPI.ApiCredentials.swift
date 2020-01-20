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
        case PasswordDefaultKey = "PasswordDefaultKey"      // Logged password.
        case NethTokenDefaultKey = "TokenDefaultKey"        // Logged token for nethcti servers.
        case DeviceIdDefaultKey = "DeviceIdDefaultKey"      // Logged deviceId for Notificatore.
        case NotifTokenDefaultKey = "NotifTokenDefaultKey"  // Logged auth token for Notificatore.
    }
    
    @objc public class ApiCredentials: NSObject {
        /**
         Init a new instance of ApiCredentials, optionally with Username or Password.
         Username or password can be nulls, because users can log in to NethCTI with authtoken directly.
         */
        init(username: String?, password: String?) {
            UserDefaults.standard.set(username, forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
            UserDefaults.standard.set(password, forKey: ApiClientIdentifier.PasswordDefaultKey.rawValue)
            print("API_MESSAGE: Credentials setted \(username ?? "no name"):\(password ?? "no pwd").")
        }
        
        /**
         Get the username.
         */
        public func getUsername() -> String? {
            return UserDefaults.standard.string(forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
        }
        
        /**
         Get the password.
         */
        public func getPassword() -> String? {
            return UserDefaults.standard.string(forKey: ApiClientIdentifier.PasswordDefaultKey.rawValue)
        }
        
        /**
         Generate the authorization token.
         */
        public func setToken(digest: String) -> Bool {
            guard let d = digest as String? else {
                print("No digest provided.")
                return false;
            }
            
            let splitted = d.components(separatedBy: " ") // "Digest 1234567890"
            let sum = "\(getUsername()!):\(getPassword()!):\(splitted[1])"
            guard let t = sum.hmac(key: getPassword()!) as String? else {
                print("No token generated.")
                return false;
            }
            
            UserDefaults.standard.set(t, forKey:ApiClientIdentifier.NethTokenDefaultKey.rawValue)
            print("API_MESSAGE: Token setted from \(sum) to \(t).")
            return true;
        }
        
        /**
         Set a generated token from QrCode data provisioning.
         */
        public func setToken(token: String) -> Bool {
            guard let t = token as String? else {
                print("No token provided.")
                return false;
            }
            
            UserDefaults.standard.set(t, forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue)
            print("API_MESSAGE: Token setted to \(t).")
            return true;
        }
        
        /**
         Prepare the login credential as form-data.
         */
        public func getAuthenticationCredentials() -> [String: String]? {
            return ["username": getUsername()!, "password": getPassword()!] as [String: String]
        }
        
        /**
         Use this after a successful login.
         TODO: Make this function stronger.
         */
        public func getAuthenticatedCredentials() -> [String: String]? {
            let token = UserDefaults.standard.string(forKey: ApiClientIdentifier.NethTokenDefaultKey.rawValue)
            return ["Authorization": "\(getUsername()!):\(token!)"] as [String: String]
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
