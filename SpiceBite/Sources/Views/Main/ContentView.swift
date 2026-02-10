//
//  ContentView.swift
//  SpiceBite
//
//  Main tab navigation view
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)
            
            ExploreView()
                .tabItem {
                    Label(AppTab.explore.title, systemImage: AppTab.explore.icon)
                }
                .tag(AppTab.explore)
            
            CompareView()
                .tabItem {
                    Label(AppTab.compare.title, systemImage: AppTab.compare.icon)
                }
                .tag(AppTab.compare)
                .badge(appState.compareList.count > 0 ? appState.compareList.count : 0)
            
            SavedView()
                .tabItem {
                    Label(AppTab.saved.title, systemImage: AppTab.saved.icon)
                }
                .tag(AppTab.saved)
                .badge(appState.savedRestaurantIds.count > 0 ? appState.savedRestaurantIds.count : 0)
            
            ProfileView()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .tint(.brand)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(DataService.shared)
        .environmentObject(LocationService.shared)
}
