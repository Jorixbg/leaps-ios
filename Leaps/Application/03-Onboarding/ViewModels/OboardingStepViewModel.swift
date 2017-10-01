//
//  StepViewModel.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/1/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import Foundation

enum StepType {
    case first
    case second
    case third
    case fourth
    case fifth
    
    func titleForStep() -> String {
        switch self {
        case .first:
            return "Sports rookie or pro athlete?"
        case .second:
            return "Pay less, get more."
        case .third:
            return "Train with the best"
        case .fourth:
            return "You’re part of the team now"
        case .fifth:
            return "The more you train, \nthe more you gain"
        }
    }
    
    func subtitleForStep() -> String {
        switch self {
        case .first:
            return "Doesn’t matter. Leaps will help you find the best training event for you personally."
        case .second:
            return "Leaps revolutionizes the way you pay for training sessions, allowing you to pay less for a better training experience."
        case .third:
            return "Leaps is the only app that shows you a full list of trainers in your city, ranked and rated strictly by users. Warning - chances of disappointment drop dramatically."
        case .fourth:
            return "Socialize and team up with other sports enthusiasts. Join teams and you’ll never train alone again."
        case .fifth:
            return "Unlock prizes, free training sessions and bonuses for staying in shape. It’s called a work out. So finally, you’ll get rewarded for it."
        }
    }
}
class OnboardingStepViewModel: BaseViewModel {
    
    let type: Dynamic<StepType>
    
    init(type: Dynamic<StepType>) {
        self.type  = type
    }
}
