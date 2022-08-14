//
//  ViewController.swift
//  weatherProject
//
//  Created by 이병현 on 2022/08/14.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import Kingfisher

import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var talkLabel: UILabel!
    
    
    var weatherDataList: [weatherData] = []
    
    //35.158695, 129.160370
    var coordLat: Double = 35.158695
    var coordLon: Double = 129.160370
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        fetchWheaterByAPIManager()
        layout()
        
    }
    
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            showRequestLocationServiceAlert()
        }
    
    func fetchWheaterByAPIManager() {
        APIManager.shared.fetchWeather(lat: coordLat, lon: coordLon) { [self] json in
            let weather = json["weather"].arrayValue
            let description = json["weather"][0]["description"].stringValue
            let icon = json["weather"][0]["icon"].stringValue
            let main = json["weather"][0]["main"].stringValue
            print("=====\(weather)====")
            let temp = json["main"]["temp"].doubleValue
            let feelingTemp = json["main"]["feels_like"].doubleValue
            let minTemp = json["main"]["temp_min"].doubleValue
            let maxTemp = json["main"]["temp_max"].doubleValue
            let wind = json["wind"]["speed"].doubleValue
            let humidity = json["main"]["humidity"].intValue
            print(wind)
            let region = json["name"].stringValue
            print(region)
            
            let data = weatherData(description: description, icon: icon, main: main, temp: temp, feelingTemp: feelingTemp, minTemp: minTemp, maxTemp: maxTemp, wind: wind, region: region, humidity: humidity)
            
            self.weatherDataList.append(data)
            print(self.weatherDataList)
            
            let nowDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let currentDate = dateFormatter.string(from: nowDate)
            
            dateLabel.text = (" 현재 시간 : \(currentDate) ")
            locationLabel.text = (" 현재 내 위치 : \(region) ")
            tempLabel.text = (" 오늘의 온도: \(String(Int(temp - 273.15))), 최고 온도: \(String(Int(maxTemp - 273.15))), 최저 온도: \(String(Int(minTemp - 273.15))) ")
            humidityLabel.text = (" 오늘의 습도는 \(String(humidity))입니다. ")
            windLabel.text = (" 오늘의 풍속은 \(String(wind))입니다. ")
            talkLabel.text = " 오늘 날씨 : \(description)입니다. "
            
            let url = URL(string: "\(EndPoint.imageURL)\(icon)@2x.png")
            weatherImageView.backgroundColor = .white
            weatherImageView.layer.cornerRadius = 10
            weatherImageView.kf.setImage(with: url)
        }
    }
    
    func layout() {
        talkLabel.layer.masksToBounds = true
        talkLabel.layer.cornerRadius = 10
        talkLabel.backgroundColor = .white
        
        windLabel.layer.masksToBounds = true
        windLabel.layer.cornerRadius = 10
        windLabel.backgroundColor = .white
        
        humidityLabel.layer.masksToBounds = true
        humidityLabel.layer.cornerRadius = 10
        humidityLabel.backgroundColor = .white
        
        tempLabel.layer.masksToBounds = true
        tempLabel.layer.cornerRadius = 10
        tempLabel.backgroundColor = .white
        
        dateLabel.layer.masksToBounds = true
        dateLabel.layer.cornerRadius = 10
        dateLabel.backgroundColor = .white
        
        locationLabel.layer.masksToBounds = true
        locationLabel.layer.cornerRadius = 10
        locationLabel.backgroundColor = .white
    }
}

extension ViewController {
    func checkUserDeviceLocationServiceAuthorization() {

            let authorizationStatus: CLAuthorizationStatus

            if #available(iOS 14.0, *) {
                // 프로퍼티를 통해 locationManager가 가지고 있는 상태를 가져옴
                authorizationStatus = locationManager.authorizationStatus
                print(authorizationStatus)
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
                print(authorizationStatus)
            }

            // iOS 위치 서비스 활성화 여부 체크 : locationServicesEnabled()
            if CLLocationManager.locationServicesEnabled() {
                // 위치 서비스가 활성화 되어 있으므로, 위치 권한 요청 가능해서 위치 권한을 요청함
                checkUserCurrentLocationAuthorization(authorizationStatus)

            } else {
                print("위치 서비스가 꺼져 있어서 위치 권한 요청을 못함")
            }

        }

        // Location8. 사용자의 위치 권한 상태 확인
        // 사용자가 위치를 허용했는 지, 거부했는 지, 아직 선택하지 않앗는 지 등을 확인. (단, 사전에 iOS 위치 서비스 활성화 꼭 확인)
        func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
            switch authorizationStatus {
            case .notDetermined:
                print("NOTDETERMINED")

                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization() // 앱을 사용하는 동안에 대한 위치 권한 요청
                //plist WhenInUse -> request 메서드 OK
    //            locationManager.startUpdatingLocation()

            case .restricted, .denied:
                print("DENIED, 아이폰 설정으로 유도")
            case .authorizedWhenInUse:
                print("WHEN IN USE")
                // 사용자가 위치를 허용해둔 상태라면, startUpdatingLocation을 통해 didUpdateLocations 메서드가 실행
                locationManager.startUpdatingLocation()
            default: print("DEFAULT")

            }
        }

        func showRequestLocationServiceAlert() {
          let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
          let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in

              if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(appSetting)
              }
          }
          let cancel = UIAlertAction(title: "취소", style: .default)
          requestLocationServiceAlert.addAction(cancel)
          requestLocationServiceAlert.addAction(goSetting)

          present(requestLocationServiceAlert, animated: true, completion: nil)
        }


}

extension ViewController: CLLocationManagerDelegate {
    // Location5. 사용자의 위치를 성공적으로 가지고 온 경우
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           print(#function, locations)

           // ex. 위도, 경도 기반으로 날씨 정보를 조회
           // ex. 지도를 다시 세팅

           if let coordinate = locations.last?.coordinate {
               coordLat = coordinate.latitude
               coordLon = coordinate.longitude
               fetchWheaterByAPIManager()


           }
           //위치 업데이트 멈춰!!
           locationManager.stopUpdatingLocation()
       }

       // Location6. 사용자의 위치를 가져오지 못한 경우
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(#function)

       }

       // Location9. 사용자의 권한 상태가 바뀔 때를 알려줌
       // 거부 했다가 설정에서 변경했거나, 혹은 notDetermined에서 허용을 했거나 등
       // 허용 했어서 위치를 가지고 오는 중에, 설정에서 거부하고 돌아온다면?

       // iOS 14 이상: 사용자의 군한 상태가 변경이 될 때, 위치 관리자 생성할 때 호출됨.
       func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
           print(#function)
           checkUserDeviceLocationServiceAuthorization()
       }

       // iOS 14 미만
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

       }
}
