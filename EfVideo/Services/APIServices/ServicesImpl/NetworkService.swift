//
//  NetworkService.swift
//  EfVideo
//
//  Created by user on 19.07.2023.
//

import Foundation
import RxSwift
 
class NetworkService: NetworkServiceProtocol {
    
    init() {
    }
    
    func getListVideoMock(completionHandler: @escaping (Result<ListModel, Error>) -> Void) {
        
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
    
    func getListVideo<T: Codable>(url: URL) -> Observable<T> {
        return Observable.create { observer -> Disposable in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("83mNiekF3DmxfAHegwchaQynJkgckTMMQoXNmxs4PUxIEjDAgaqy8KWl", forHTTPHeaderField: "Authorization")
    
            let task = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
                guard let data = data, let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                    return
                }
                
                observer.onNext(decoded)
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

