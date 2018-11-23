//
//  MapViewController.swift
//  com.equipe-6.name
//
//  Created by Victor Timsit on 21/11/2018.
//  Copyright © 2018 Victor Timsit. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var destinationAdress = ""
    
    
//    @IBAction func closeKeyboard(sender: MKMapView) {
//        if whereTextField.isFirstResponder == true {
//            whereTextField.resignFirstResponder()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        destinationTextField.delegate = self
        
        
        
        
        
        // Geolocation
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
                
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK:- CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        self.mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
//        if let n = destinationTextField.text {
//            destinationAdress = n
//        }
//        print("endEdit")
//    }
    
    //MARK:- UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchPlaceFromGoogle(place: textField.text!)
        
        //Stack input text in variable
        if let n = destinationTextField.text {
            destinationAdress = n
        }

        //Init push
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultListController = storyBoard.instantiateViewController(withIdentifier: "result") as! ResultList

        //Send destinationAdress in resultListController
        resultListController.adress = destinationAdress
        
        self.navigationController?.pushViewController(resultListController, animated: true)

        return true
    }
    
    func searchPlaceFromGoogle(place: String) {
        var strGoogleApi = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(place)&key=AIzaSyCwaprHsKUC-l-Tnca98j378Mu6xdAxYUs"
        
        strGoogleApi = strGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: strGoogleApi)!)
        
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if error == nil {
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
                print("json == \(jsonDict)")
            } else {
                print("error connecting google API")
            }
        }
        task.resume()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
