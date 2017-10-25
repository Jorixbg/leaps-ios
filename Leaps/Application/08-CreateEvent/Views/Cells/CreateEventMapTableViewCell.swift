//
//  CreateEventMapTableViewCell.swift
//  Leaps
//
//  Created by Slav Sarafski on 15/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import GoogleMaps

class CreateEventMapTableViewCell: StandardCreateEventTableViewCell, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    let gmsgeocoder = GMSGeocoder()
    let clgeocoder = CLGeocoder()
    
    var viewModel:CreateEventStepViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let coordinates = UserManager.shared.currentCoordinates ?? (42.6977, 23.3219)
        
        mapView.layer.cornerRadius = Constants.General.standradCornerRadius
        mapView.camera = GMSCameraPosition.camera(withLatitude: coordinates.0,
                                                  longitude: coordinates.1,
                                                  zoom: 16.0)
        mapView.delegate = self
        
        self.onTextEnter = { [unowned self] text in
            //self.viewModel?.delegate?.enterLocation(location: text)
            delay(0.7, closure: {
                if text == self.textField.text {
                    self.fetchCoordinates(text: text)
                }
            })
        }
    }
    
    func fetchCoordinates(text:String) {
        self.viewModel?.delegate?.enterLocation(location: text)
        self.viewModel?.fetchCoordinates(by: text, completion: { [weak self] (result) in
            switch result {
            case .success((let lat, let lnt)):
                self?.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lnt))
                self?.viewModel?.delegate?.enterCoordinates(lat: lat, lon: lnt)
                break
            case .error(_):
                
                break
            }
        })
    }
    
    //MARK: GMSMapView Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.viewModel?.delegate?.enterCoordinates(lat: position.target.latitude, lon: position.target.longitude)
    }
    
    //MARK: Geocoder
    func getAddress(byCoordinates coordinates: CLLocationCoordinate2D) {
        gmsgeocoder.reverseGeocodeCoordinate(coordinates) { (response, error) in
            if let address = response?.firstResult() {
                print(address)
                var addressArray:[String] = []
                if let city = address.locality {
                    addressArray.append(city)
                }
                if let subLocality = address.subLocality {
                    addressArray.append(subLocality)
                }
                if let thoroughfare = address.thoroughfare {
                    addressArray.append(thoroughfare)
                }
                self.textField.text = addressArray.joined(separator: ", ")
            }
        }
    }
    
    func getCoordinates(byAddress address:String) {
        clgeocoder.geocodeAddressString(address) { (places, error) in
            if let place = places?.first,
               let location = place.location {
                self.mapView.animate(toLocation: location.coordinate)
            }
        }
    }
}
