//
//  CreateEventStepViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 7/18/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import DatePickerCell

class CreateEventStepViewController: UIViewController {
    typealias T = CreateEventStepViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    private let tableViewHardcodedBottomInset: CGFloat = 80
    fileprivate var viewModel: CreateEventStepViewModel?
    
    //thta is done wrong but can't waste time on it now
    var navTitle: String? {
        return viewModel?.title
    }
    
    weak var delegate: ImageSettable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asserDependencies(viewModel: viewModel)
        viewModel?.rows.bind({ (rowtypes) in
            self.tableView.reloadData()
        })
        
        tableView.register(EventDateTableViewCell.self)
        tableView.register(PickerTableViewCell.self)
        tableView.register(ImageSelectionTableViewCell.self)
        tableView.register(StandardCreateEventTableViewCell.self)
        tableView.register(CreateEventMapTableViewCell.self)
        tableView.register(TextViewTableViewCell.self)
        tableView.register(SpecialitiesSelectionTableViewCell.self)
        tableView.register(RepeatingHeaderTableViewCell.self)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.contentInset = UIEdgeInsetsMake(0, 0, tableViewHardcodedBottomInset, 0)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func validate(by type: CreateEventRowType) {
        guard let index = viewModel?.rowIndex(for: type),
              let cell = tableView.cellForRow(at: index) as? ErrorCreateEventTableViewCell else {
            return
        }
        cell.showErrorLabel(with: nil)
    }
}

extension CreateEventStepViewController: Injectable {
    func inject(_ viewModel: CreateEventStepViewModel) {
        self.viewModel = viewModel
    }
}

extension CreateEventStepViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.rows.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = viewModel?.rowType(forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        
        switch type {
        case .imageSelection:
            return tableView.dequeueReusableCell(of: ImageSelectionTableViewCell.self, for: indexPath, configure: { (cell) in
                delegate = cell
                cell.setup(type: .createEvent)
                cell.onImageSelected = { [unowned self] in
                    self.presentPictureSelectionOptions()
                }
                
                cell.onDelteImage = { [unowned self] (id, image) in
                    self.viewModel?.removePicture(currentImageID: id, image: image)
                }
                
                cell.onImageSet = { [unowned self] image in
                    self.viewModel?.addUploadImage(image: image)
                }
            })
        case .description:
            return tableView.dequeueReusableCell(of: TextViewTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.onTextEnter = { [unowned self] text in
                    self.viewModel?.delegate?.enterDescription(description: text)
                }
            })
            
        case .workoutType(let tags):
            return tableView.dequeueReusableCell(of: SpecialitiesSelectionTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.onTagSelection = { [unowned self] tag, isSelected in
                    isSelected
                        ? self.viewModel?.delegate?.addTag(tag: tag)
                        : self.viewModel?.delegate?.removeTag(tag: tag)
                }
                
                cell.onTagAdded = { [unowned self] in
                    self.tableView.reloadData()
                }
                
                cell.setTags(tags: tags)
            })
        case .eventLocationMap:
           return tableView.dequeueReusableCell(of: CreateEventMapTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(type: .eventLocationMap)
                cell.viewModel = self.viewModel
            })
        case .title, .priceFrom, .freeSlots, .date, .time:
            return getStandardCell(tableView: tableView, indexPath: indexPath, type: type)
        case .start(let rowTitle, let mode), .end(let rowTitle, let mode):
            let datePickerCell = DatePickerCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
            datePickerCell.datePicker.datePickerMode = mode
            datePickerCell.dateStyle = DateFormatter.Style.medium
            datePickerCell.timeStyle = (mode == .date) ? .none : .short
            datePickerCell.leftLabel.text = rowTitle
            datePickerCell.leftLabel.font = UIFont.leapsSFFont(size: 17)
            datePickerCell.leftLabel.textColor = .leapsOnboardingBlue
            datePickerCell.tag = indexPath.row
            datePickerCell.delegate = self
            return datePickerCell
        case .repeat(_), .frequency(_):
            return tableView.dequeueReusableCell(of: EventDateTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(type: type)
                cell.viewModel = self.viewModel
            })
        case .dayHeader(let day):
            return tableView.dequeueReusableCell(of: RepeatingHeaderTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(day: day, addBlock: {
                    let picker = PickerDialog(type: type)
                    picker.showAlertPicker(frequencyBlock: nil, timeBlock: { (t, activity) in
                        self.viewModel?.activities.value.append(activity)
                    })
                })
            })
        case .activity(_):
            return tableView.dequeueReusableCell(of: EventDateTableViewCell.self, for: indexPath, configure: { (cell) in
                cell.setup(type: type)
                cell.viewModel = self.viewModel
            })
        }
        
    }
    
    func getStandardCell(tableView: UITableView, indexPath: IndexPath, type: CreateEventRowType) -> UITableViewCell {
        var onTextEnter: ((String) -> Void)? = nil
        
        switch type {
        case .title:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterTitle(title: text)
            }
        case .priceFrom:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterPrice(price: text)
            }
        case .freeSlots:
            onTextEnter = { [unowned self] text in
                self.viewModel?.delegate?.enterFreeSlots(slots: text)
            }
        default:
            break
        }
        return tableView.dequeueReusableCell(of: StandardCreateEventTableViewCell.self, for: indexPath, configure: { (cell) in
            cell.setup(type: type)
            cell.onTextEnter = onTextEnter
        })
    }
}

