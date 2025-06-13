//
//  FestiGoApp.swift
//  FestiGo
//
//  Created by kisellsn on 05/03/2025.
//
import FirebaseCore
import SwiftUI
import GoogleSignIn
import FirebaseMessaging
import UserNotifications

@main
struct FestiGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var eventListVM = EventListViewModel()
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    init() {
        Bundle.setLanguage(LanguageManager.shared.selectedLanguage)
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(
                    UserDefaults.standard.object(forKey: "isDarkMode") == nil
                    ? nil 
                    : (isDarkMode ? .dark : .light)
                )
                .environmentObject(eventListVM)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // Push-повідомлення
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }

    // Google Sign-In
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // FCM Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
        // Надіслати токен на сервер, якщо потрібно
    }

    // Push (foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                   @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // Scene configuration
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Cleanup
    }
    
    // Push (mock)
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Permission granted")
            } else {
                print("❌ Permission denied")
            }
        }
    }
}

