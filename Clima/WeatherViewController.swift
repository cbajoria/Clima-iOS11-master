//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate {
  
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "bc091ee3b5da90d789a5c47b61ab73bd"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String , param : [String:String])
    {
        Alamofire.request(url, method: .get, parameters: param).responseJSON { (response) in
            if(response.result.isSuccess)
            {
                var result : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: result)
            }else
            {
                
                print(response.result.error)
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON)
    {
        if let temp = json["main"]["temp"].double{
            weatherDataModel.temperature = Int(temp - 273.15)  // Convereted in Celcius
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition =  json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }else
        {
            self.cityLabel.text = "Weather Unavailable"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        locationManager.delegate = nil
        if location.horizontalAccuracy>0
        {
            locationManager.stopUpdatingLocation()
            let latitude =  location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let param : [ String : String] = ["lat" : String(latitude) ,"lon" : String(longitude),"appId":APP_ID]
            getWeatherData(url: WEATHER_URL, param : param)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let param : [String : String] = ["q" : city,"appId": APP_ID]
        getWeatherData(url: WEATHER_URL, param: param)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChangeCityViewController
        destination.delegate = self
    }
    
    
    
    
}


