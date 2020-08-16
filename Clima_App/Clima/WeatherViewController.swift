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

class WeatherViewController: UIViewController,CLLocationManagerDelegate,changeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "3d7ddb3f0ec18f1a087d9c44da2db49c"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    var locationManager=CLLocationManager()
    var weatherData=WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String:String])
    {
        Alamofire.request(url,method: .get,parameters: parameters).responseJSON
            {
                response in
                if(response.result.isSuccess)
                {
                    let weatherData : JSON=JSON(response.result.value!)
                    self.updateWeatherData(json: weatherData)
                }
                else{
                    print("Error")
                    self.cityLabel.text="Connection Problem"
                }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON)
    {
        if let temp=json["main"]["temp"].double
        {
            weatherData.temperature=Int(temp-273.15)
            weatherData.city=json["name"].stringValue
            weatherData.condition=json["weather"][0]["id"].intValue
            weatherData.weatherIconName=weatherData.updateWeatherIcon(condition: weatherData.condition)
            updateUIWithWeatherData()
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData()
    {
        weatherIcon.image=UIImage(named: weatherData.weatherIconName)
        cityLabel.text=weatherData.city
        temperatureLabel.text="\(weatherData.temperature)"
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location=locations[locations.count-1]
        if(location.horizontalAccuracy>0)
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
        }
        var latitude=String(location.coordinate.latitude)
        var longitude=String(location.coordinate.longitude)
        var params : [String : String]=["lat" : latitude,"lon" : longitude,"appid" : APP_ID]
        getWeatherData(url : WEATHER_URL,parameters : params)
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String : String]=["q" : city,"appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="changeCityName"
        {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate=self
        }
    }
    
    
    
    
}


