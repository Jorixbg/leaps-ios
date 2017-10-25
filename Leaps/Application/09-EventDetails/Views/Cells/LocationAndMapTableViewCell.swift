//
//  AboutTableViewCell.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/27/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationAndMapTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var unloggedImageView: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    
    //TODO: moregeneric names as this cell is resused on quite a few places. Also we need to refactor cell setup
    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var categoryImage: UIImage? {
        didSet {
            categoryImageView.image = categoryImage
        }
    }
    
    var viewModel:EventViewModel? {
        didSet {
            guard let event = viewModel?.event.value else {
                return
            }
            let position = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            mapView.camera = GMSCameraPosition.camera(withTarget: position, zoom: 7.0)
            
            let marker = GMSMarker(position: position)
            marker.title = event.title
            marker.map = mapView
            let iconView = LocationIconView.instanceFromNib()
            iconView.setup(price: event.priceFrom, index: 0)
            marker.iconView = iconView
        }
    }
    
    func showImage(shouldShowImage: Bool, image: UIImage? = nil) {
        unloggedImageView.isHidden = !shouldShowImage
        unloggedImageView.image = image
        if shouldShowImage {
            descriptionLabel.text = ""
            mapView.removeFromSuperview()
        }
    }
}
