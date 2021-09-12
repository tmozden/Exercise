//
//  ExercisesOverviewViewModel.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import SwiftUI

class ExercisesOverviewViewModel: ObservableObject {

    @Published var exercises: [Exercise]
    
    init() {
        exercises = ExerciseManager.shared.getAllExercises()
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: .didSaveExerciseList, object: nil)
    }
    
    @objc
    private func updateList() {
        DispatchQueue.main.async { [weak self] in
            self?.exercises = ExerciseManager.shared.getAllExercises()
        }
    }
    
    func toggleFavorite(exercise: Exercise) {
        ExerciseManager.shared.toggleFavorite(for: exercise)
    }
}
