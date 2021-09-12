//
//  Exercise.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import Foundation


/// Imutable exercise objects used throughout the app
struct Exercise: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let imageUrl: URL
    let videoUrl: URL?
    let isFavorite: Bool
    
    init(id: Int,
         name: String,
         imageUrl: URL,
         videoUrl: URL?,
         isFavorite: Bool) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.isFavorite = isFavorite
    }
    
    static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
}
