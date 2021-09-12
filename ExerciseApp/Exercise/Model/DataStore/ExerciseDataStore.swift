//
//  ExerciseDataStore.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import Foundation

/// This class is responsable for persisting exercise data locally.
class ExerciseDataStore {
    private static let storeBaseKey = "exercise.datastore."
    private let imageBasePath: URL
    private let key: String
    private let encoder = JSONEncoder()
    private let queue = DispatchQueue(label: "exercise.datastore.queue")
    
    private lazy var storageKey = {
        return ExerciseDataStore.storeBaseKey + key
    }()
    
    private var exerciseList: [Exercise] = [] {
        didSet {
            do {
                let data = try encoder.encode(exerciseList)
                UserDefaults.standard.setValue(data, forKey: storageKey)
            } catch {
                //assertfailure so debug builds will crash here and clearly indicate a problem but prod wont.
                assertionFailure("Failed to encode exercise list")
                //Use logging system to log error here so prod will still have
                //logs of issue.
            }
        }
    }
    
    init(with key: String) {
        self.key = key
        
        let libraryFolder = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let imageFolder = libraryFolder.appendingPathComponent("images")
        if !FileManager.default.fileExists(atPath: imageFolder.absoluteString) {
            do {
            try FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                //log error
                print("Failed to create images directory")
            }
        }
        imageBasePath = imageFolder
        
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            let decoder = JSONDecoder()
            do {
                exerciseList = try decoder.decode([Exercise].self, from: data)
            } catch {
                assertionFailure("Failed to decode exercise list")
                //Log error with loging system here
            }
        }
    }
    
    func getAllExercises() -> [Exercise] {
        var list: [Exercise] = []
        queue.sync {
            list = exerciseList
        }
        return list
    }
    
    func getExercise(with id: Int) -> Exercise? {
        var exercise: Exercise?
        queue.sync {
            exercise = exerciseList.first { $0.id == id }
        }
        return exercise
    }
    
    func getImageData(for exercise: Exercise) -> Data? {
        let localUrl = imageBasePath.appendingPathComponent("\(exercise.id)")
        return try? Data(contentsOf: localUrl)
    }
    
    func saveNew(exerciseList list: [Exercise]) {
        queue.async { [weak self] in
            self?.exerciseList = list
            self?.notify()
        }
    }
    
    func save(imageData: Data, for exercise: Exercise) {
        let localUrl = imageBasePath.appendingPathComponent("\(exercise.id)")
        try? FileManager.default.removeItem(at: localUrl)
        do {
            try imageData.write(to: localUrl)
            let updatedExercise = Exercise(id: exercise.id,
                                           name: exercise.name,
                                           imageUrl: exercise.imageUrl,
                                           videoUrl: exercise.videoUrl,
                                           isFavorite: exercise.isFavorite)
            save(exercise: updatedExercise)
        } catch {
            //Log failure to save data
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
    
    func save(exercise: Exercise) {
        queue.sync {
            if let index = exerciseList.firstIndex(of: exercise) {
                exerciseList.replace(at: index, with: exercise)
            } else {
                exerciseList.append(exercise)
            }
            notify()
        }
    }
    
    private func notify() {
        DispatchQueue.global().async {
            NotificationCenter.default.post(name: .didSaveExerciseList, object: nil)
        }
    }
    
}

extension Notification.Name {
    static let didSaveExerciseList = Notification.Name("ExerciseDataStoreDidSaveExerciseList")
}

extension Array {
    mutating func replace(at index: Int, with e: Element) {
        remove(at: index)
        insert(e, at: index)
    }
}
