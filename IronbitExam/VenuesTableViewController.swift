//
//  FruitTableViewController.swift
//  IronbitExam
//
//  Created by Alan Escobar Martínez on 1/17/17.
//  Copyright © 2017 Alan Escobar. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import CoreLocation

class VenuesTableViewController: UITableViewController, CLLocationManagerDelegate  {
    
    //var TableData:Array< String > = Array < String >()
    let manager = CLLocationManager()
    var venuesArray: [Venue] = []
    var currentLatitude = 0.0
    var currentLongitude = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.requestWhenInUseAuthorization()
        print("status: \(CLLocationManager.authorizationStatus())")
        
        if (CLLocationManager.locationServicesEnabled()){
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        cell.textLabel?.text = venuesArray[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(venuesArray[indexPath.row].name!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" ,
            let nextScene = segue.destination as? DetailViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedVenue = venuesArray[indexPath.row]
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
            nextScene.currentVenue = selectedVenue
        }
        else if segue.identifier == "showFavs"{
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    // MARK: - Getting Data
    
    func getDataFromUrl(_ link:String){
        let url:URL = URL(string: link)!
        Alamofire.request(url, method: .get)
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success:
                    if let JSON = response.result.value{
                        self.extractJson(JSON)
                    }
                case .failure(let error):
                    print(error)
                }
                
        }
    }
    
    func extractJson(_ data: Any){
        if let dictionary = data as? [String:Any]{
            if let response = dictionary["response"] as? [String:Any]{
                if let venues = response["venues"] as? [Any]{
                    for i in 0..<venues.count {
                        if let venueObj = venues[i] as? [String:Any]{
                            if let nameVenue = venueObj["name"] as? String{
                                let idVenue = venueObj["id"]
                                if let locationVenue = venueObj["location"] as? [String: Any]{
                                    let latitude = locationVenue["lat"] as? Double
                                    let longitude = locationVenue["lng"] as? Double
                                    let distance = locationVenue["distance"] as? Int
                                    let formattedAddress = locationVenue["formattedAddress"]
                                    if let statsVenue = venueObj["stats"] as? [String: Int]{
                                        let checkinsCount = statsVenue["checkinsCount"]
                                        let usersCount = statsVenue["usersCount"]
                                        let tipCount = statsVenue["tipCount"]
                                        if let categoryInfo = venueObj["categories"] as? [Any]{
                                            let categoryObj = categoryInfo[0] as? [String: Any]
                                            if let categoryName = categoryObj?["name"] as? String{
                                                if let categoryIcon = categoryObj?["icon"] as? [String: String]{
                                                    let iconUrl = categoryIcon["prefix"]! + "64" + categoryIcon["suffix"]!
                                                    let currentVenue = Venue(name: nameVenue, latitude: latitude!, longitude: longitude!, formattedAddress: formattedAddress as! [String], distance: distance!, categoryName: categoryName, icon: iconUrl, checkinsCount: checkinsCount!, usersCount: usersCount!, tipCount: tipCount!, id: idVenue as! String)
                                                    venuesArray.append(currentVenue!)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        DispatchQueue.main.async(execute: {self.doTableRefresh()})
        for j in  0..<venuesArray.count{
            print(venuesArray[j].name!)
        }
    }
    
    func doTableRefresh(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print("Estas som las coordenadas actuales: Latitud \(location.coordinate.latitude) y longitud: \(location.coordinate.longitude)")
        if (currentLatitude != location.coordinate.latitude && currentLongitude != location.coordinate.longitude){
            manager.stopUpdatingLocation()
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            var url = "https://api.foursquare.com/v2/venues/search?ll="
            url += String(format: "%f", location.coordinate.latitude)
            url += ","
            url += String(format: "%f", location.coordinate.longitude)
            url += "&limit=50&locale=es&client_id=CKL03AM1QZC34AFAYMAGC2ZXJOI2T4XESGCAV1QZZSGBGM4X&client_secret=SJOG2OTK0SAXPTSDEMMRDG5IWP3KKW1KHT2OQ13M1BUGMK1B&v=20170117"
            getDataFromUrl(url)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error::: \(error)")
        manager.stopUpdatingLocation()
        let alert = UIAlertController(title: "Error", message: "Permite el acceso a tu ubicación desde settings", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Ir a preferencias", style: .default, handler: { action in
            switch action.style{
            case .default: UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:])
            case .cancel: print("cancel")
            case .destructive: print("destructive")
            }
        }))
    }
}
