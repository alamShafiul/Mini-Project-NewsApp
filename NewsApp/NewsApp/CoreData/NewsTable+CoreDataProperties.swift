//
//  NewsTable+CoreDataProperties.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//
//

import Foundation
import CoreData


extension NewsTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsTable> {
        return NSFetchRequest<NewsTable>(entityName: "NewsTable")
    }

    @NSManaged public var title: String?
    @NSManaged public var time: String?
    @NSManaged public var imgURL: String?
    @NSManaged public var url: String?
    @NSManaged public var author: String?
    @NSManaged public var desc: String?
    @NSManaged public var content: String?
    @NSManaged public var category: String?

}

extension NewsTable : Identifiable {

}
