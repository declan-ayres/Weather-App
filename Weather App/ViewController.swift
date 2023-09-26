//
//  ViewController.swift
//  Weather App
//
//  Created by Declan Ayres on 9/19/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    lazy var searchBar: UITextField! = {
        let searchBar = UITextField(frame: .zero)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        searchBar.backgroundColor = .white
        searchBar.borderStyle = .roundedRect
        searchBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        searchBar.placeholder = "City"
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return searchBar
    }()
        
    lazy var button: UIButton! = {
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.text = "Search"
        button.setTitle("Search", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(searchWeatherTapped), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var tempLabel: UILabel! = {
        tempLabel = UILabel(frame: .zero)
        tempLabel.font = UIFont.systemFont(ofSize: 32)
        return tempLabel
    }()
    
    lazy var descriptionLabel: UILabel! = {
        descriptionLabel = UILabel(frame: .zero)
        return descriptionLabel
    }()
    
    lazy var highLabel: UILabel! = {
        let highLabel = UILabel(frame: .zero)
        return highLabel
    }()
    
    lazy var lowLabel: UILabel! = {
        let lowLabel = UILabel(frame: .zero)
        return lowLabel
    }()
    
    //I would have put this in separate view given more time
    lazy var stackView: UIStackView! = {
        let stackView = UIStackView(arrangedSubviews: [imageView, cityLabel, tempLabel, descriptionLabel, innerStackView, windLabel, humidityLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var innerStackView: UIStackView! = {
        let innerStackView = UIStackView(arrangedSubviews: [lowLabel, highLabel])
        innerStackView.axis = .horizontal
        innerStackView.spacing = 8
        return innerStackView
    }()
    
    lazy var cityLabel: UILabel! = {
        let cityLabel = UILabel(frame: .zero)
        cityLabel.font = UIFont.systemFont(ofSize: 28)
        return cityLabel
    }()
    
    lazy var imageView: UIImageView! = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()
    
    lazy var windLabel: UILabel! = {
        let windLabel = UILabel(frame: .zero)
        return windLabel
    }()
    
    lazy var humidityLabel: UILabel! = {
        let humidityLabel = UILabel(frame: .zero)
        return humidityLabel
    }()
    
    lazy var errorLabel: UILabel! = {
        let errorLabel = UILabel(frame: .zero)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        errorLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -40).isActive = true
        return errorLabel
    }()
    
    var weatherApi = ApiManager()
    var locationManager = CLLocationManager()
    var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        view.addSubview(button)
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        button.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 10).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        } else {
            if let lastCity = UserDefaults.standard.string(forKey: "lastCity") {
                searchWeather(city: lastCity)
            }
        }
    }
    
    @objc func searchWeatherTapped() {
        guard let text = searchBar.text else {return}
        if text.isEmpty {return}
        searchWeather(city: text)
    }
    
    func searchWeather(city: String) {
        if loading {
            return
        }
        loading = true
        weatherApi.getWeatherForCity(city: city) { result in
            self.loading = false
            switch result {
            case .failure(let error):
                self.stackView.isHidden = true
                self.errorLabel.isHidden = false
                self.errorLabel.text = "Failed to get weather: \(error.localizedDescription)"
                return
            case .success(let weather):
                self.stackView.isHidden = false
                self.errorLabel.isHidden = true
                self.tempLabel.text = String(Int(weather.mainData.temp)) + "º"
                self.descriptionLabel.text = weather.details[0].description
                self.highLabel.text = "H: " + String(Int(weather.mainData.temp_max)) + "º"
                self.lowLabel.text = "L: " + String(Int(weather.mainData.temp_min)) + "º"
                self.cityLabel.text = weather.name
                self.humidityLabel.text = "Humidity: " + String(Int(weather.mainData.humidity)) + "%"
                self.windLabel.text = "Wind Speed: " + String(Int(weather.windData.speed)) + " mph"
                self.weatherApi.getWeatherIcon(icon: weather.details[0].icon) { result in
                    switch result {
                    case .failure( _):
                        return
                    case .success(let image):
                        self.imageView.image = image
                    }
                }
                UserDefaults.standard.set(city, forKey: "lastCity")
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let coordinate = location.coordinate
        weatherApi.getCityFromCoords(lat: coordinate.latitude, lon: coordinate.longitude) { [weak self] result in
            switch result {
            case .failure(_):
                let alert = UIAlertController(title: "Error", message: "Unable to convert coordinates to city", preferredStyle: .alert)
                self?.present(alert, animated: true)
            case .success(let city):
                self?.searchWeather(city: city)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Location Error", message: "Unable to get location", preferredStyle: .alert)
        self.present(alert, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }

}

