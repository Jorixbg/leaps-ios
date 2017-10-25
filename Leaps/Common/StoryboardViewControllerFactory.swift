//
//  StoryboardViewControllerFactory.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/16/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

//TODO: the approach with the current implementation is not the creates
struct StoryboardViewControllerFactory {
    let storyboard: UIStoryboard
    let userManager: UserManager
    init(storyboard: UIStoryboard, userManager: UserManager = UserManager.shared) {
        self.storyboard = storyboard
        self.userManager = userManager
    }
}

extension StoryboardViewControllerFactory {
    static func createShareViewController(event: Event, image:UIImage? = nil) -> UIActivityViewController {
        let  text = "Check out this event at Leaps!\n\n\(event.title)\n\nDownload Leaps app now and get first training FREE."
        
        var shareThis: [Any] = [ text ]
        if let image = image {
            shareThis.append(image)
        }
        let activityViewController = UIActivityViewController(activityItems: shareThis, applicationActivities: nil)
        return activityViewController
    }
}

extension StoryboardViewControllerFactory: ViewControllerFactory {
    func createPastHostingEventsViewController(events: [Event]) -> EventsListWithNavViewController? {
        return createEventListViewController(type: .hostingPast, events: events)
    }

    func createPastAttendingEventsViewController(events: [Event]) -> EventsListWithNavViewController? {
        return createEventListViewController(type: .attendingPast, events: events)
    }
    
    private func createEventListViewController(type: EventType, events: [Event]) -> EventsListWithNavViewController? {
        let eventResult = EventResult(type: type, events: events)
        let viewModel = ActivitiesViewModel(service: EventsService(), userService: UserService(), prefetchedEvents: eventResult)
        
        guard let vc = createViewController(viewControllerClass: EventsListWithNavViewController.self) else {
            return nil
        }
        
        vc.inject(viewModel)
        
        return vc
    }
    //MARK: - USER PROFILE-
    func createUserProfileViewController(user: Attendee) -> UserDetailsViewController? {
        guard let vc = createViewController(viewControllerClass: UserDetailsViewController.self) else {
            return nil
        }
        
        let viewModel = UserViewModel(simpleUser: user)
        vc.inject(viewModel)
        
        return vc
    }

    //MARK: - MAX DISTANCE SETTINGS -
    func createMaxDistanceSettingsViewController(viewModel: ProfileViewModel) -> MaxDistanseSettingViewController? {
        let vc = createViewController(viewControllerClass: MaxDistanseSettingViewController.self)
        vc?.inject(viewModel)
        
        return vc
    }

    
    //MARK: - EDIT PROFILE -
    func createEditProvfileViewController(viewModel: ProfileViewModel) -> EditProfileViewController? {
        let vc = createViewController(viewControllerClass: EditProfileViewController.self)
        vc?.inject(viewModel)
        
        return vc
    }

    func createTimeAndDateStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController? {
        return createCreateEventFlow(type: .timeAndDate, delegate: delegate)
    }

    func createPriceAndSlotsStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController? {
        return createCreateEventFlow(type: .priceAndSlots, delegate: delegate)
    }

    func createLocationStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController? {
        return createCreateEventFlow(type: .location, delegate: delegate)
    }

    func createCreateAnEventStep(delegate: EventEntryDelegate?) -> CreateEventStepViewController? {
        return createCreateEventFlow(type: .createAnEvent, delegate: delegate)
    }

    //MARK: - CREATE EVENT- 
    func createCreateEventFlow() -> UINavigationController? {
        let storyboard = UIStoryboard(name: .createEvent, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.createEvent(EventCreateData())), service: service)
        
        guard let stepOneVC = factory.createCreateAnEventStep(delegate: viewModel),
                let stepTwoVC = factory.createLocationStep(delegate: viewModel),
                let stepThreeVC = factory.createPriceAndSlotsStep(delegate: viewModel),
                let stepFourVC = factory.createTimeAndDateStep(delegate: viewModel) else {
            return nil
        }
        
        guard let flowVC = createViewController(viewControllerClass: StepsFlowViewController.self) else {
            return nil
        }
        
        flowVC.pageableViewControllers = [stepOneVC, stepTwoVC, stepThreeVC, stepFourVC]
        flowVC.inject(viewModel)
        let navigationController = UINavigationController(rootViewController: flowVC)
        
