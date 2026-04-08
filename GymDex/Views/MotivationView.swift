import SwiftUI

struct MotivationView: View {
    @EnvironmentObject private var store: AppStore

    @State private var nickname = ""
    @State private var selectedStarter = "Charmander"
    @State private var captureMessage = ""

    private let starters = ["Bulbasaur", "Charmander", "Squirtle"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Area de motivacao")
                            .font(.title2.bold())

                        Text("Seu motivador evolui quando voce treina e vence batalhas. Batalhas so acontecem nos dias em que um treino e registrado.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.state.starter.nickname)
                                .font(.headline)
                            Text(store.state.starter.species)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("Estagio \(store.state.starter.stage) • XP \(store.state.starter.xp) • Vitorias \(store.state.starter.battlesWon)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Escolher inicial")
                            .font(.headline)

                        Picker("Inicial", selection: $selectedStarter) {
                            ForEach(starters, id: \.self) { starter in
                                Text(starter).tag(starter)
                            }
                        }
                        .pickerStyle(.segmented)

                        TextField("Apelido", text: $nickname)

                        Button("Definir inicial") {
                            store.chooseStarter(species: selectedStarter, nickname: nickname)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Captura de novos pokemons")
                            .font(.headline)
                        Text("A cada 3 dias unicos de treino, uma nova captura e liberada.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Tentar captura") {
                            captureMessage = store.captureCreatureIfEligible()
                        }
                        .buttonStyle(.borderedProminent)

                        if !captureMessage.isEmpty {
                            Text(captureMessage)
                                .font(.caption)
                        }

                        ForEach(store.state.collection) { creature in
                            Text(creature.species)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Historico de batalhas")
                            .font(.headline)

                        ForEach(store.state.battleLogs.prefix(8)) { battle in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(battle.planName)
                                    .font(.subheadline.weight(.semibold))
                                Text(battle.summary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Motivacao")
        }
    }
}
