//
//  UtilsService.swift
//  Leaps
//
//  Created by Slav Sarafski on 17/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation
import GoogleMaps

typealias CoordinatesResult = Result<(Double, Double)>
typealias CoordinatesFetchingHandler = (CoordinatesResult) -> Void
typealias AddressResult = Result<(String)>
typealias AddressFetchingHandler = (AddressResult) -> Void

class UtilsService {

    private let userManager: UserManager
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager(), userManager: UserManager = UserManager.shared) {
        self.networkManager = networkManager
        self.userManager = userManager
    }
    
    //MARK: - COORDINATES FETCH BY ADDRESS
    func fetchCoordinates(by address:String, completion: CoordinatesFetchingHandler?) {
        let endPoint = "/utils/coordinates"
        let params = ["address": address]
        let headers = ["Content-Type": "application/json"]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            // parse data to user or trainer and return it
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let data):
                guard let data = data as? [String: Any],
                      let lat = data["coord_lat"] as? Double,
                      let lon = data["coord_lnt"] as? Double else {
                    completion?(Result.error(LeapsError.deserializing))
                    return
                }
                completion?(Result.success((lat, lon)))
            }
        }
    }
    
    func fetchAdress(with coordinates:CLLocationCoordinate2D, completion: AddressFetchingHandler?) {
        let endPoint = "/utils/address"
        let params = ["coord_lat": coordinates.latitude, "coord_lnt": coordinates.longitude]
        let headers = ["Content-Type": "application/json"]
        
        networkManager.post(path: endPoint, params: params, headers: headers) { (result) in
            // parse data to user or trainer and return it
            switch result {
            case .error(let error):
                completion?(Result.error(error))
            case .success(let data):
                guard let data = data as? [String: Any],
                      let address = data["address"] as? String else {
                        completion?(Result.error(LeapsError.deserializing))
                        return
                }
                completion?(Result.success((address)))
            }
        }
    }
}
