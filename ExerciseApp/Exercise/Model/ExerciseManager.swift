//
//  ExerciseManager.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import Foundation

/// This object is the api bridge between the "Exercise System" and the rest of the app
/// The UI as well as other areas of the app should come here for all of their exercise
/// needs and should never touch, know, or care about the underlying data store or
/// network handler.
class ExerciseManager {
    static private let storageKey = "exerciseManager.storage.key"
    //This class is a singleton
    static let shared = ExerciseManager()
    
    private let dataStore = ExerciseDataStore(with: storageKey)
    private let networkHandler = ExerciseNetworkhandler()
    
    private init() {
        networkHandler.delegate = self
        
        //Once per app run update the exercise list. This should be done in a more clean way
        requestListUpdate()
    }
    
    func isExerciseAFaviorite(exerciseId: Int) -> Bool {
        return dataStore.getExercise(with: exerciseId)?.isFavorite ?? false
    }
    
    func requestListUpdate() {
        networkHandler.requestExerciseList()
    }
    
    func getImageData(for exercise: Exercise) -> Data? {
        return dataStore.getImageData(for: exercise)
    }
    
    func getExercise(for id: Int) -> Exercise? {
        return dataStore.getExercise(with: id)
    }
    
    func getAllExercises() -> [Exercise] {
        return dataStore.getAllExercises()
    }
    
    func toggleFavorite(for exercise: Exercise) {
        let toggled = Exercise(id: exercise.id,
                               name: exercise.name,
                               imageUrl: exercise.imageUrl,
                               videoUrl: exercise.videoUrl,
                               isFavorite: !exercise.isFavorite)
        dataStore.save(exercise: toggled)
    }
}

extension ExerciseManager: ExerciseNetworkDelegate {
    func didReceive(exerciseList list: [Exercise]) {
        dataStore.saveNew(exerciseList: list)
    }
    
    func didReceive(error: ExerciseNetworkError) {
        //No-OP
        //Maybe show an alert to the user if appropriate or take some other action.
    }
    
    func didReceive(imageData: Data, for exercise: Exercise) {
        dataStore.save(imageData: imageData, for: exercise)
    }
}
