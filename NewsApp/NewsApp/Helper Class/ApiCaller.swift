//
//  ApiCaller.swift
//  NewsApp
//
//  Created by Admin on 16/1/23.
//

import Foundation

class ApiCaller {
    static let shared = ApiCaller()
    private init() {}
    
    func getDataFromAPI(category: String?, completion: @escaping ([Article]?)->Void) {
        var result: NewsModel!
        var tailURL = ""
        if let category = category {
            if category == "All" {
                tailURL = ""
            }
            else {
                tailURL = "&category=\(category)"
            }
        }
        guard let url = URL(string: Constants.apiLink+tailURL) else {
            return
        }
        
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                guard let data = data else { return }
                do {
                    result = try JSONDecoder().decode(NewsModel.self, from: data)
                    completion(result.articles)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        session.resume()
    }
}
