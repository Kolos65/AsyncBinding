//
//  AsyncBindingDemoApp.swift
//  AsyncBindingDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import SwiftUI
import Resolver

@main
struct AsyncBindingDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Resolver.registerAppDependencies()
        return true
    }
}
