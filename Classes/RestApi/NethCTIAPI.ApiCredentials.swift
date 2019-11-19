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
        case SuiteNameKey = "NethCTIUserDefaults"
        case UserDefaultKey = "UserDefaultKey"
        case PasswordDefaultKey = "PasswordDefaultKey"
        case TokenDefaultKey = "TokenDefaultKey"
    }
    
    @objc public class ApiCredentials: NSObject {
        init(username: String?, password: String?) {
            UserDefaults.standard.set(password!, forKey: ApiClientIdentifier.PasswordDefaultKey.rawValue)
            UserDefaults.standard.set(username!, forKey: ApiClientIdentifier.UserDefaultKey.rawValue)
            print("API_MESSAGE: Credentials setted \(username!):\(password!).")
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
            
            let splitted = d.components(separatedBy: " ")
            let sum = "\(getUsername()!):\(getPassword()!):\(splitted[1])"
            guard let t = sum.hmac(key: getPassword()!) as String? else {
                print("No token generated.")
                return false;
            }
            
            UserDefaults.standard.set(t, forKey:ApiClientIdentifier.TokenDefaultKey.rawValue);
            print("API_MESSAGE: Token setted from \(sum) to \(t).")
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
            let token = UserDefaults.standard.string(forKey: ApiClientIdentifier.TokenDefaultKey.rawValue)
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
