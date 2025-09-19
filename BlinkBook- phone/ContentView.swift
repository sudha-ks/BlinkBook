//
//  ContentView.swift
//  BlinkBook- phone
//
//  Created by Sudha on 10/09/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background
            Constants.DesignSystem.Colors.background
                .ignoresSafeArea()
            
            // Main content based on current screen
            switch coordinator.currentScreen {
            case .camera:
                CameraView()
                    .environmentObject(coordinator.cameraVM)
                    .environmentObject(coordinator)
            case .processing:
                ProcessingView()
                    .environmentObject(coordinator.ocrVM)
            case .review:
                ReviewView()
                    .environmentObject(coordinator.ocrVM)
                    .environmentObject(coordinator.contactVM)
                    .environmentObject(coordinator)
            case .success:
                SuccessView()
                    .environmentObject(coordinator.contactVM)
                    .environmentObject(coordinator)
            case .history:
                HistoryView()
                    .environmentObject(coordinator)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
    }
}

#Preview {
    MainView()
        .environmentObject(AppCoordinator())
}