extension CreateEventStepViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell is DatePickerCell {
            return (cell as! DatePickerCell).datePickerHeight()
        }
        if cell is RepeatingHeaderTableViewCell{
            return 80
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }
        let type = viewModel.rowType(forIndexPath: indexPath)
        switch type {
        case .start, .end:
            let cell = self.tableView.cellForRow(at: indexPath)
            if (cell is DatePickerCell) {
                let datePickerTableViewCell = cell as! DatePickerCell
                datePickerTableViewCell.selectedInTableView(tableView)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            return
        case .frequency(_):
            let picker = PickerDialog(type: type)
            picker.showAlertPicker(frequencyBlock: { (t, frequency) in
                self.viewModel?.frequency.value = frequency
            }, timeBlock: nil)
            return
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else {
            return false
        }
        let type = viewModel.rowType(forIndexPath: indexPath)
        switch type {
        case .activity(_):
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let viewModel = viewModel else {
            return nil
        }
        let type = viewModel.rowType(forIndexPath: indexPath)
        switch type {
        case .activity(let activity):
            let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, index) in
//                viewModel.activities.value.remove
            }
            return [removeAction]
        default:
            return nil
        }
    }
}

extension CreateEventStepViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func presentPictureSelectionOptions() {
        let camera = CameraMenager(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        UIApplication.topViewController()?.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        delegate?.setImage(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateEventStepViewController: DatePickerCellDelegate {
    func datePickerCell(_ cell: DatePickerCell, didPickDate date: Date?) {
        guard let pickedDate = date else {
            return
        }
        if cell.tag == 1 {
            self.viewModel?.delegate?.enterTimeFrom(time: pickedDate)
        }
        if cell.tag == 2 {
            self.viewModel?.delegate?.enterTimeTo(time: pickedDate)
        }
    }
}

class PickerDialog: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: 260, height: 162))
    var type:CreateEventRowType = .time
    var dayRows: [[String]] = []
    
    typealias FrequencyBlockType = (_ type: CreateEventRowType, _ result: Frequency)->Void
    typealias TiemBlockType = (_ type: CreateEventRowType, _ result: Activity)->Void
    var frequencyBlock: FrequencyBlockType?
    var timeBlock: TiemBlockType?
    
    init(type: CreateEventRowType) {
        super.init()
        self.type = type
    }
    
    func showAlertPicker(frequencyBlock:FrequencyBlockType? = nil, timeBlock:TiemBlockType? = nil) {
        self.timeBlock = timeBlock
        self.frequencyBlock = frequencyBlock
        
        var hours: [String] = []
        var minutes: [String] = []
        var i = 0
        while i<60 {
            if i < 24 { hours.append("\(i)") }
            minutes.append("\(i)")
            i = i+1
        }
        dayRows = [hours, minutes, ["-"], hours, minutes]
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        var title = type.titleForRow()
        switch self.type {
        case .frequency(let frequency):
            let index = frequency.array().index(of: frequency) ?? 0
            pickerView.selectRow(index, inComponent: 0, animated: false)
            break
        case .dayHeader(_):
            title = "Start & end hours"
            break
        default:
            break
        }
        
        let alertView = UIAlertController(
            title: title,
            message: "\n\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
        
        alertView.view.addSubview(pickerView)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: didSelectOk(action:))
        alertView.addAction(action)
        
        UIApplication.topViewController()?.present(alertView, animated: false, completion: {
            self.pickerView.frame.size.width = alertView.view.frame.size.width
        })
    }
    
    func didSelectOk(action: UIAlertAction) {
        switch type {
        case .frequency(let frequency):
            let result = frequency.array()[pickerView.selectedRow(inComponent: 0)]
            frequencyBlock?(type, result)
        case .dayHeader(let day):
            let startHour = dayRows[0][pickerView.selectedRow(inComponent: 0)].twoLengthString()
            let startMinutes = dayRows[1][pickerView.selectedRow(inComponent: 1)].twoLengthString()
            let endHour = dayRows[3][pickerView.selectedRow(inComponent: 3)].twoLengthString()
            let endMinutes = dayRows[4][pickerView.selectedRow(inComponent: 4)].twoLengthString()
            let result = Activity(day: day, startHour: startHour, startMinutes: startMinutes, endHour: endHour, endMinutes: endMinutes)
            timeBlock?(type, result)
        default:
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch type {
        case .frequency(_):
            return 1
        case .dayHeader(_):
            return dayRows.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch type {
        case .frequency(let frequency):
            return frequency.array().count
        case .dayHeader(_):
            return dayRows[component].count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch type {
        case .dayHeader(_):
            if component == 2 { return 20 }
            else { return 40 }
        default:
            return pickerView.frame.width
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch type {
        case .frequency(let frequency):
            return frequency.array()[row].rawValue
        case .dayHeader(_):
            return dayRows[component][row]
        default:
            return ""
        }
    }
}
