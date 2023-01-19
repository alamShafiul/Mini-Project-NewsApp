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
    var bookmarks = [BookmarkTable]()
    var searchBookmarks = [BookmarkTable]()
    let context = AppDelegate.shared.persistentContainer.viewContext
    
    func getData(category: String?, searchText: String) {
        do {
            let request = NSFetchRequest<NewsTable>(entityName: "NewsTable")
            if let category = category {
                let predicate = NSPredicate(format: "category == %@ AND title CONTAINS %@", category, searchText)
                request.predicate = predicate
            }
            newses = try context.fetch(request)
        }
        catch {
            print(error)
        }
    }
    
//    func getData(offset: Int, category: String?, searchText: String) {
//        do {
//            let request = NSFetchRequest<NewsTable>(entityName: "NewsTable")
//            request.fetchLimit = 5
//            request.fetchOffset = offset
//            if let category = category {
//                let predicate = NSPredicate(format: "category == %@ AND title CONTAINS %@", category, searchText)
//                request.predicate = predicate
//            }
//            newses = try context.fetch(request)
//        }
//        catch {
//            print(error)
//        }
//    }

    
    func getFromBookmark(newsUrl: String?) {
        do {
            let request = NSFetchRequest<BookmarkTable>(entityName: "BookmarkTable")
            if let newsUrl = newsUrl {
                let predicate = NSPredicate(format: "url == %@", newsUrl)
                request.predicate = predicate
            }
            bookmarks = try context.fetch(request)
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
        newRow.bookmarkTick = newsModel.bookmarkTick
        
        do {
            try context.save()
            newses.append(newRow)
        }
        catch {
            print(error)
        }
    }
    
    func addToBookTable(newsModel: NewsesMODEL) {
        let newRow = BookmarkTable(context: context)
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
            bookmarks.append(newRow)
        }
        catch {
            print(error)
        }
    }
    
    func updateData(indexPath: IndexPath, flag: Bool) {
        newses[indexPath.row].bookmarkTick = flag
        do{
            try context.save()
        }
        catch {
            print(error)
        }
    }
    
    func deleteData(category: String) {
        for news in newses {
            if(news.category == category) {
                context.delete(news)
            }
        }
        
        do{
            try context.save()
        }
        catch {
            print(error)
        }
    }
    
    func deleteFromBookmark(indexPath: IndexPath, from: String) {
        if(from == "BookmarkVC") {
            let findURL = bookmarks[indexPath.row].url
            for item in newses {
                if(item.url == findURL) {
                    item.bookmarkTick = false
                    context.delete(bookmarks[indexPath.row])
                    break
                }
            }
        }
        else {
            let findURL = newses[indexPath.row].url
            newses[indexPath.row].bookmarkTick = false
            for item in bookmarks {
                if(item.url == findURL) {
                    context.delete(item)
                    break
                }
            }
        }
        do{
            try context.save()
            bookmarks.remove(at: indexPath.row)
        }
        catch {
            print(error)
        }
    }
}
