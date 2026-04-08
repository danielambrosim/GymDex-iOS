import SwiftUI

struct VideoLibraryView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.state.videos) { video in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.exerciseName)
                            .font(.headline)
                        Text(video.title)
                            .font(.subheadline)
                        Text(video.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let url = URL(string: video.url) {
                            Link("Abrir video", destination: url)
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Biblioteca de Videos")
        }
    }
}
