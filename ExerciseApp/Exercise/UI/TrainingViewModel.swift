//
//  TrainingViewModel.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/12/21.
//

import Foundation
import Combine

class TrainingViewModel: ObservableObject {
    
    private var exercises: [Exercise]
    private var currentIndex: Int?
    @Published var currentExercise: Exercise?
    var cancellables: Set<AnyCancellable> = []
    
    init(exercises: [Exercise]) {
        self.exercises = exercises
        
        if !exercises.isEmpty {
            currentExercise = self.exercises[0]
            currentIndex = 0
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            guard let self = self, let currentIndex = self.currentIndex else { timer.invalidate(); return }
            let nextIndex = currentIndex + 1
            
            if nextIndex == self.exercises.count {
                self.currentIndex = nil
                self.currentExercise = nil
                timer.invalidate()
            } else {
                self.currentIndex = nextIndex
                self.currentExercise = exercises[nextIndex]
            }
        }
    }
    
    func toggleFavorite(exercise: Exercise) {
        guard let index = exercises.firstIndex(of: exercise) else {
            //should not be possible
            //log
            return
        }
        let toggled = Exercise(id: exercise.id,
                               name: exercise.name,
                               imageUrl: exercise.imageUrl,
                               videoUrl: exercise.videoUrl,
                               isFavorite: !exercise.isFavorite)
        exercises.replace(at: index, with: toggled)
        currentExercise = toggled
        ExerciseManager.shared.toggleFavorite(for: exercise)
    }
}
