//
//  TokenManager.swift
//  FestiGo
//
//  Created by kisellsn on 12/05/2025.
//


import Security
import Foundation

struct TokenResponse: Codable {
    let access_token: String
}

class TokenManager {
    static let service = "com.festigo.token"
    static let account = "accessToken"
    static let shared = TokenManager()
    static let serverBaseUrl = Bundle.main.infoDictionary?["SERVER_BASE_URL"] as? String ?? ProcessInfo.processInfo.environment["SERVER_BASE_URL"]

    static func save(token: String) {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func authorizedRequest(to endpoint: String, method: String = "GET") -> URLRequest? {
        return TokenManager.createRequest(endpoint: endpoint, method: method, addAuth: true)
    }

    static func createRequest(endpoint: String, method: String = "GET", addAuth: Bool = false) -> URLRequest? {
        guard let base = serverBaseUrl,
              let url = URL(string: "\(base)\(endpoint)") else {
            print("❌ Помилка формування URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if addAuth, let token = load() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// отримання JWT
    func sendUserIdToBackend(_ userId: String) {
        guard let request = TokenManager.createRequest(endpoint: "/auth/firebase-login", method: "POST") else { return }
 
        var modifiedRequest = request
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: String] = ["user_id": userId]
        modifiedRequest.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: modifiedRequest) { data, response, error in
            guard let data = data else {
                print("❌ Немає даних або помилка: \(error?.localizedDescription ?? "невідома помилка")")
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                TokenManager.save(token: tokenResponse.access_token)
                print("✅ Access token збережено в Keychain.")
            } catch {
                print("❌ Не вдалося розпарсити токен:", error)
            }
        }.resume()
    }
}
