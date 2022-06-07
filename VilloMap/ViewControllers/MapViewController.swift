//
//  MapViewController.swift
//  VilloMap
//
//  Created by Huei Li Yap on 04/06/2022.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var villoData:VilloDataStruct?
    
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
                    //self.translateData(responseData: jsonData)
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                self.addAnnotations()
            }
        }
        task.resume()
    }
    
    func translateData(responseData:Data)
    {
        //let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject]
        //print(json)
        
        
        //let villoData = try! JSONDecoder().decode(VilloDataStruct.self, from: responseData)
        
        //print(villoData.features[0].properties.status)
        
        
        //let list = json!["features"] as! [AnyObject]
        //let bbox = list.forEach{print($0)}
        //let bbox = list[0]
        //print(bbox)
        /*let today = Date()
        var date1 = Date()
        var dayCounter = 0
     
        var newDay = false
        var iconURLS = [String]()
        for counter in 0...list.count-1{
            let items = list[counter] as! [String: AnyObject]
            var date2 = Date()
            
            if  let timeResult = (items["dt"] as? Double) {
                date2 = Date(timeIntervalSince1970: timeResult)
            }
            
            
            if Calendar.current.compare(date1, to: date2, toGranularity: .day) != ComparisonResult.orderedSame {
                if (newDay){
                    dayCounter += 1
                }
                newDay = true
            }
            if dayCounter == 3 {
                return
            }
            if Calendar.current.compare(today, to: date2, toGranularity: .day) != ComparisonResult.orderedSame
            {
                let main = items["main"] as! [String: AnyObject]
                
                let temp = main["temp"] as! Double
                let tempMin = main["temp_min"] as! Double
                let tempMax = main["temp_max"] as! Double
                let weatherArray = items["weather"] as! [AnyObject]
                let weather = weatherArray[0] as! [String: AnyObject]
                let icon = weather["icon"] as! String
                let iconURL = URL(string: "http://openweathermap.org/img/w/\(icon).png")
                if !iconURLS.contains(icon) {
                    WeatherInfoSingleton.shared.downloadImage(url: URL(string: iconURL!.absoluteString)!)
                }
               iconURLS.append(icon)
                WeatherInfoSingleton.shared.weatherInfos.append([WeatherInfo]())
                WeatherInfoSingleton.shared.weatherInfos[dayCounter].append(WeatherInfo(date: date2, temp: temp, tempMin: tempMin, tempMax: tempMax, icon: iconURL!.absoluteString))
                
            }
            
           
            
            date1 = date2
        }*/
        
    }

    func addAnnotations() -> Void {
        var annotations = [MKAnnotation]()

        for bicycle in self.villoData!.features
        {
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

