//
//  ListApiImpl.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation
 
class ListApiImpl: ListApiProtocol {
    
    init() {
    }
    
    func getListVideo(completionHandler: @escaping (Result<ListModel, Error>) -> Void) {
        
        let data: Data
        let filename = "mock_file.json"
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            let rez = try decoder.decode(ListModel.self, from: data)
            completionHandler(.success(rez))
        } catch {
            fatalError("Couldn't parse \(filename) as \(ListModel.self):\n\(error)")
        }
    }
}
