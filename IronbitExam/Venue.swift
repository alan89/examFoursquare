//
//  venue.swift
//  IronbitExam
//
//  Created by Alan Escobar Martínez on 1/22/17.
//  Copyright © 2017 Alan Escobar. All rights reserved.
//
import Foundation
import CoreLocation

class Venue:NSObject{
    let id:String
    let name:String
    let location:CLLocationCoordinate2D
    let address:String
    let category:Category
    let checkIns:Int?
    let usersCount:Int?
    let tipsCount:Int?
    let distance:Int
    
    init(id:String,name:String, location:CLLocationCoordinate2D,address:String, category:Category,checkIns:Int,usersCount:Int,tipsCount:Int, distance:Int){
        self.id = id
        self.name = name
        self.location = location
        self.address = address
        self.category = category
        self.checkIns = checkIns
        self.usersCount = usersCount
        self.tipsCount = tipsCount
        self.distance = distance
    }
    class func venueFrom(_ dic:[String:Any])->Venue?{
        if  let name = dic["name"] as? String,
            let id = dic["id"] as? String,
            let locationDic = dic["location"] as? [String:Any], let long = locationDic["lng"] as? Double, let lat = locationDic["lat"] as? Double, let distance = locationDic["distance"] as? Int,
            let addressArray =  locationDic["formattedAddress"] as? [String],
            let categories = dic["categories"] as? [[String:Any]]{
            print(categories)
            if let stats = dic["stats"] as? [String:Int]{
                var checkins:Int = 0
                var users:Int = 0
                var tips:Int = 0
                var address = ""
                
                if let statsTips = stats["tipCount"] {
                    tips = statsTips
                }
                if let statsUsers = stats["usersCount"] {
                    users = statsUsers
                }
                if let statsCheckIns = stats["checkinsCount"] {
                    checkins = statsCheckIns
                }
                
                for element in addressArray{
                    address += element+"\n"
                }
                let venueLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                if categories.count > 0{
                    if let category = Category.categoryFrom(dic: categories[0]){
                        return Venue(id:id,name:name, location:venueLocation,address:address, category:category,checkIns:checkins,usersCount:users,tipsCount:tips, distance: distance)
                    }
                }
                else{
                    let categorySup = Category.categoryRaw(name: "Sin Categoría", url: "")
                    return Venue(id:id,name:name, location:venueLocation,address:address, category:categorySup!,checkIns:checkins,usersCount:users,tipsCount:tips, distance: distance)
                }
            }
        }
        return nil
    }
    class func venueRaw(_ id:String,name:String, latitude: Double, longitude: Double, address:String, categoryName: String, categoryUrl: String, checkIns:Int,usersCount:Int,tipsCount:Int, distance: Int)->Venue?{
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let catInfo = Category.categoryRaw(name: categoryName, url: categoryUrl)
        return Venue(id:id,name:name, location:coordinates,address:address, category:catInfo!, checkIns:checkIns, usersCount:usersCount,tipsCount:tipsCount, distance: distance)
    }
}

struct Category{
    let name:String
    let icon:String?
    
    init(name:String,icon:String?){
        self.name = name
        self.icon = icon
    }
    static func categoryFrom(dic:[String:Any])->Category?{
        if let name =  dic["name"] as? String,
            let iconDic = dic["icon"] as? [String:String]{
            var iconURL = ""
            if let prefix = iconDic["prefix"], let suffix = iconDic["suffix"]{
                iconURL = prefix + "64" + suffix
            }
            return Category(name:name,icon:iconURL)
        }
        return nil
    }
    static func categoryRaw(name: String, url: String)->Category?{
        return Category(name:name,icon:url)
    }
}
