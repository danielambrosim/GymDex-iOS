import SwiftUI

struct WorkoutPlansView: View {
    @EnvironmentObject private var store: AppStore

    @State private var workoutName = ""
    @State private var workoutFocus = ""
    @State private var workoutDay = ""
    @State private var selectedPlanID: UUID?
    @State private var exerciseName = ""
    @State private var sets = "4"
    @State private var reps = "10"
    @State private var rest = "60"
    @State private var calories = "8"
    @State private var videoTitle = ""
    @State private var videoURL = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Criar ficha de treino") {
                    TextField("Nome da ficha", text: $workoutName)
                    TextField("Foco", text: $workoutFocus)
                    TextField("Dia da semana", text: $workoutDay)
                    Button("Salvar ficha") {
                        guard !workoutName.isEmpty, !workoutFocus.isEmpty, !workoutDay.isEmpty else { return }
                        store.addWorkoutPlan(name: workoutName, focus: workoutFocus, weekday: workoutDay)
                        workoutName = ""
                        workoutFocus = ""
                        workoutDay = ""
                    }
                }

                Section("Adicionar exercicio") {
                    Picker("Ficha", selection: $selectedPlanID) {
                        Text("Selecione").tag(UUID?.none)
                        ForEach(store.state.workoutPlans) { plan in
                            Text(plan.name).tag(Optional(plan.id))
                        }
                    }
                    TextField("Exercicio", text: $exerciseName)
                    TextField("Series", text: $sets)
                    TextField("Repeticoes", text: $reps)
                    TextField("Descanso em segundos", text: $rest)
                    TextField("Calorias por serie", text: $calories)
                    TextField("Titulo do video", text: $videoTitle)
                    TextField("URL do video", text: $videoURL)

                    Button("Adicionar exercicio") {
                        guard
                            let selectedPlanID,
                            let setCount = Int(sets),
                            let restSeconds = Int(rest),
                            let caloriesPerSet = Int(calories),
                            !exerciseName.isEmpty
                        else { return }

                        let exercise = WorkoutExercise(
                            name: exerciseName,
                            sets: setCount,
                            reps: reps,
                            restSeconds: restSeconds,
                            caloriesPerSet: caloriesPerSet,
                            videoTitle: videoTitle.isEmpty ? "Como fazer \(exerciseName)" : videoTitle,
                            videoURL: videoURL.isEmpty
                                ? "https://www.youtube.com/results?search_query=\(exerciseName.replacingOccurrences(of: " ", with: "+"))+execucao+correta"
                                : videoURL
                        )
                        store.addExercise(to: selectedPlanID, exercise: exercise)
                        exerciseName = ""
                        sets = "4"
                        reps = "10"
                        rest = "60"
                        calories = "8"
                        videoTitle = ""
                        videoURL = ""
                    }
                }

                Section("Fichas cadastradas") {
                    ForEach(store.state.workoutPlans) { plan in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plan.name)
                                        .font(.headline)
                                    Text("\(plan.focus) • \(plan.weekday)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if plan.completedDates.contains(DateKey.today) {
                                    Label("Treinado hoje", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }

                            ForEach(plan.exercises) { exercise in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text("\(exercise.sets)x \(exercise.reps) • descanso \(exercise.restSeconds)s")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Button("Registrar treino do dia") {
                                store.completeWorkout(planID: plan.id)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Ficha de Treino")
        }
    }
}
