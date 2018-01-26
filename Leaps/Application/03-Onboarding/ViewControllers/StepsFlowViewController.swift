//
//  OnboardingViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 5/28/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import CoreLocation

class StepsFlowViewController: UIViewController {
    
    typealias T = StepFlowViewModel
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rightTop: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomCentralButton: UIButton!
    
    var pageableViewControllers: [UIViewController] = []
    //keyboard avoidable
    var layoutConstraintsForKeyboard: [NSLayoutConstraint] = []
    var initialLayoutConstraintsConstantsForKeyboard: [CGFloat] = []
    var aboveKeyboardMargin: CGFloat = 20
    var onLogin: ((Bool) -> Void)?
    
    private var isDoneLayingOutScrollView = false
    fileprivate var locationManager: CLLocationManager!
    fileprivate var viewModel: StepFlowViewModel?
    fileprivate var didPressTopRightButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        assert(!pageableViewControllers.isEmpty)
        addKeyboardObservers()
        layoutConstraintsForKeyboard.append(pageControlBottomConstraint)
        initialLayoutConstraintsConstantsForKeyboard.append(pageControlBottomConstraint.constant)
        
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        
        cancelButton.setTitle(.back, for: .normal)
        pageControl.numberOfPages = pageableViewControllers.count
        pageControl.currentPage = 0
        pageControl.isHidden = pageableViewControllers.count < 2
        
        viewModel?.type.bindAndFire({ [unowned self] (type) in
            self.cancelButton.isHidden = type.isCancelHidden()
            self.rightTop.isHidden = type.isSkipHidden()
            self.rightTop.setTitle(type.titleForTopRigtButton(), for: .normal)
            self.nextButton.isHidden = type.isNextButtonIsHidden()
            self.bottomCentralButton.setTitle(type.titleForBottomButton(), for: .normal)
            switch type {
            case .login:
                self.didPressTopRightButtonAction = {
                    let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
                    let factory = StoryboardViewControllerFactory(storyboard: storyboard)
                    guard let vc = factory.createForgottenPasswordFlowViewController() else {
                        return
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            case .onboarding:
                self.nextButton.setTitle(.next, for: .normal)
                self.nextButton.setImage(#imageLiteral(resourceName: "next"), for: .normal)
                self.didPressTopRightButtonAction = {
                    self.dismiss(animated: true, completion: nil)
                }
            case .createEvent:
                //show navbar
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.navigationBar.isTranslucent = false
                
                //back button
                let buttonSelector = #selector(self.didPressCancel)
                let cancelNavButton = UIButton(type: .custom)
                cancelNavButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
                cancelNavButton.addTarget(self, action: buttonSelector, for: .touchUpInside)
                cancelNavButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                cancelNavButton.imageEdgeInsets = UIEdgeInsetsMake(0, -11, 0, 0)
                cancelNavButton.tintColor = .leapsOnboardingBlue
                cancelNavButton.contentHorizontalAlignment = .left
                cancelNavButton.contentVerticalAlignment = .center
                let barButton = UIBarButtonItem(customView: cancelNavButton)
                self.navigationItem.leftBarButtonItem  = barButton
                
                //set attributed title
                self.setCurrentTitle(page: self.pageControl.currentPage)
                guard let font = UIFont.leapsSFFont(size: 12) else {
                    break
                }
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font,
                                                                                NSAttributedStringKey.foregroundColor: UIColor.leapsOnboardingBlue]

                //remove bottom line
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.navigationBar.shadowImage = UIImage()
            default:
                break
            }
        })
        
        UIApplication.shared.statusBarStyle = .default
        setupLocation()
    }
    
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // the first possible moment before viewDidAppear to layout scrollview
        if scrollView.bounds.width == view.bounds.width && !isDoneLayingOutScrollView {
            for (index, step) in pageableViewControllers.enumerated() {
                let x = CGFloat(index) * scrollView.bounds.width
                let y: CGFloat = 0
                let width = scrollView.bounds.width
                let height = scrollView.bounds.height
                let frame = CGRect(x: x, y: y, width: width, height: height)
                step.view.frame = frame
                scrollView.addSubview(step.view)
                self.addChildViewController(step)
                step.didMove(toParentViewController: self)
            }
            
            let scrollViewWidth = scrollView.bounds.width * CGFloat(pageableViewControllers.count)
            let scrollViewHeight = scrollView.frame.height
            scrollView.contentSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
            isDoneLayingOutScrollView = true
        } 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let type = viewModel?.type.value else {
            return
        }
        switch type {
        case .onboarding, .forgottenPassword:
            self.configureToDismissKeyboard()
        case .registration, .becomeTrainer, .login:
            self.setFirstResponder()
        case .createEvent:
            break
            //TODO: check as configure tap to dismiss may interfere with the table view. Table view keyboard dismissing is currently used.
        }
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    @IBAction func didSelectPageControl(_ sender: Any) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        let frame = CGRect(x: x, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func didPressTopRightButton(_ sender: Any) {
        didPressTopRightButtonAction?()
    }

    @IBAction func didPressNextButton(_ sender: Any) {
        let nextPage = pageControl.currentPage + 1
        
        if nextPage >= pageableViewControllers.count {
            guard let viewModel = viewModel else {
                return
            }
            
            switch viewModel.type.value {
            case .onboarding:
                if viewModel.isInitialOnboardingPresentation {
                    requestPermission(locationManager: locationManager)
                //when presented from settigns
                } else {
                    dismiss(animated: true, completion: nil)
                }
            case .becomeTrainer, .createEvent:
                viewModel.finishAllsteps { [weak self] error in
                    self?.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                }
            case .registration, .login:
                viewModel.finishAllsteps { [weak self] error in
                    guard error == nil else {
                        self?.onLogin?(false)
                        return
                    }
                    
                    self?.dismiss(animated: true) {
                        self?.onLogin?(true)
                    }
                    
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                }
            case .forgottenPassword:
                //do nothing. it's not visible
                break
            }
        } else {
            guard let viewModel = viewModel else {
                return
            }
            switch viewModel.validate(step: pageControl.currentPage){
            case .success():
                pageControl.currentPage = nextPage
                didSelectPageControl(pageControl)
                break
            case .error(let error):
                switch error {
                case .createEvent(let type):
                    validateCreateEventViewController(type: type)
                }
                break
            }
        }
    }
    
    @IBAction func didPressBottomCentralButton(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }
        
        switch viewModel.type.value {
        case  .createEvent:
            view.endEditing(true)
            viewModel.finishAllsteps { [weak self] error in
                
                self?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .refreshData, object: nil)
            }
        default:
            break
        }
    }
    