        return navigationController
    }
    
    private func createCreateEventFlow(type: CreateEventStepType, delegate: EventEntryDelegate?) -> CreateEventStepViewController? {
        let viewModel = CreateEventStepViewModel(type: type, delegate: delegate)
        let createEventVC = createViewController(viewControllerClass: CreateEventStepViewController.self)
        createEventVC?.inject(viewModel)
        
        return createEventVC
    }

    //MARK: - TRAINER PROFILE-
    func createTrainerProfileViewController(trainer: User) -> TrainerDetailsViewController? {
        
        guard let vc = createViewController(viewControllerClass: TrainerDetailsViewController.self) else {
            return nil
        }
        
        let viewModel = TrainerViewModel(trainer: trainer)
        vc.inject(viewModel)
        
        return vc
    }
    
    //MARK: - FOLLOWERS-
    func createFollowersViewController(event:Event) -> FollowersViewController? {
        let service = EventsService()
        let userService = UserService()
        let viewModel = FollowingViewModel(event: event, userService: userService, service: service)
        return createFollowersViewController(viewModel: viewModel)
    }
    
    func createFollowersViewController(user:User) -> FollowersViewController? {
        let service = EventsService()
        let userService = UserService()
        let viewModel = FollowingViewModel(user: user, userService: userService, service: service)
        return createFollowersViewController(viewModel: viewModel)
    }
    
    func createFollowersViewController(viewModel:FollowingViewModel) -> FollowersViewController? {
        guard let vc = createViewController(viewControllerClass: FollowersViewController.self) else {
            return nil
        }
        vc.inject(viewModel)
        
        return vc
    }

    //MARK: - FORGOTTEN PASSWORD-
    func createStepOneForgottenPasswordViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .forgottenPassword, userEntryDelegate: userEntryDelegate, prefilledData: nil)
    }

    func createForgottenPasswordFlowViewController() -> StepsFlowViewController? {
        let storyboard = UIStoryboard(name: .login, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.forgottenPassword), service: service)//, userDetails: prefilledData)
        
        guard let loginVC = factory.createStepOneForgottenPasswordViewController(userEntryDelegate: viewModel) else {
            return nil
        }
        
        let flowVC = createViewController(viewControllerClass: StepsFlowViewController.self)
        flowVC?.pageableViewControllers = [loginVC]
        flowVC?.inject(viewModel)
        
        return flowVC
    }

    
    //MARK: - LOGIN-
    func createLoginViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .login, userEntryDelegate: userEntryDelegate, prefilledData: nil)
    }

    func createStandardLoginFlowViewController(onLogin: ((Bool) -> Void)?) -> StepsFlowViewController? {
        let storyboard = UIStoryboard(name: .login, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.login(LoginData())), service: service)//, userDetails: prefilledData)
        
        guard let loginVC = factory.createLoginViewController(userEntryDelegate: viewModel) else {
            return nil
        }
        
        let flowVC = createViewController(viewControllerClass: StepsFlowViewController.self)
        flowVC?.onLogin = onLogin
        flowVC?.pageableViewControllers = [loginVC]
        flowVC?.inject(viewModel)
        
        return flowVC
    }

    
    //MARK: - BECOME TRAINER-
    func createBecomeATrainerFlowViewController() -> StepsFlowViewController? {
        let storyboard = UIStoryboard(name: .login, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.becomeTrainer(BecomeTrainerData())), service: service)
        guard   let stepOne = factory.createStepOneBecomeTrainerViewController(userEntryDelegate: viewModel),
                let stepTwo = factory.createStepTwoBecomeTrainerViewController(userEntryDelegate: viewModel),
                let stepThree = factory.createStepThreeBecomeTrainerViewController(userEntryDelegate: viewModel) else {
                print("couldnt create become trainer flow")
                return nil
        }
        
        let stepFlowViewController = createViewController(viewControllerClass: StepsFlowViewController.self)
        stepFlowViewController?.pageableViewControllers = [stepOne, stepTwo, stepThree]
        stepFlowViewController?.inject(viewModel)
        
        return stepFlowViewController
    }

    func createStepThreeBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .phoneNumber, userEntryDelegate: userEntryDelegate, prefilledData: nil)
    }

    func createStepTwoBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .sessionPrice, userEntryDelegate: userEntryDelegate, prefilledData: nil)
    }

    func createStepOneBecomeTrainerViewController(userEntryDelegate: UserEntryDelegate?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .yearsOfTraining, userEntryDelegate: userEntryDelegate, prefilledData: nil)
    }

    private func createViewController<T: UIViewController> (viewControllerClass: T.Type) -> T? {
        guard let vc = storyboard.instantiateViewController(withIdentifier: "\(T.self)") as? T else {
            print("init \(T.self) failed")
            return nil
        }
        
        return vc
    }
    
    //MARK: - ACTIVITIES-
    func createActivitiesViewController() -> ActivitiesViewController? {
        let service = EventsService()
        let userService = UserService()
        let viewModel = ActivitiesViewModel(service: service, userService: userService, eventSearchType: .all)
        let vc = createViewController(viewControllerClass: ActivitiesViewController.self)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - REGISTRATION FLOW-
    func createRegistrationFlowViewController(prefilledData: UserSignUpStepsData? = nil,
                                              isSocialNetworkRegistration: Bool,
                                              onLogin: ((Bool) -> Void)?) -> StepsFlowViewController? {
        let storyboard = UIStoryboard(name: .login, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.registration(prefilledData)), service: service)//, userDetails: prefilledData)
        var viewControllers: [UIViewController] = []
        guard let regStrepOneViewController = factory.createStepOneRegistrationViewController(userEntryDelegate: viewModel, prefilledData: prefilledData),
            let regStepTwoViewController = factory.createStepTwoRegistrationViewController(userEntryDelegate: viewModel,
                                                                                           prefilledData: prefilledData),
            let regStepFourOneViewController = factory.createStepFourRegistrationViewController(userEntryDelegate: viewModel,
                                                                                                prefilledData: prefilledData) else {
            return nil
        }
        viewControllers.append(regStrepOneViewController)
        viewControllers.append(regStepTwoViewController)
        if let regStepThreepOneViewController = factory.createStepThreeRegistrationViewController(userEntryDelegate: viewModel,
                                                                                                      prefilledData: prefilledData),
            !isSocialNetworkRegistration {
            viewControllers.append(regStepThreepOneViewController)
        }
        
        viewControllers.append(regStepFourOneViewController)
        
        let registrationFlowViewController = createViewController(viewControllerClass: StepsFlowViewController.self)
        registrationFlowViewController?.pageableViewControllers = viewControllers
        registrationFlowViewController?.inject(viewModel)
        registrationFlowViewController?.onLogin = onLogin
        return registrationFlowViewController
    }
    
    func createStepOneRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .firstLastName, userEntryDelegate: userEntryDelegate, prefilledData: prefilledData)
    }
    
    func createStepTwoRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .emailAddress, userEntryDelegate: userEntryDelegate, prefilledData: prefilledData)
    }
    
    func createStepThreeRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .password, userEntryDelegate: userEntryDelegate, prefilledData: prefilledData)
    }
    
    func createStepFourRegistrationViewController(userEntryDelegate: UserEntryDelegate?, prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController? {
        return createRegStepViewController(type: .birthday, userEntryDelegate: userEntryDelegate, prefilledData: prefilledData)
    }
    
    private func createRegStepViewController(type: RegistrationStepType, userEntryDelegate: UserEntryDelegate?,  prefilledData: UserSignUpStepsData?) -> RegistrationStepOneViewController? {
        let stepOneViewModel = RegistrationStepViewModel(type: Dynamic(type), userPrefilledData: Dynamic(prefilledData))
        let regStepOneViewController = createViewController(viewControllerClass: RegistrationStepOneViewController.self)
        stepOneViewModel.delegate = userEntryDelegate
        regStepOneViewController?.inject(stepOneViewModel)
        
        return regStepOneViewController
    }
    
    //MARK: - HOME-
    func createHomeViewController() -> HomeViewController? {
        let homeViewController = createViewController(viewControllerClass: HomeViewController.self)
        
        return homeViewController
    }
    
    func createLoginNavigationController(onLogin: ((Bool) -> Void)?) -> UINavigationController? {
        let viewModel = LoginViewModel(service: UserService())
        guard let loginViewController = createViewController(viewControllerClass: LoginViewController.self) else {
            return nil
        }
        loginViewController.inject(viewModel)
        loginViewController.onLogin = onLogin
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
    
    //MARK: - ONBOARDING-
    func createOnboradingStepOneViewController() -> StepViewController? {
        return createOnboardingStepViewController(type: .first)
    }
    
    func createOnboradingStepTwoViewCotroller() -> StepViewController? {
        return createOnboardingStepViewController(type: .second)
    }
    
    func createOnboradingStepThreeViewController() -> StepViewController? {
        return createOnboardingStepViewController(type: .third)
    }
    
    func createOnboradingStepFourViewController() -> StepViewController? {
        return createOnboardingStepViewController(type: .fourth)
    }
    
    func createOnboradingStepFiveViewController() -> StepViewController? {
        return createOnboardingStepViewController(type: .fifth)
    }
    
    func createOnboardingStepViewController(type: StepType) -> StepViewController? {
        let stepViewController = createViewController(viewControllerClass: StepViewController.self)
        let third = Dynamic(type)
        let viewModel = OnboardingStepViewModel(type: third)
        stepViewController?.inject(viewModel)
        
        return stepViewController
    }
    
    func createOnboardingFlowViewController() -> StepsFlowViewController? {

        guard let stepOne = createOnboradingStepOneViewController(),
            let stepTwo = createOnboradingStepTwoViewCotroller(),
            let stepThree = createOnboradingStepThreeViewController(),
            let stepFour = createOnboradingStepFourViewController(),
            let stepFive = createOnboradingStepFiveViewController() else {
                print("guard failed \(#function), \(#line)")
                return nil
        }
        
        let onboardingViewController = createViewController(viewControllerClass: StepsFlowViewController.self)
        onboardingViewController?.pageableViewControllers = [stepOne, stepTwo, stepThree, stepFour, stepFive]
        let service = UserService()
        let viewModel = StepFlowViewModel(type: Dynamic(.onboarding), service: service)
        onboardingViewController?.inject(viewModel)
        return onboardingViewController
    }
    
    //MARK: - SEARCH-
    func createSearchViewController(onSearchPressed: @escaping ((SearchEntry) -> Void)) -> SearchViewController? {
        let vc = createViewController(viewControllerClass: SearchViewController.self)
        vc?.modalPresentationStyle = .overCurrentContext
        vc?.modalTransitionStyle = .crossDissolve
        let searchEntry = SearchEntry.default
        
        let tags = userManager.tags ?? []
        
        let viewModel = SearchViewModel(searchEntry: searchEntry, tags: tags, onSearch: onSearchPressed)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - HOME-TRAINERS-
    func createTrainersViewController() -> TrainersViewController? {
        let vc = createViewController(viewControllerClass: TrainersViewController.self)
        let service = UserService()
        let viewModel = TrainersViewModel(service: service)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - EVENT DETAILS-
    func createEventDetailsViewController(event: Event) -> EventDetailsViewController? {
        let vc = createViewController(viewControllerClass: EventDetailsViewController.self)
        let service = EventsService()
        let viewModel = EventViewModel(event: event, service: service)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - EVENT DETAILS RATE-
    func createEventDetailsRateViewController(event: Event) -> EventDetailsRateViewController? {
        let vc = createViewController(viewControllerClass: EventDetailsRateViewController.self)
        let service = EventsService()
        let viewModel = EventViewModel(event: event, service: service)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - EVENT THANKS-
    func createEventDetailsThanksViewController(event: Event) -> EventDetailsThanksViewController? {
        let vc = createViewController(viewControllerClass: EventDetailsThanksViewController.self)
        let service = EventsService()
        let viewModel = EventViewModel(event: event, service: service)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - EVENT REVIEWS-
    func createEventDetailsReviewsViewController(event: Event) -> EventDetailsReviewsViewController? {
        let vc = createViewController(viewControllerClass: EventDetailsReviewsViewController.self)
        let service = EventsService()
        let viewModel = ReviewViewModel(event: event, service: service)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - HOME-ALL ACTIVITIES-
    func createAllActivitiesViewController(type: EventType) -> AllActivitiesViewController? {
        let vc = createViewController(viewControllerClass: AllActivitiesViewController.self)
        let service = EventsService()
        let userService = UserService()
        let viewModel = ActivitiesViewModel(service: service, userService: userService, eventSearchType: type)
        vc?.inject(viewModel)
        
        return vc
    }
    
    //MARK: - HOME-LOCATIONS-
    func createLocationsViewController(viewModel:ActivitiesViewModel?) -> UINavigationController? {
        let vc = createViewController(viewControllerClass: LocationsViewController.self)
        if let viewModel = viewModel {
            vc?.inject(viewModel)
        }
        else {
            let service = EventsService()
            let userService = UserService()
            let viewModel = ActivitiesViewModel(service: service, userService: userService, eventSearchType: .all)
            vc?.inject(viewModel)
        }
        let nvc = UINavigationController(rootViewController: vc!)
        
        return nvc
    }
}

