//
//  DataManager.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/24/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

struct Notifications {
    static let FavoritesDidChangeNotification = "FavoritesDidChangeNotification"
}

class DataManager {
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
    let fileName = "Favorites.plist"
    var filePath: String {
        get {
            return documentsDirectory.stringByAppendingPathComponent(fileName)
        }
    }
    var favorites: [BasicInfo]?

    init() {
        loadFavorites()
    }
    
    class func sharedManager() -> DataManager {
        struct Static { static let instance: DataManager = DataManager() }
        return Static.instance
    }

    private func loadFavorites() -> [BasicInfo]? {
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            var data = NSData(contentsOfFile:filePath)
            if let data = data {
                self.favorites = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [BasicInfo]?
                return self.favorites
            }
        }
        return nil
    }
    
    private func saveFavorites(items: [BasicInfo]) {
        var data = NSKeyedArchiver.archivedDataWithRootObject(items)
        data.writeToFile(filePath, atomically: true)
        self.favorites = items
    }
    
    // MARK: -
    
    func isFavorite(item: BasicInfo) -> Bool {
        var favoriteItem = self.favorites?.filter({ $0.identifier == item.identifier }).first
        if favoriteItem != nil {
            return true
        }
        return false
    }
    
    func addToFavorites(item: BasicInfo) {
        var items = [BasicInfo]()
        if let favorites = loadFavorites() {
            items += favorites
        }
        items.append(item)
        saveFavorites(items)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.FavoritesDidChangeNotification, object: nil)
    }
    
    func removeFromFavorites(item: BasicInfo) {
        var items = loadFavorites()
            if var items = items {
            var favoriteItem = items.filter({ $0.identifier == item.identifier }).first
            if let favoriteItem = favoriteItem {
                var idx = find(items, favoriteItem)
                items.removeAtIndex(idx!)
                saveFavorites(items)

                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.FavoritesDidChangeNotification, object: nil)
            }
        }
    }
}

    