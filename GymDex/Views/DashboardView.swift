import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SummaryCard(
                        title: "Saldo Calorico",
                        value: "\(store.netCalories) kcal",
                        subtitle: "Consumidas: \(store.todayCaloriesConsumed) | Gastas: \(store.totalCaloriesBurned)"
                    )

                    SummaryCard(
                        title: "Passos de Hoje",
                        value: "\(store.todaySteps)",
                        subtitle: "Meta sugerida: 10.000 passos"
                    )

                    SummaryCard(
                        title: "Treinos na Semana",
                        value: "\(store.state.dailyTrainingDates.count)",
                        subtitle: "Streak atual: \(store.trainingStreak) dias"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Treinos do Plano")
                            .font(.headline)

                        ForEach(store.state.workoutPlans) { plan in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(plan.name)
                                    .font(.subheadline.weight(.semibold))
                                Text("\(plan.focus) • \(plan.weekday)")
                                    .foregroundStyle(.secondary)
                                Text("\(plan.exercises.count) exercicios")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("GymDex")
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.85), Color.red.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
