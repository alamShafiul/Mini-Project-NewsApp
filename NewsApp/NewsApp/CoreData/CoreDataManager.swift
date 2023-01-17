//
//  CoreDataManager.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    var newses = [NewsTable]()
    let context = AppDelegate.shared.persistentContainer.viewContext
    
    func getData(category: String?) {
        do {
            let request = NSFetchRequest<NewsTable>(entityName: "NewsTable")
            if let category = category {
                let predicate = NSPredicate(format: "category == %@", category)
                request.predicate = predicate
            }
            newses = try context.fetch(request)
        }
        catch {
            print(error)
        }
    }
    
    func addData(newsModel: NewsesMODEL) {
        let newRow = NewsTable(context: context)
        newRow.title = newsModel.title
        newRow.time = newsModel.time
        newRow.imgURL = newsModel.imgURL
        newRow.url = newsModel.URL
        newRow.author = newsModel.author
        newRow.desc = newsModel.desc
        newRow.content = newsModel.content
        newRow.category = newsModel.category
        
        do {
            try context.save()
            newses.append(newRow)
        }
        catch {
            print(error)
        }
    }
    
    func updateData(newsModel: NewsesMODEL, indexPath: IndexPath) {
        let existedRow = newses[indexPath.row]
        existedRow.title = newsModel.title
        existedRow.time = newsModel.time
        existedRow.imgURL = newsModel.imgURL
        existedRow.url = newsModel.URL
        existedRow.author = newsModel.author
        existedRow.desc = newsModel.desc
        existedRow.content = newsModel.content
        existedRow.category = newsModel.category
        
        do{
            try context.save()
        }
        catch {
            print(error)
        }
    }
    
    func deleteData(indexPath: IndexPath) {
        let existedRow = newses[indexPath.row]
        context.delete(existedRow)
        
        do{
            try context.save()
            newses.remove(at: indexPath.row)
        }
        catch {
            print(error)
        }
    }
}
