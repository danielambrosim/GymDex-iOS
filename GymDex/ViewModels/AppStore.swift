import Foundation
import SwiftUI

final class AppStore: ObservableObject {
    @Published private(set) var state: AppState

    private let storageKey = "gymdex.app.state"

    init() {
        if
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(AppState.self, from: data)
        {
            self.state = decoded
        } else {
            self.state = AppState.default()
        }
    }

    var todayCaloriesConsumed: Int {
        state.foodEntries
            .filter { Calendar.current.isDateInToday($0.createdAt) }
            .reduce(0) { $0 + $1.calories }
    }

    var todayWorkoutCalories: Int {
        state.workoutPlans.reduce(0) { partialResult, plan in
            guard plan.completedDates.contains(DateKey.today) else { return partialResult }
            let planCalories = plan.exercises.reduce(0) { $0 + ($1.caloriesPerSet * $1.sets) }
            return partialResult + planCalories
        }
    }

    var todaySteps: Int {
        state.stepRecords.first(where: { $0.dateKey == DateKey.today })?.count ?? 0
    }

    var stepCalories: Int {
        Int(Double(todaySteps) * 0.04)
    }

    var totalCaloriesBurned: Int {
        todayWorkoutCalories + stepCalories
    }

    var netCalories: Int {
        todayCaloriesConsumed - totalCaloriesBurned
    }

    var trainingStreak: Int {
        let sorted = state.dailyTrainingDates.sorted()
        guard !sorted.isEmpty else { return 0 }

        var streak = 0
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        while state.dailyTrainingDates.contains(formatter.string(from: date)) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }

    func addWorkoutPlan(name: String, focus: String, weekday: String) {
        let plan = WorkoutPlan(name: name, focus: focus, weekday: weekday, exercises: [])
        state.workoutPlans.append(plan)
        persist()
    }

    func addExercise(to planID: UUID, exercise: WorkoutExercise) {
        guard let index = state.workoutPlans.firstIndex(where: { $0.id == planID }) else { return }
        state.workoutPlans[index].exercises.append(exercise)
        state.videos.append(
            VideoResource(
                exerciseName: exercise.name,
                title: exercise.videoTitle,
                category: state.workoutPlans[index].focus,
                url: exercise.videoURL
            )
        )
        persist()
    }

    func completeWorkout(planID: UUID) {
        guard let index = state.workoutPlans.firstIndex(where: { $0.id == planID }) else { return }
        guard !state.workoutPlans[index].completedDates.contains(DateKey.today) else { return }

        state.workoutPlans[index].completedDates.append(DateKey.today)

        if !state.dailyTrainingDates.contains(DateKey.today) {
            state.dailyTrainingDates.append(DateKey.today)
        }

        runBattle(for: state.workoutPlans[index].name)
        persist()
    }

    func updateSteps(_ value: Int) {
        if let index = state.stepRecords.firstIndex(where: { $0.dateKey == DateKey.today }) {
            state.stepRecords[index].count = value
        } else {
            state.stepRecords.append(StepRecord(dateKey: DateKey.today, count: value))
        }
        persist()
    }

    func addFood(name: String, calories: Int, protein: Int, carbs: Int, fats: Int) {
        state.foodEntries.insert(
            FoodEntry(name: name, calories: calories, protein: protein, carbs: carbs, fats: fats),
            at: 0
        )
        persist()
    }

    @discardableResult
    func analyzeFoodInput(_ text: String) -> FoodAnalysis {
        let library: [String: FoodEntry] = [
            "ovo": FoodEntry(name: "Ovo", calories: 78, protein: 6, carbs: 0, fats: 5),
            "frango": FoodEntry(name: "Frango", calories: 165, protein: 31, carbs: 0, fats: 4),
            "arroz": FoodEntry(name: "Arroz", calories: 130, protein: 2, carbs: 28, fats: 0),
            "feijao": FoodEntry(name: "Feijao", calories: 110, protein: 7, carbs: 20, fats: 1),
            "banana": FoodEntry(name: "Banana", calories: 105, protein: 1, carbs: 27, fats: 0),
            "whey": FoodEntry(name: "Whey", calories: 120, protein: 24, carbs: 3, fats: 1),
            "batata": FoodEntry(name: "Batata Doce", calories: 112, protein: 2, carbs: 26, fats: 0),
            "pao": FoodEntry(name: "Pao", calories: 80, protein: 3, carbs: 15, fats: 1),
            "queijo": FoodEntry(name: "Queijo", calories: 90, protein: 6, carbs: 1, fats: 7),
            "carne": FoodEntry(name: "Carne Bovina", calories: 250, protein: 26, carbs: 0, fats: 15)
        ]

        let lowercased = text.lowercased()
        let matches = library.compactMap { key, value in
            lowercased.contains(key) ? value : nil
        }

        let detected = matches.isEmpty
            ? [FoodEntry(name: "Refeicao estimada", calories: 350, protein: 18, carbs: 35, fats: 12)]
            : matches

        let total = detected.reduce(0) { $0 + $1.calories }
        let analysis = FoodAnalysis(
            input: text,
            detectedItems: detected,
            totalCalories: total,
            notes: matches.isEmpty
                ? "Nenhum item reconhecido com precisao. Use a estimativa e ajuste manualmente."
                : "Itens reconhecidos com base no texto informado."
        )

        state.analyses.insert(analysis, at: 0)
        persist()
        return analysis
    }

    func captureCreatureIfEligible() -> String {
        let uniqueTrainingDays = Set(state.dailyTrainingDates).count
        let alreadyCaptured = state.collection.count
        let capturesAvailable = uniqueTrainingDays / 3

        guard capturesAvailable > alreadyCaptured else {
            return "Treine por mais dias para liberar uma nova captura."
        }

        let pool = ["Pikachu", "Machop", "Eevee", "Snorlax", "Psyduck", "Growlithe"]
        let species = pool[alreadyCaptured % pool.count]
        state.collection.append(CreatureCollectionEntry(species: species))
        persist()
        return "\(species) entrou para a sua colecao."
    }

    func chooseStarter(species: String, nickname: String) {
        state.starter = StarterCreature(
            nickname: nickname.isEmpty ? "Seu Inicial" : nickname,
            species: species
        )
        state.battleLogs = []
        persist()
    }

    private func runBattle(for planName: String) {
        state.starter.xp += 35
        state.starter.battlesWon += 1

        if state.starter.species == "Bulbasaur", state.starter.xp >= 70, state.starter.stage == 1 {
            state.starter.species = "Ivysaur"
            state.starter.stage = 2
        } else if state.starter.species == "Ivysaur", state.starter.xp >= 140, state.starter.stage == 2 {
            state.starter.species = "Venusaur"
            state.starter.stage = 3
        } else if state.starter.species == "Charmander", state.starter.xp >= 70, state.starter.stage == 1 {
            state.starter.species = "Charmeleon"
            state.starter.stage = 2
        } else if state.starter.species == "Charmeleon", state.starter.xp >= 140, state.starter.stage == 2 {
            state.starter.species = "Charizard"
            state.starter.stage = 3
        } else if state.starter.species == "Squirtle", state.starter.xp >= 70, state.starter.stage == 1 {
            state.starter.species = "Wartortle"
            state.starter.stage = 2
        } else if state.starter.species == "Wartortle", state.starter.xp >= 140, state.starter.stage == 2 {
            state.starter.species = "Blastoise"
            state.starter.stage = 3
        }

        state.battleLogs.insert(
            BattleLog(
                planName: planName,
                summary: "\(state.starter.nickname) venceu uma batalha depois do treino \(planName)."
            ),
            at: 0
        )
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