    func requestPermission(locationManager: CLLocationManager) {
        //add blur
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        //request permissions
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        let previousPage = pageControl.currentPage - 1
        if previousPage >= 0 {
            pageControl.currentPage = previousPage
            didSelectPageControl(pageControl)
        } else {
            if let navigationController = navigationController {
                guard let type = viewModel?.type.value else {
                    return
                }
                
                switch type {
                case .createEvent:
                    navigationController.dismiss(animated: true, completion: nil)
                default:
                    navigationController.popViewController(animated: true)
                }
                
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func validateCreateEventViewController(type:CreateEventRowType) {
        guard let vc = pageableViewControllers[pageControl.currentPage] as? CreateEventStepViewController else {
            return
        }
        vc.validate(by: type)
    }
}

extension StepsFlowViewController: UIScrollViewDelegate {
    //one is for when pressing next the other is for swiping but at the time of writing this I am too lazy to check which is which. Quite sure that I am right though.
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let type = viewModel?.type.value else {
            return
        }
        
        switch type {
        case .registration, .becomeTrainer, .login:
            setFirstResponder()
        case .onboarding, .forgottenPassword:
            break
        case .createEvent:
            setCurrentTitle(page: pageControl.currentPage)
            let shouldShowBottomCentralButton = pageControl.currentPage == pageableViewControllers.count - 1
            bottomCentralButton.isHidden = !shouldShowBottomCentralButton
            nextButton.isHidden = shouldShowBottomCentralButton
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        guard let type = viewModel?.type.value else {
            return
        }
        switch type {
        case .registration, .becomeTrainer, .login:
            setFirstResponder()
        case .onboarding, .forgottenPassword:
            break
        case .createEvent:
            setCurrentTitle(page: pageControl.currentPage)
            let shouldShowBottomCentralButton = pageControl.currentPage == pageableViewControllers.count - 1
            bottomCentralButton.isHidden = !shouldShowBottomCentralButton
            nextButton.isHidden = shouldShowBottomCentralButton
        }
    }
    
    //woraround for setting nav bar title
    fileprivate func setCurrentTitle(page: Int) {
        guard let vc = pageableViewControllers[page] as? CreateEventStepViewController else {
            return
        }
        
        self.title = vc.navTitle
    }
    
    func setFirstResponder() {
        let vc = pageableViewControllers[pageControl.currentPage]
        for textField in vc.view.allSubViews where textField is UITextField {
            textField.becomeFirstResponder()
            return
        }
    }
}

extension StepsFlowViewController: KeyboardScrollViewAvoidable { }
extension StepsFlowViewController: KeyboardDismissible {
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension StepsFlowViewController: Injectable {
    func inject(_ viewModel: StepFlowViewModel) {
        self.viewModel = viewModel
    }
}

extension StepsFlowViewController: MainTabBarPresentable {}

extension StepsFlowViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (UserManager.shared.hasSeenOnboarding() == nil || UserManager.shared.hasSeenOnboarding() == false)
            && status != .notDetermined {
            UserManager.shared.set(isSeenOnboarding: true)
            startMainTabBarController()
        }
    }
}
