//
//  ReviewViewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 23/9/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class ReviewViewModel: BaseViewModel {
    
    let event: Dynamic<Event>
    var reviews: Dynamic<[Review]> = Dynamic([])
    private let service: EventsService
    private var nextPage = 1
    
    var hasFinishedFetching: Dynamic<Bool> = Dynamic(true)
    
    init(event: Event, service: EventsService) {
        self.event = Dynamic(event)
        self.service = service
        
    }
    
    func loadMore(indexPath: IndexPath,
                  completion: ((Error?) -> Void)? = nil) {
        guard hasFinishedFetching.value else {
            return
        }
        
        guard indexPath.row == reviews.value.count - 1 else {
                return
        }
        
        fetchEventsReviews(completion: completion)
    }
    
    func fetchEventsReviews(completion: ((Error?) -> Void)? = nil) {
        guard hasFinishedFetching.value == true else {
            return
        }
        
        hasFinishedFetching.value = false
        
        let id = event.value.id
        service.fetchedEventReviews(id: id, page: nextPage) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let fetchedReviews):
                //last page reached when we get empty array
                guard fetchedReviews.count > 0 else {
                    break
                }
                
                strongSelf.reviews.value = fetchedReviews
                
                completion?(nil)
                strongSelf.nextPage = strongSelf.nextPage + 1
                
            case .error(let error):
                
                completion?(error)
            }
            
            //this will trigger table view reload data
            self?.hasFinishedFetching.value = true
        }
    }
}
