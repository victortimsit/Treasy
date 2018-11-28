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

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tablePlaces: UITableView!
    
    var locationManager = CLLocationManager()
    var destinationAdress = ""
    var resultsArray:[Dictionary<String, AnyObject>] = Array()
    
    
//    @IBAction func closeKeyboard(sender: MKMapView) {
//        if whereTextField.isFirstResponder == true {
//            whereTextField.resignFirstResponder()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        destinationTextField.addTarget(self, action: #selector(searchPlaceFromGoogle(_:)), for: .editingChanged)
        
        
        destinationTextField.delegate = self
        
        tablePlaces.estimatedRowHeight = 44.0
        tablePlaces.dataSource = self
        tablePlaces.delegate = self
        
        tablePlaces?.backgroundColor = UIColor(white: 1, alpha: 0)
        
        
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
//            let coordinate: CLLocationCoordinate2D
            print(locationManager)
            
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
    
    //MARK:- UITableViewDataSource and UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell")
        
        if let labelPlaceName = cell?.contentView.viewWithTag(102) as? UILabel {
            
            let place = self.resultsArray[indexPath.row]
            labelPlaceName.text = "\(place["description"] as! String)"
//            print("place : \(place)")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Init push
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultListController = storyBoard.instantiateViewController(withIdentifier: "result") as! ResultList
        
        //Send destinationAdress in resultListController
        
        if let description = self.resultsArray[indexPath.row]["description"] as? String {
            destinationTextField.text = description
        }
        if let placeID = self.resultsArray[indexPath.row]["place_id"] as? String {
            resultListController.placeID = placeID
    
        }
        
        self.navigationController?.pushViewController(resultListController, animated: true)
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tablePlaces?.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //Stack input text in variable
        if let n = destinationTextField.text {
            destinationAdress = n
        }

        //Init push
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultListController = storyBoard.instantiateViewController(withIdentifier: "result") as! ResultList

        //Send destinationAdress in resultListController
//        resultListController.adress = destinationAdress
        
        self.navigationController?.pushViewController(resultListController, animated: true)

        return true
    }
    
    @objc func searchPlaceFromGoogle(_ textField:UITextField) {
        if let place = textField.text {
            var strGoogleApi = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(place)&location=48.8667,2.4333&radius=1&key=AIzaSyCwaprHsKUC-l-Tnca98j378Mu6xdAxYUs"
            
            strGoogleApi = strGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            var urlRequest = URLRequest(url: URL(string: strGoogleApi)!)
            
            urlRequest.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: urlRequest) {
                (data, response, error) in
                
                if error == nil {
                    
                    if let responseData = data {
                        //                    print("response DATA : \(responseData)")
        
                        //                    let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)
//                        print("response JSONDICT : \(jsonDict)")
                        
                        if let dict = jsonDict as? Dictionary<String, AnyObject>{
                            
                            if let predictions = dict["predictions"] as? [Dictionary<String, AnyObject>] {
                                //                             print("json == \(results)")
                                self.resultsArray.removeAll()
                                for dictionary in predictions {
                                    self.resultsArray.append(dictionary)
                                }
                                
                                DispatchQueue.main.async {
                                    self.tablePlaces.reloadData()
                                }
                            }
                        }
                    }
                    
                } else {
                    print("error connecting google API")
                }
            }
            task.resume()
        }
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
