//
//  LocationManager.swift
//  FestiGo
//
//  Created by kisellsn on 08/04/2025.
//

import Foundation
import CoreLocation


class LocationFetcher: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    private var completion: ((String) -> Void)?

    func requestLocation(completion: @escaping (String) -> Void) {
        self.completion = completion
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                let name = [place.locality, place.administrativeArea, place.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                self.completion?(name)
            } else {
                self.completion?("Не вдалося визначити місцезнаходження")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.completion?("Помилка при отриманні геопозиції")
    }
}


//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
//    var locationManager = CLLocationManager()
//    
//    
////    @IBAction func locationPressed(_ sender: UIButton) {
////        locationManager.requestLocation()
////    }
////    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            locationManager.stopUpdatingLocation()
//            let lat = location.coordinate.latitude
//            let lon = location.coordinate.longitude
////            weatherManager.fetchWeather(latitude: lat, longitude: lon)
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
//    }
//}
