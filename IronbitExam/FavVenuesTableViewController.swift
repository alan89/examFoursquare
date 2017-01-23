//
//  FavVenuesTableViewController.swift
//  IronbitExam
//
//  Created by Alan Escobar Martínez on 1/22/17.
//  Copyright © 2017 Alan Escobar. All rights reserved.
//

import UIKit
import CoreData

class FavVenuesTableViewController: UITableViewController {
    
    var venuesFavArray: [Venue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Guardados"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        venuesFavArray = []
        getDataFromCoreData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesFavArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFavs", for: indexPath)
        cell.textLabel?.text = venuesFavArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(venuesFavArray[indexPath.row].name!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailFav" ,
            let nextScene = segue.destination as? DetailViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedVenue = venuesFavArray[indexPath.row]
            let backItem = UIBarButtonItem()
            backItem.title = " "
            navigationItem.backBarButtonItem = backItem
            nextScene.currentVenue = selectedVenue
        }
    }
    
    // MARK: - Getting Data
    
    func getDataFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<FavVenues> = FavVenues.fetchRequest()
        do {
            let results = try managedContext.fetch(request)
            for ev in results{
                print(ev.value(forKeyPath: "name")!)
                let text = ev.value(forKeyPath: "formattedAddress")! as! String
                let currentVenue = Venue(name: ev.value(forKeyPath: "name")! as! String, latitude: ev.value(forKeyPath: "latitude")! as! Double, longitude: ev.value(forKeyPath: "longitude")! as! Double, formattedAddress: [text], distance: 0, categoryName: ev.value(forKeyPath: "categoryName")! as! String, icon: ev.value(forKeyPath: "icon") as! String, checkinsCount: ev.value(forKeyPath: "checkinsCount")! as! Int, usersCount: ev.value(forKeyPath: "usersCount")! as! Int, tipCount: ev.value(forKeyPath: "tipsCount")! as! Int, id: ev.value(forKeyPath: "id")! as! String)
                venuesFavArray.append(currentVenue!)
            }
            DispatchQueue.main.async(execute: {self.doTableRefresh()})
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func doTableRefresh(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            return
        }
    }

}
