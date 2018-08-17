//
//  ViewController.swift
//  elements
//
//  Created by Gabe Zimbric on 8/16/18.
//  Copyright © 2018 Gabe Zimbric. All rights reserved.
//

import UIKit
import ForecastIO
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Large Navbar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //
        let locManager = CLLocationManager()
        var currentLocation: CLLocation!
        let geoCoder = CLGeocoder()
        let tempSymbol = "°"
        // Request for location
        locManager.requestWhenInUseAuthorization()
        // Get location (lat/long)
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
        }
        // Grab lat/long to find city
        let location = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        // Get weather data from Dark Sky using ForecastIO
        let client = DarkSkyClient(apiKey: "lol")
        client.units = .auto
        client.language = .english
        client.getForecast(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, excludeFields: [.alerts, .daily, .flags, .minutely]) { result in
            switch result {
            case .success(let forecast, let requestMetadata):
                let temp = round(forecast.currently!.temperature!)
                let infoText = forecast.currently!.summary!
                // Find city based off of lat/long
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    if let city = placeMark.locality {
                        // Setup view
                        DispatchQueue.main.async(execute: {
                            self.navigationController?.navigationBar.topItem?.title = String(temp.cleanValue) + tempSymbol + " " + city
                            self.weatherIcon.image = UIImage(named: forecast.currently!.icon!.rawValue)
                            self.weatherLabel.text = forecast.hourly!.summary!
                            self.iconLabel.text = infoText.uppercased()
                        })
                        // Console logging
                        print(city)
                    }
                })
                // More console logging
                print(forecast.currently!.temperature!)
                print(forecast.currently!.icon!)
                print(forecast.hourly!.summary!)
                print(requestMetadata)
            case .failure(let error):
                print(error)
            }
        }
    }
}
// Round temp and get rid of decimal
extension Double {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
