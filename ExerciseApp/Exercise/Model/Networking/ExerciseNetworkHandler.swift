//
//  ExerciseNetworkHandler.swift
//  ExerciseApp
//
//  Created by Travis Mozden on 9/11/21.
//

import Foundation

protocol ExerciseNetworkDelegate: AnyObject {
    func didReceive(exerciseList list: [Exercise])
    func didReceive(error: ExerciseNetworkError)
    func didReceive(imageData: Data, for exercise: Exercise)
}

/// This class handles all network related work for the Exercise subsystem.
/// Including sending/receiving requests, handling errors, encoding/decoding objects.
class ExerciseNetworkhandler {
    private static let listUrl = URL(string: "https://jsonblob.com/api/jsonBlob/027787de-c76e-11eb-ae0a-39a1b8479ec2")!
    let urlSession = URLSession(configuration: .default)
    let decoder: JSONDecoder = JSONDecoder()
    
    weak var delegate: ExerciseNetworkDelegate?
    
    init() {
        
    }
    
    func requestExerciseList() {
        let exerciseListRequest = urlSession.dataTask(with: ExerciseNetworkhandler.listUrl) { [weak self] data, response, error in
            if let _ = error {
                //log error using logging system
                self?.delegate?.didReceive(error: .exerciseListRequestFailed)
            } else if let response = response as? HTTPURLResponse {
                //validate response
                guard response.statusCode == 200 else {
                    //log status error in logging system
                    self?.delegate?.didReceive(error: .exerciseListRequestFailed)
                    return
                }
                guard let data = data else {
                    //log that something went wrong and we received no data and also no error
                    self?.delegate?.didReceive(error: .exerciseListRequestFailed)
                    return
                }
                self?.process(exerciseListData: data)
                
            } else {
                //I dont think this case should ever be hit but log if it is
                //Log that we received a response with no valid response and no error
                self?.delegate?.didReceive(error: .exerciseListRequestFailed)
            }
        }
        
        //Send request
        exerciseListRequest.resume()
    }
    
    func requestImage(for exercise: Exercise) {
        let imageRequest = urlSession.dataTask(with: exercise.imageUrl) { [weak self] data, response, error in
            if let _ = error {
                //log error using logging system
                self?.delegate?.didReceive(error: .imageRequestFailed)
            } else if let response = response as? HTTPURLResponse {
                //validate response
                guard response.statusCode == 200 else {
                    //log status error in logging system
                    self?.delegate?.didReceive(error: .imageRequestFailed)
                    return
                }
                guard let data = data else {
                    //log that something went wrong and we received no data and also no error
                    self?.delegate?.didReceive(error: .imageRequestFailed)
                    return
                }
                self?.delegate?.didReceive(imageData: data, for: exercise)
                
            } else {
                //I dont think this case should ever be hit but log if it is
                //Log that we received a response with no valid response and no error
                self?.delegate?.didReceive(error: .imageRequestFailed)
            }
        }
        
        imageRequest.resume()
    }
    
    private func process(exerciseListData listData: Data) {
        do {
            let exercises = try decoder.decode([WebExercise].self, from: listData)
            let converted = exercises.compactMap { self.convert(webExercise: $0) }
            delegate?.didReceive(exerciseList: converted)
        } catch {
            //Log decoding error
            delegate?.didReceive(error: .exerciseListDecodingFailed)
        }
    }
    
    private func convert(webExercise exercise: WebExercise) -> Exercise? {
        //Validate image url
        guard let imageUrl = URL(string: exercise.cover_image_url) else {
            //log invalid url for this object
            return nil
        }
        var videoUrl: URL?
    
        //Validate video url if it is here
        if let videoUrlString = exercise.video_url {
            videoUrl = URL(string: videoUrlString)
        }
        
        //Check if we already know about this exercise if we do keep
        //its favorite status
        let isAlreadyFavorite = ExerciseManager.shared.isExerciseAFaviorite(exerciseId: exercise.id)
        let convertedExercise = Exercise(id: exercise.id,
                                         name: exercise.name,
                                         imageUrl: imageUrl,
                                         videoUrl: videoUrl,
                                         isFavorite: isAlreadyFavorite)
        
        //Check to see if we already have the image downloaded or if we should
        //kick off an image download.
        if let localExercise = ExerciseManager.shared.getExercise(for: exercise.id),
           localExercise.imageUrl == convertedExercise.imageUrl,
           ExerciseManager.shared.getImageData(for: convertedExercise) != nil {
            //We already have a local image downloaded that is from the same URL
            //I am assuming here that if there was a change in image for a given
            //exercise it would come from a different url. It is possible we would
            //want to use some other mechanism for indicating an image change an
            //keep the URL constant.
        } else {
            //We dont have a local copy already so kick off an image request.
            requestImage(for: convertedExercise)
        }
        
        return convertedExercise
    }
}

enum ExerciseNetworkError: Error {
    case exerciseListRequestFailed
    case exerciseListDecodingFailed
    case failedToConvertWebExerciseToExercise
    case imageRequestFailed
}
