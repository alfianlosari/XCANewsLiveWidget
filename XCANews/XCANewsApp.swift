//
//  XCANewsApp.swift
//  XCANews
//
//  Created by Alfian Losari on 6/27/21.
//

import SwiftUI
import UIKit
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WidgetCenter.shared.reloadAllTimelines()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            print(success)
            print(error?.localizedDescription ?? "No error for authorization permission")
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
    
}

@main
struct XCANewsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var articleBookmarkVM = ArticleBookmarkViewModel.shared
    
    @State var selectedArticleURL: URL? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.selectedArticleURL, $selectedArticleURL)
                .environmentObject(articleBookmarkVM)
                .onContinueUserActivity(activityTypeViewKey, perform: handleOnContinueUserActivity)
                .onOpenURL { selectedArticleURL = $0 }
                .sheet(item: $selectedArticleURL) {
                    SafariView(url: $0)
                        .edgesIgnoringSafeArea(.bottom)
                        .id($0)
                }
        }
    }
    
    private func handleOnReceiveNotification(_ notification: Notification) {
        if let url = notification.userInfo?["url"] as? URL {
            selectedArticleURL = url
        }
    }
    
    private func handleOnContinueUserActivity(_ userActivity: NSUserActivity) {
        if let urlString = userActivity.userInfo?[activityURLKey] as? String,
           let url = URL(string: urlString) {
            selectedArticleURL = url
        }
    }
}

struct SelectedArticleListURLKey: EnvironmentKey {
    
    static var defaultValue: Binding<URL?> = .constant(nil)
    
}

extension EnvironmentValues {
    
    var selectedArticleURL: Binding<URL?> {
        get { self[SelectedArticleListURLKey.self] }
        set { self[SelectedArticleListURLKey.self] = newValue }
        
    }
    
}
