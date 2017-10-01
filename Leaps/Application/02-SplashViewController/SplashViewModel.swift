//
//  SplashViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/24/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class SplashViewModel: BaseViewModel {
    
    private let service: EventsService
    private let userManager: UserManager
    
    init(service: EventsService = EventsService(), userManager: UserManager = UserManager.shared) {
        self.service = service
        self.userManager = userManager
    }
    
    func fetchTags(completion: ((Error?) -> Void)?) {
        service.fetchTags { [weak self] (result) in
            switch result {
            case .success(let tags):
                self?.userManager.setTags(tags: tags)
                completion?(nil)
            case .error(let error):
                completion?(error)
            }
        }
    }
}
