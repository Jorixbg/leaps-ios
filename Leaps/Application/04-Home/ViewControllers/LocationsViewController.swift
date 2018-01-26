//
//  LocationsViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 24/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    
    fileprivate var viewModel: ActivitiesViewModel?
    fileprivate var events:[Event] = []
    
    var markers:[GMSMarker] = []
    var selectedMarker:GMSMarker?
    var selectedIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let coordinates = UserManager.shared.currentCoordinates ?? (42.6977, 23.3219)
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: coordinates.0,
                                                  longitude: coordinates.1,
                                                  zoom: 14.0)
        mapView.delegate = self
        
        tableView.register(LocationsEventTableViewCell.self)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        tableView.transform = transform
        tableView.frame.origin.x = 0
        tableView.frame.origin.y = UIScreen.main.bounds.height - 140 - 15
        tableView.frame.size.width = UIScreen.main.bounds.width
        tableView.frame.size.height = 140
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 11, height: 11))
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let allEvents = viewModel?.allEvents(filtered: true) {
            if allEvents.count == 0 {
                viewModel?.fetchEvents()
                viewModel?.eventSearchResults.bind({ [weak self] (eventsResult) in
                    self?.events = self?.viewModel?.allEvents() ?? []
                    self?.reloadData()
                })
            }
            else {
                events = allEvents
                reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    @IBAction func didSelectCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func reloadData() {
        self.loadMarkers()
        self.tableView.reloadData()
    }
    
    func selectLocation(indexPath:IndexPath?, marker:GMSMarker?) {
        var newMarker = GMSMarker()
        var newIndexPath = IndexPath()
        
        if let marker:GMSMarker = marker, let index = marker.userData as? Int {
            newMarker = marker
            newIndexPath = IndexPath(row: 0, section: index)
        }
        if let index = indexPath {
            newMarker = markers[index.section]
            newIndexPath = index
        }
//        selectedMarker?.zIndex = 1
//        newMarker.zIndex = 2
        
        guard let iconView = newMarker.iconView as? LocationIconView else {
            return
        }
        if selectedIndex == newIndexPath.section {
            openEventViewController(event: events[selectedIndex])
        }
        else {
            if let iconView = selectedMarker?.iconView as? LocationIconView {
                iconView.isActieve = false
            }
            iconView.isActieve = true
            selectedMarker = newMarker
            selectedIndex = newIndexPath.section
            mapView.animate(toLocation: newMarker.position)
            
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .top)
        }
    }
    
    func openEventViewController(event:Event) {
        let storyboard = UIStoryboard(name: .eventDetails, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createEventDetailsViewController(event: event) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LocationsViewController: Injectable {
    func inject(_ viewModel: ActivitiesViewModel) {
        self.viewModel = viewModel
    }
}

extension LocationsViewController:GMSMapViewDelegate {
    func loadMarkers() {
        mapView.clear()
        markers = []
        var i = 0
        for event in events {
            let position = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)

            let marker = GMSMarker(position: position)
            marker.title = event.title
            marker.map = mapView
            let iconView = LocationIconView.instanceFromNib()
            iconView.setup(price: event.priceFrom, index: i)
            marker.iconView = iconView
            marker.userData = i
            i = i+1
            markers.append(marker)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        selectLocation(indexPath: nil, marker: marker)
        return true
    }
}

extension LocationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: LocationsEventTableViewCell.self, for: indexPath) { (cell) in
            let event = events[indexPath.section]
            

            let distance = viewModel?.distance(from: event)
            let eventViewModel = ActivityViewModel(event: event, distanceFromCurrentLocation: distance)
            cell.viewModel = eventViewModel
            
        }
        
        //pagination
        viewModel?.loadMore(currentActivity: indexPath, completion: nil)
        
        return cell
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        cell.transform = transform
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 11
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectLocation(indexPath: indexPath, marker: nil)
    }
}

extension LocationsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = tableView.contentOffset.x + tableView.bounds.width/2
        let y = tableView.contentOffset.y + tableView.bounds.height/2//tableView.rowHeight/2
        if let indexPathToScrollTo: IndexPath = self.tableView.indexPathForRow(at: CGPoint (x: x, y: y)) {
            //tableView.selectRow(at: indexPathToScrollTo, animated: true, scrollPosition: .top)
            tableView.scrollToRow(at: indexPathToScrollTo, at: .top, animated: true)
        }
    }
}
