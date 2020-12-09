//
//  WeatherManager.swift
//  Clima
//
//  Created by abdullah irianda on 23/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{  
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b0f3f59c82babf2a733ee122fae20dfd&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    // Networking
    func performRequest(urlString: String){
        // 1. create URL
        if let url = URL(string: urlString){
            // 2. create URL Sesision
            let session = URLSession(configuration: .default)
            // 3. give task for session
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{ // jika ada error
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            }
            
            // 4. start task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(condition: id, cityName: name, temperature: temp)
            return weather
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}









