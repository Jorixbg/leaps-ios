//
//  SearchViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

class SearchViewModel: BaseViewModel {
    
    var searchEntry: Dynamic<SearchEntry>
    var tags: Dynamic<[String]>
    fileprivate var onSearch: ((SearchEntry) -> Void)?
    
    init(searchEntry: SearchEntry, tags: [String], onSearch: ((SearchEntry) -> Void)?) {
        self.searchEntry = Dynamic(searchEntry)
        self.tags = Dynamic(tags)
        self.onSearch = onSearch
    }

    func selectPeriod(period: SelectionPeriod) {
        searchEntry.value.selectionPeriod = period
    }
    
    var distanceText: String {
        return "\(searchEntry.value.searchDistance) km"
    }
    
    func resetSearch() {
        searchEntry.value = SearchEntry.default
        tags.listener?(tags.value)
    }
    
    func addToSearch(tag: String) {
        searchEntry.value.tags.append(tag)
    }
    
    func removeFromSearch(tag: String) {
        guard let index = searchEntry.value.tags.index(of: tag) else {
            return
        }
        
        searchEntry.value.tags.remove(at: index)
    }
    
    func didEnter(searchTerm: String) {
        searchEntry.value.searchTerm = searchTerm
    }
    
    func search() {
        onSearch?(searchEntry.value)
    }
}
