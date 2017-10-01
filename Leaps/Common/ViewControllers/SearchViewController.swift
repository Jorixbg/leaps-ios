//
//  SearchViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/10/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    typealias T = SearchViewModel

    @IBOutlet weak var searchTextField: TextFieldWithImage!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var horizontalSlider: UISlider!
    @IBOutlet weak var maxDistanceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var nextThreeDaysButton: UIButton!
    @IBOutlet weak var nextFiveDaysButton: UIButton!
    @IBOutlet var timePeriodButtons: [UIButton]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextFieldTrailingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    fileprivate var viewModel: SearchViewModel?
    private let searchFieldFinalConstraintValue: CGFloat = 11
    private let cancelButtonWidth: CGFloat = 45
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asserDependencies(viewModel: viewModel)
        collectionView.register(TagCollectionViewCell.self)
        configureToDismissKeyboard()
        searchTextField.set(image: #imageLiteral(resourceName: "find"), enabled: true)
        _ = timePeriodButtons.map {
            $0.setTitleColor(.white, for: .selected)
        }
        searchTextField.delegate = self
        let selector = #selector(changeSearchTerm(sender:))
        searchTextField.addTarget(self, action: selector, for: .editingChanged)
        bindViewModel(viewModel: viewModel)
    }
    
    func changeSearchTerm(sender: UITextField) {
        guard let text = sender.text else {
            return
        }
        
        viewModel?.didEnter(searchTerm: text)
    }
    
    func bindViewModel(viewModel: SearchViewModel?) {
        viewModel?.searchEntry.value.searchDistance = Int(horizontalSlider.value)
        viewModel?.searchEntry.bindAndFire { [unowned self] searchEntry in
            self.searchTextField.text = searchEntry.searchTerm
            self.distanceLabel.text = self.viewModel?.distanceText
            self.horizontalSlider.setValue(Float(searchEntry.searchDistance), animated: false)
            let selectedButton: UIButton
            switch searchEntry.selectionPeriod {
            case .today:
                selectedButton = self.todayButton
            case .inThreeDays:
                selectedButton = self.nextThreeDaysButton
            case .inFiveDays:
                selectedButton = self.nextFiveDaysButton
            }
            
            self.setSelected(isSelected: true, button: selectedButton)
        }
        
        viewModel?.tags.bindAndFire({ [weak self] (tags) in
            self?.collectionView.reloadData()
            guard let height = self?.collectionView.collectionViewLayout.collectionViewContentSize.height else {
                return
            }
            
            self?.collectionViewHeightConstraint.constant = height
            self?.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //workaround to fix cell distribution. Check for better fix if time permits.
        viewModel?.resetSearch()
    }
    
    private func setSelected(isSelected: Bool, button: UIButton) {
        guard  button.isSelected != isSelected else {
            return
        }
        
        button.isSelected = isSelected
        _ = timePeriodButtons.filter {
            $0 != button
            }.map {
                _ = $0.isSelected = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       options: [],
                       animations: {
            [unowned self] in
            self.view.alpha = 1

        },
                       completion: { [weak self] completed in
                        if completed {
                            guard let strongSelf = self else {
                                return
                            }
                            UIView.animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
                                strongSelf.searchTextFieldTrailingConstraint.constant = strongSelf.searchFieldFinalConstraintValue
                                strongSelf.cancelButtonWidthConstraint.constant = strongSelf.cancelButtonWidth
                                strongSelf.view.layoutIfNeeded()
                            }, completion: { (completed) in
                                strongSelf.searchTextField.becomeFirstResponder()
                            })
                        }
        
        })
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.view.isUserInteractionEnabled = false
            self.searchTextFieldTrailingConstraint.constant = 0
            self.cancelButtonWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) { [unowned self] (completed) in
            guard completed else {
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didPressSearch(_ sender: Any) {
        onSearchPressed()
    }
    
    fileprivate func onSearchPressed() {
        viewModel?.search()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didChangeDistance(_ sender: UISlider) {
        viewModel?.searchEntry.value.searchDistance = Int(sender.value)
    }
    
    @IBAction func didPressResetAll(_ sender: Any) {
        viewModel?.resetSearch()
    }
    
    @IBAction func didSelectPeriod(_ sender: UIButton) {
        switch sender {
        case todayButton:
            viewModel?.selectPeriod(period: .today)
        case nextThreeDaysButton:
            viewModel?.selectPeriod(period: .inThreeDays)
        case nextFiveDaysButton:
            viewModel?.selectPeriod(period: .inFiveDays)
        default:
            break
        }
    }
}

extension SearchViewController: KeyboardDismissible {
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SearchViewController: Injectable {
    func inject(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.tags.value.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(of: TagCollectionViewCell.self, for: indexPath) { (cell) in
            guard let tag = viewModel?.tags.value[indexPath.row] else {
                return
            }
            
            cell.setTag(text: tag, color: .white, shouldEnableTap: true, isAlreadySelected: false) { [weak self] (tag, selected) in
                selected ? self?.viewModel?.addToSearch(tag: tag) : self?.viewModel?.removeFromSearch(tag: tag)
            }
        }
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = viewModel?.tags.value[indexPath.row] else {
            return .zero
        }
        //workaround to get the intrinsic size
        let label = TagLabel()
        let topAndBottomInset: CGFloat = 3.5
        label.topInset = topAndBottomInset
        label.bottomInset = topAndBottomInset
        label.text = tag
        label.layoutIfNeeded()
        let size = label.intrinsicContentSize
        
        return size
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSearchPressed()
        
        return true
    }
}
