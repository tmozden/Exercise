//
//  ExercisesOverview.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import SwiftUI

struct ExercisesOverview: View {
    private let selectionString = "viewer"
    
    @StateObject private var viewModel = ExercisesOverviewViewModel()
    @State private var selection: String?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.exercises) { exercise in
                        HStack {
                            if let data = ExerciseManager.shared.getImageData(for: exercise) {
                               if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 75)
                               } else {
                                Text("DataNotImage")
                               }
                            } else {
                                Text("Error")
                            }
                            Text(exercise.name)
                            Spacer()
                            Button(exercise.isFavorite ? "✭" : "✩" , action: { viewModel.toggleFavorite(exercise: exercise) })
                                .font(.title)
                        }
                    }
                }
                NavigationLink(destination: TrainingView(viewModel: TrainingViewModel(exercises: viewModel.exercises)), tag: selectionString, selection: $selection) { EmptyView() }
                Button("Start Training", action: {
                    selection = selectionString
                })
            }
            //Super hacky but couldnt find a better way to do it in SwiftUI in the little time
            //I searched
            .navigationTitle(selection == selectionString ? "Cancel Training" : "Exercises")
        }
    }
}

struct ExercisesOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesOverview()
    }
}
