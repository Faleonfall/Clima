//
//  ViewController.swift
//  Clima
//
//  Created by Volodymyr Kryvytskyi on 21.07.2023.
//

import UIKit
import CoreLocation

@MainActor
class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let weatherManager = WeatherManager()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        searchTextField.delegate = self
        
        // Ask for permission only; actual location will be requested later.
        locationManager.requestWhenInUseAuthorization()
    }

    private func render(weather: WeatherModel) {
        temperatureLabel.text = weather.temperatureString
        conditionImageView.image = UIImage(systemName: weather.conditionName)
        cityLabel.text = weather.cityName
    }

    private func presentError(_ error: Error) {
        let message: String
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                message = "Location access denied. Enable it in Settings."
            case .locationUnknown:
                message = "Temporary issue getting your location. Try again."
            default:
                message = clError.localizedDescription
            }
        } else if let localized = error as? LocalizedError, let desc = localized.errorDescription {
            message = desc
        } else {
            message = (error as NSError).localizedDescription
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           text.isEmpty == false {
            return true
        } else {
            textField.placeholder = "Type a city name"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let city = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              city.isEmpty == false else { return }
        searchTextField.text = ""

        Task {
            do {
                let model = try await weatherManager.weather(for: city)
                render(weather: model)
            } catch {
                presentError(error)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: @MainActor CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted, .denied:
            // Optionally inform the user to enable location in Settings.
            break
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        Task {
            do {
                let model = try await weatherManager.weather(latitude: lat, longitude: lon)
                render(weather: model)
            } catch {
                presentError(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presentError(error)
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}
