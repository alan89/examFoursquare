//
//  DETAILViewController.swift
//  IronbitExam
//
//  Created by Alan Escobar Martínez on 1/22/17.
//  Copyright © 2017 Alan Escobar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var checkinLabel: UILabel!
    @IBOutlet weak var usersLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var addressValue = ""
    var isFav = false
    var currentVenue = Venue.venueRaw("", name: "", latitude: 0.0, longitude: 0.0, address: "", categoryName: "", categoryUrl: "", checkIns: 0, usersCount: 0, tipsCount: 0, distance: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = currentVenue!.name
        getIsFav()
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let venueLocation = CLLocationCoordinate2D(latitude: currentVenue!.location.latitude, longitude: currentVenue!.location.longitude)
        let region = MKCoordinateRegionMake(venueLocation,span)
        let annotation = MKPointAnnotation()
        annotation.title = currentVenue!.name
        annotation.coordinate = venueLocation
        
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        
        map.addAnnotation(annotation)
        
        addressValue = (currentVenue?.address)!
        
        addressLabel.text = addressValue
        labelCategory.text = currentVenue!.category.name
        if currentVenue!.distance == 0{
            distanceLabel.text = " "
        }
        else{
            distanceLabel.text = "\(currentVenue!.distance) metros"
        }
        checkinLabel.text = "\(currentVenue!.checkIns!)"
        usersLabel.text = "\(currentVenue!.usersCount!)"
        tipsLabel.text = "\(currentVenue!.tipsCount!)"
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let imageSelected = isFav ? #imageLiteral(resourceName: "fav_on") : #imageLiteral(resourceName: "fav_off")
        let rightButtonItem = UIBarButtonItem.init(image: imageSelected, style: .plain, target: self, action: #selector(setFav))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        if (currentVenue?.category.icon! != "") {
            let imageUrl:URL = URL(string: (self.currentVenue?.category.icon)!)!
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData:NSData = NSData(contentsOf: imageUrl){
                    // When from background thread, UI needs to be updated on main_queue
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self.icon.image = image
                        self.icon.tintColor = UIColor.blue
                        self.icon.contentMode = UIViewContentMode.scaleAspectFit
                    }
                }
            }
        }
    }
    
    func setFav(){
        print("click button")
        if self.navigationItem.rightBarButtonItem?.image == #imageLiteral(resourceName: "fav_on"){
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "fav_off")
            deleteFav();
        }
        else{
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "fav_on")
            save(name: (currentVenue?.name)!, latitude: (currentVenue?.location.latitude)!, longitude: (currentVenue?.location.longitude)!, formattedAddress: addressValue, categoryName: (currentVenue?.category.name)!, icon: (currentVenue?.category.icon)!, checkinsCount: (currentVenue?.checkIns)!, usersCount: (currentVenue?.usersCount)!, tipsCount: (currentVenue?.tipsCount)!, id: (currentVenue?.id)!)
        }
        
    }
    
    func getIsFav(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<FavVenues> = FavVenues.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", (currentVenue?.id)!)
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0{
                isFav = true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFav(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<FavVenues> = FavVenues.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", (currentVenue?.id)!)
        do {
            let results = try managedContext.fetch(request)
            for object in results {
                managedContext.delete(object)
            }
            do{
                try managedContext.save()
            }
            catch{}
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save(name: String,latitude: Double,longitude: Double, formattedAddress: String,categoryName: String, icon: String,checkinsCount: Int,usersCount: Int,tipsCount: Int, id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entityVenues = NSEntityDescription.entity(forEntityName: "FavVenues", in: managedContext)!
        let venue = NSManagedObject(entity: entityVenues, insertInto: managedContext)
        
        venue.setValue(name, forKeyPath: "name")
        venue.setValue(latitude, forKeyPath: "latitude")
        venue.setValue(longitude, forKeyPath: "longitude")
        venue.setValue(categoryName, forKeyPath: "categoryName")
        venue.setValue(icon, forKeyPath: "icon")
        venue.setValue(checkinsCount, forKeyPath: "checkinsCount")
        venue.setValue(tipsCount, forKeyPath: "tipsCount")
        venue.setValue(usersCount, forKeyPath: "usersCount")
        venue.setValue(id, forKeyPath: "id")
        venue.setValue(formattedAddress, forKeyPath: "formattedAddress")
        
        do {
            try managedContext.save()
            print("Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
