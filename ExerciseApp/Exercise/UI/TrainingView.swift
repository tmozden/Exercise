//
//  TrainingView.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/12/21.
//

import SwiftUI
import Combine

struct TrainingView: View {
    
    @StateObject var viewModel: TrainingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Text("").onAppear {
                //Hacky but not sure how better to do this with SwiftUI
                viewModel.$currentExercise.sink {
                    if $0 == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }.store(in: &viewModel.cancellables)
            }
            if let exercise = viewModel.currentExercise {
                if let data = ExerciseManager.shared.getImageData(for: exercise) {
                   if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                   } else {
                    //Should log and show some better failure view here
                    Text("Data Is Not Image")
                   }
                } else {
                    //Should log and show some better failure view here
                    Text("Error No Image")
                }
                VStack {
                    Spacer()
                    Button(exercise.isFavorite ? "✭" : "✩" , action: { viewModel.toggleFavorite(exercise: exercise) })
                        .font(.title)
                }
            }
        }
    }
}

