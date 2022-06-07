//
//  MapViewController.swift
//  VilloMap
//
//  Created by Huei Li Yap on 04/06/2022.
//

import CoreLocation
import MapKit
import UIKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var villoData:VilloDataStruct?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var villoMap: [VilloMap] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        getDataFromWebservice()
    }
    
    // Code heavily inspired by course material "hondentoiletten" made by Johan Van Den Broek
    func getDataFromWebservice() -> Void {
        let url = URL(string: "https://data.mobility.brussels/geoserver/bm_bike/wfs?service=wfs&version=1.1.0&request=GetFeature&typeName=bm_bike:villo&outputFormat=json&srsName=EPSG:4326")!
        let task = URLSession.shared.dataTask(with: url) {
        (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if let jsonData = data
            {
                do {
                    self.villoData = try JSONDecoder().decode(VilloDataStruct.self, from: jsonData)
                } catch {
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                self.addAnnotations()
                self.persistData()
                self.fetchLocalData()
                print(self.villoMap.count)
            }
        }
        task.resume()
    }
    
    func persistData() -> Void {
        
        for bicycle in self.villoData!.features{
            let villoMap = VilloMap(context: context) // Link VilloMap data model & Context
            
            villoMap.latitude = bicycle.geometry.coordinates[1]
            villoMap.longitude = bicycle.geometry.coordinates[0]
            villoMap.lastWebUpdate = self.villoData!.timeStamp
            villoMap.lastLocalUpdate = Date()
            villoMap.municipality = bicycle.properties.mu_nl
            villoMap.street = bicycle.properties.address_nl
            villoMap.status = bicycle.properties.status
            
            // Save the data to coredata
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func fetchLocalData() {
        do {
            villoMap = try context.fetch(VilloMap.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }

    func addAnnotations() -> Void {
        var annotations = [MKAnnotation]()

        for bicycle in self.villoData!.features {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = bicycle.geometry.coordinates[1]
            annotation.coordinate.longitude = bicycle.geometry.coordinates[0]
            annotation.title = bicycle.properties.mu_nl
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
    }
    
    
    // show user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(region, animated: true)
    }
    

}

