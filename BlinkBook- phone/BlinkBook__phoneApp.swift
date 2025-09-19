//
//  BlinkBook__phoneApp.swift
//  BlinkBook- phone
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI

@main
struct BlinkBook__phoneApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appCoordinator)
        }
    }
}
