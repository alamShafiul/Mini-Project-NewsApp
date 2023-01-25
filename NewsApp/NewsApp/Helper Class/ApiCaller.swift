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
    
    func getDataFromAPI(category: String?, completion: @escaping ([NewsesMODEL]?)->Void) {
        var result: NewsModel!
        var tailURL = ""
        if let getCategory = category {
            if getCategory == "All" {
                tailURL = ""
            }
            else {
                tailURL = "&category=\(getCategory)"
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
                    var tempArray: [NewsesMODEL] = []
                    for item in result.articles {
                        if let title = item.title, let time = item.publishedAt, let imgURL = item.urlToImage, let url = item.url, let author = item.author, let desc = item.description, let content = item.content {
                            let tempItem = NewsesMODEL(title: title, time: time, imgURL: imgURL, URL: url, author: author, desc: desc, content: content, category: category!, bookmarkTick: false)
                            tempArray.append(tempItem)
                        }
                    }
                    completion(tempArray)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        session.resume()
    }
}
