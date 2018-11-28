//
//  ResultList.swift
//  com.equipe-6.name
//
//  Created by Victor Timsit on 23/11/2018.
//  Copyright © 2018 Victor Timsit. All rights reserved.
//

import UIKit

class ResultList: UIViewController {
    
    @IBOutlet weak var destinationAdress: UILabel!
    
    var placeID = ""
    var placeDetails:[Dictionary<String, AnyObject>] = Array()
    
    var coordinateLatitude: Double?
    var coordinateLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        destinationAdress.text = placeID
        
        searchLocationFromGoogle()

        // Do any additional setup after loading the view.
    }
    
    func searchLocationFromGoogle() {
        var strGoogleApi = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=AIzaSyCwaprHsKUC-l-Tnca98j378Mu6xdAxYUs"
        
        strGoogleApi = strGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: strGoogleApi)!)
        
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if error == nil {
                
                if let responseData = data {

                    let jsonDict = try? JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)

                    if let dict = jsonDict as? Dictionary<String, AnyObject>{
                        print(dict["result"]?["geometry"])
                        if let result = dict["result"] as? [Dictionary<String, AnyObject>] {
//                            self.placeDetails.removeAll()
                            
//                            if let geometry = result["geometry"] as? [Dictionary<String, AnyObject>] {
//                                if let location = result["location"] as? [Dictionary<String, AnyObject>] {
//                                    if let latitude = location["latitude"] as? Double {
//                                        coordinateLatitude = latitude
//                                    }
//                                    if let longitude = location["longitude"] as? Double {
//                                        coordinateLongitude = longitude
//                                    }
//                                }
//                            }
//                            print(coordinateLatitude)
//                            print(coordinateLongitude)
//                            for dictionary in predictions {
//                                self.placeDetails.append(dictionary)
//                            }
                            
                            DispatchQueue.main.async {
//                                    self.tablePlaces.reloadData()
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
