import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }

            WorkoutPlansView()
                .tabItem {
                    Label("Treino", systemImage: "dumbbell.fill")
                }

            NutritionView()
                .tabItem {
                    Label("Calorias", systemImage: "fork.knife")
                }

            VideoLibraryView()
                .tabItem {
                    Label("Videos", systemImage: "play.rectangle.fill")
                }

            MotivationView()
                .tabItem {
                    Label("Motivacao", systemImage: "bolt.heart.fill")
                }
        }
        .tint(.orange)
    }
}
