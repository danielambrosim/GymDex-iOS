import SwiftUI

struct NutritionView: View {
    @EnvironmentObject private var store: AppStore

    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fats = ""
    @State private var analysisInput = ""
    @State private var latestAnalysis: FoodAnalysis?
    @State private var stepsValue = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Contador de calorias") {
                    Text("Meta diaria: \(store.state.calorieGoal) kcal")
                    Text("Consumidas hoje: \(store.todayCaloriesConsumed) kcal")
                    Text("Gastas hoje: \(store.totalCaloriesBurned) kcal")
                    Text("Saldo: \(store.netCalories) kcal")
                }

                Section("Registrar refeicao") {
                    TextField("Nome da refeicao", text: $foodName)
                    TextField("Calorias", text: $calories)
                    TextField("Proteina", text: $protein)
                    TextField("Carboidratos", text: $carbs)
                    TextField("Gorduras", text: $fats)

                    Button("Adicionar refeicao") {
                        guard
                            let caloriesInt = Int(calories),
                            let proteinInt = Int(protein),
                            let carbsInt = Int(carbs),
                            let fatsInt = Int(fats),
                            !foodName.isEmpty
                        else { return }

                        store.addFood(
                            name: foodName,
                            calories: caloriesInt,
                            protein: proteinInt,
                            carbs: carbsInt,
                            fats: fatsInt
                        )

                        foodName = ""
                        calories = ""
                        protein = ""
                        carbs = ""
                        fats = ""
                    }
                }

                Section("Analisador de comida") {
                    TextField("Ex: 2 ovos, arroz, frango e banana", text: $analysisInput, axis: .vertical)
                    Button("Analisar") {
                        guard !analysisInput.isEmpty else { return }
                        latestAnalysis = store.analyzeFoodInput(analysisInput)
                    }

                    if let latestAnalysis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Resultado estimado: \(latestAnalysis.totalCalories) kcal")
                                .font(.headline)
                            ForEach(latestAnalysis.detectedItems) { item in
                                Text("\(item.name): \(item.calories) kcal")
                                    .font(.caption)
                            }
                            Text(latestAnalysis.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Contador de passos") {
                    Text("Passos hoje: \(store.todaySteps)")
                    TextField("Atualizar passos manualmente", text: $stepsValue)
                    Button("Salvar passos") {
                        guard let value = Int(stepsValue) else { return }
                        store.updateSteps(value)
                        stepsValue = ""
                    }
                    Text("Em um iPhone real, esta tela pode ser ligada ao HealthKit para sincronizar automaticamente.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Historico") {
                    ForEach(store.state.foodEntries.prefix(8)) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                            Text("\(item.calories) kcal • P \(item.protein)g • C \(item.carbs)g • G \(item.fats)g")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Calorias")
        }
    }
}
