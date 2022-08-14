//
//  APIManager.swift
//  weatherProject
//
//  Created by 이병현 on 2022/08/14.
//

import Foundation

import Alamofire
import SwiftyJSON

class APIManager {
    
    static let shared = APIManager()
    
    private init() {}
    
    //MARK: - Main 네트워크 통신
    func fetchWeather(lat: Double, lon: Double, completionHandler: @escaping (JSON) -> ()) {
        let url = "\(EndPoint.WeatherURL)lat=\(lat)&lon=\(lon)&appid=\(APIKey.WeatherKey)"
        AF.request(url, method: .get).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                completionHandler(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
