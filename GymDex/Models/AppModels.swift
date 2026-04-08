import Foundation

struct WorkoutExercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var sets: Int
    var reps: String
    var restSeconds: Int
    var caloriesPerSet: Int
    var videoTitle: String
    var videoURL: String

    init(
        id: UUID = UUID(),
        name: String,
        sets: Int,
        reps: String,
        restSeconds: Int,
        caloriesPerSet: Int,
        videoTitle: String,
        videoURL: String
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.caloriesPerSet = caloriesPerSet
        self.videoTitle = videoTitle
        self.videoURL = videoURL
    }
}

struct WorkoutPlan: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var focus: String
    var weekday: String
    var exercises: [WorkoutExercise]
    var completedDates: [String]

    init(
        id: UUID = UUID(),
        name: String,
        focus: String,
        weekday: String,
        exercises: [WorkoutExercise],
        completedDates: [String] = []
    ) {
        self.id = id
        self.name = name
        self.focus = focus
        self.weekday = weekday
        self.exercises = exercises
        self.completedDates = completedDates
    }
}

struct FoodEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fats: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fats: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.createdAt = createdAt
    }
}

struct FoodAnalysis: Identifiable, Codable, Hashable {
    let id: UUID
    var input: String
    var detectedItems: [FoodEntry]
    var totalCalories: Int
    var notes: String

    init(
        id: UUID = UUID(),
        input: String,
        detectedItems: [FoodEntry],
        totalCalories: Int,
        notes: String
    ) {
        self.id = id
        self.input = input
        self.detectedItems = detectedItems
        self.totalCalories = totalCalories
        self.notes = notes
    }
}

struct StepRecord: Codable, Hashable {
    var dateKey: String
    var count: Int
}

struct VideoResource: Identifiable, Codable, Hashable {
    let id: UUID
    var exerciseName: String
    var title: String
    var category: String
    var url: String

    init(
        id: UUID = UUID(),
        exerciseName: String,
        title: String,
        category: String,
        url: String
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.title = title
        self.category = category
        self.url = url
    }
}

struct StarterCreature: Identifiable, Codable, Hashable {
    let id: UUID
    var nickname: String
    var species: String
    var stage: Int
    var xp: Int
    var battlesWon: Int

    init(
        id: UUID = UUID(),
        nickname: String,
        species: String,
        stage: Int = 1,
        xp: Int = 0,
        battlesWon: Int = 0
    ) {
        self.id = id
        self.nickname = nickname
        self.species = species
        self.stage = stage
        self.xp = xp
        self.battlesWon = battlesWon
    }
}

struct CreatureCollectionEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var species: String
    var capturedAt: Date

    init(id: UUID = UUID(), species: String, capturedAt: Date = Date()) {
        self.id = id
        self.species = species
        self.capturedAt = capturedAt
    }
}

struct BattleLog: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var planName: String
    var summary: String

    init(id: UUID = UUID(), date: Date = Date(), planName: String, summary: String) {
        self.id = id
        self.date = date
        self.planName = planName
        self.summary = summary
    }
}

struct AppState: Codable {
    var workoutPlans: [WorkoutPlan]
    var foodEntries: [FoodEntry]
    var analyses: [FoodAnalysis]
    var videos: [VideoResource]
    var stepRecords: [StepRecord]
    var starter: StarterCreature
    var collection: [CreatureCollectionEntry]
    var battleLogs: [BattleLog]
    var dailyTrainingDates: [String]
    var calorieGoal: Int

    static func `default`() -> AppState {
        let squat = WorkoutExercise(
            name: "Agachamento Livre",
            sets: 4,
            reps: "10-12",
            restSeconds: 90,
            caloriesPerSet: 9,
            videoTitle: "Execucao correta do agachamento livre",
            videoURL: "https://www.youtube.com/results?search_query=agachamento+livre+execucao+correta"
        )
        let bench = WorkoutExercise(
            name: "Supino Reto",
            sets: 4,
            reps: "8-10",
            restSeconds: 90,
            caloriesPerSet: 8,
            videoTitle: "Como fazer supino reto",
            videoURL: "https://www.youtube.com/results?search_query=supino+reto+execucao+correta"
        )
        let row = WorkoutExercise(
            name: "Remada Curvada",
            sets: 4,
            reps: "10-12",
            restSeconds: 75,
            caloriesPerSet: 7,
            videoTitle: "Remada curvada passo a passo",
            videoURL: "https://www.youtube.com/results?search_query=remada+curvada+execucao+correta"
        )
        let cardio = WorkoutExercise(
            name: "Esteira",
            sets: 1,
            reps: "20 min",
            restSeconds: 0,
            caloriesPerSet: 120,
            videoTitle: "Treino de esteira para iniciantes",
            videoURL: "https://www.youtube.com/results?search_query=treino+na+esteira+iniciante"
        )

        let plans = [
            WorkoutPlan(name: "Treino A", focus: "Peito e Quadriceps", weekday: "Segunda", exercises: [bench, squat]),
            WorkoutPlan(name: "Treino B", focus: "Costas e Cardio", weekday: "Quarta", exercises: [row, cardio]),
            WorkoutPlan(name: "Treino C", focus: "Full Body", weekday: "Sexta", exercises: [squat, bench, row])
        ]

        let videos = [
            VideoResource(exerciseName: squat.name, title: squat.videoTitle, category: "Pernas", url: squat.videoURL),
            VideoResource(exerciseName: bench.name, title: bench.videoTitle, category: "Peito", url: bench.videoURL),
            VideoResource(exerciseName: row.name, title: row.videoTitle, category: "Costas", url: row.videoURL),
            VideoResource(exerciseName: cardio.name, title: cardio.videoTitle, category: "Cardio", url: cardio.videoURL)
        ]

        return AppState(
            workoutPlans: plans,
            foodEntries: [],
            analyses: [],
            videos: videos,
            stepRecords: [StepRecord(dateKey: DateKey.today, count: 4200)],
            starter: StarterCreature(nickname: "Seu Inicial", species: "Charmander"),
            collection: [],
            battleLogs: [],
            dailyTrainingDates: [],
            calorieGoal: 2200
        )
    }
}

enum DateKey {
    static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
