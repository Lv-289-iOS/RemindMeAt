//
//  NewTaskViewController.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController {

    var name = "testName"
    var date = "09-Feb-2018 10:00"
    let location = "Lviv, Pasternaka str, 5"
    let image = #imageLiteral(resourceName: "paper2")
    var descr = "full information"
    var editIsTapped = false
    var taskIdentifier = 0
    var tags:[Tag] = []
    var theSubviews:[UIView] = []
    var picker:UIImagePickerController?=UIImagePickerController()
    
    @IBOutlet weak var editAndSaveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var tagViewSelectButton: UIButton!
    
    @IBOutlet weak var tagViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTagViewConstraint: NSLayoutConstraint!
    
    func addTags() {
        tags.append(Tag(tagName: "holidays", tagColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "home", tagColor: #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "shopping", tagColor: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "family", tagColor: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "rest", tagColor: #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "studying", tagColor: #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), isTagChoosen: false))
        tags.append(Tag(tagName: "other", tagColor: #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1), isTagChoosen: false))
    }
    
    @IBAction func saveEditButton(_ sender: UIButton) {
        editIsTapped = !editIsTapped
        if (editIsTapped) {
            editAndSaveButton.setTitle("save", for: .normal)
        } else {
             editAndSaveButton.setTitle("edit", for: .normal)
        }
        
        /* Example how to add a new task - start */
        let newTask = RMATask()
        newTask.name = "Call Artem" // TODO: cell.putNameHere.text
        
        let newLocation = RMALocation()
        newLocation.latitude = 49
        newLocation.longitude = 34
        newLocation.radius = 20.5
        newLocation.name = "Somewhere"
        newTask.location = newLocation
        
        let newTag1 = RMATag()
        let newTag2 = RMATag()

        newTag1.name = "Home"
        newTag1.color = UIColor.red.hexString()
        
        newTag2.name = "Work"
        newTag2.color = UIColor.blue.hexString()
        
        newTask.tags.append(newTag1)
        newTask.tags.append(newTag2)
        
        RMARealmManager.addTask(newTask: newTask)
        /* Example how to add a new task - end */
        
        UIView.transition(with: tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations:
            { () -> Void in
                self.tableView.reloadData()
        },
                                  completion: nil);
    }
    
    
    
    @IBAction func saveTagsButton(_ sender: UIButton) {
         bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    func updateConstraints() {
        tagTableView.rowHeight = 60
                    tagTableViewHeightConstraint.constant = tagTableView.rowHeight * CGFloat(tags.count)
            self.tagTableView.layoutIfNeeded()
        bottomTagViewConstraint.constant = -tagViewHeightConstraint.constant
            self.tagView.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tagTableView.delegate = self
        tagTableView.dataSource = self
        
        tagTableView.layer.cornerRadius = 15
        tagView.layer.cornerRadius = 30
        tagViewSelectButton.layer.cornerRadius = 15
        tableView.rowHeight = UITableViewAutomaticDimension
        addTags()
        if !(taskIdentifier == 0) {
            editIsTapped = false
            editAndSaveButton.setTitle("edit", for: .normal)
        } else {
            editIsTapped = true
            editAndSaveButton.setTitle("save", for: .normal)
            name = ""
            descr = ""
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
            date =  dateFormatter.string(from: currentDate)
        }
        self.tableView.reloadData()
        
        updateConstraints()
        
    }
    
    @objc func dateFromCalendar(_ notification: NSNotification) {
        
        if let pickedDate = notification.userInfo?["date"] as? String {
            print(pickedDate)
            date = pickedDate
            self.tableView.reloadData()
        }
       // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationName"), object: nil)
    }
    
    func cameraGalery() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            print("Camera choosen")
            self.openCamera()
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Galery", style: .default) { action -> Void in
            print("Galery choosen")
            self.openGallary()
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let newimage = info[UIImagePickerControllerOriginalImage] as? UIImage{
//            picker.dismiss(animated: true, completion: nil)
//         }
        print("it have to store image in local var")
        
    }
    func openGallary()
    {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension NewTaskViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if indexPath.row == 1 {
            } else if indexPath.row == 2 {
                print("put segue here")
                // Yura, performSegue here
            } else if indexPath.row == 4 {
                bottomTagViewConstraint.constant = 0
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneTagCell") as! TagScreenTVCell
            let oneTag = tags[indexPath.row]
            tags[indexPath.row].isTagChoosen = !oneTag.isTagChoosen
            if (tags[indexPath.row].isTagChoosen) {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "check")
            } else  {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "uncheck")
            }
            tagTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        
    }
    
    @objc func imgTapped(sender: UITapGestureRecognizer) {
        cameraGalery()
    }
    
}

extension NewTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return 5
        }
        if tableView == self.tagTableView {
            return tags.count
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if indexPath.row == 0 {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameTVCell
            cell.nameLabel.text = "name: "
            if !editIsTapped {
                cell.isUserInteractionEnabled = false
                cell.putNameHere.text = name
            } else {
                cell.putNameHere.text = name
                cell.isUserInteractionEnabled = true
              //  cell.putNameHere.addTarget(self, action: #selector(nameFieldDidChange(_:)), for: .editingChanged)
//                cell.putNameText.borderStyle = .none
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
            if !editIsTapped {
                cell.isUserInteractionEnabled = false
            } else {
                cell.isUserInteractionEnabled = true
            }
            cell.fieldNameLabel.text = "date: "
            cell.informationLabel.text = date
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
                if !editIsTapped {
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                }
            cell.fieldNameLabel.text = "location: "
            cell.informationLabel.text = location
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageAndDescr") as! ImageAndDescrTVCell
            cell.descrTextView.text = "information: "
            cell.pictureView.image = image
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
            cell.pictureView.addGestureRecognizer(tapGesture)
            if !editIsTapped {
                cell.isUserInteractionEnabled = false
                cell.descrTextView.text = descr
            }  else {
                cell.isUserInteractionEnabled = true
                cell.descrTextView.text = descr
//                cell.textField.borderStyle = .none
//                cell.textField.addTarget(self, action: #selector(descriptionFieldDidChange(_:)), for: .editingChanged)
                cell.pictureView.isUserInteractionEnabled = true
//                cell.textField.isEnabled = true
//                cell.textField.isHidden = false
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as! TagsTVCell
                if !editIsTapped {
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                }
                for cellSubview in cell.subviews{
                    if cellSubview != cell.tagesLabel && cellSubview != cell.contentView {
                        cellSubview.removeFromSuperview()
                    }
                }
                cell.tagesLabel.text = "tags: "
                var i: CGFloat = 1
                for tag in tags {
                    if tag.isTagChoosen {
                        theSubviews.append(drawSquare(frameWidth: cell.frame.width, number: i, color: tag.tagColor))
                        cell.addSubview(drawSquare(frameWidth: cell.frame.width, number: i, color: tag.tagColor))
                        i += 1
                    }
                }
            return cell
        }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneTagCell") as! TagScreenTVCell
            let tagForCell = tags[indexPath.row]
            cell.tagColorView.layer.cornerRadius = 15
            cell.tagColorView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.tagColorView.layer.borderWidth = 2
            cell.tagColorView.backgroundColor = tagForCell.tagColor
            cell.tagLabel.text = tagForCell.tagName
            if (tagForCell.isTagChoosen) {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "check")
            } else  {
                cell.tagIsChoosePic.image = #imageLiteral(resourceName: "uncheck")
            }
            return cell
        }
    }
    
    func drawSquare(frameWidth: CGFloat, number: CGFloat, color: UIColor) -> UIView {
        let size: CGFloat = 20
        let space: CGFloat = 5
        let rectangle = UIView(frame: CGRect(x: frameWidth - (size * number) - (space * number), y: 12, width: size, height: size))
//        let rectangle = UIView(frame: CGRect(x: frameWidth - 20 - ( space * number), y: 12, width: size, height: size))
        rectangle.backgroundColor = color
        rectangle.layer.borderWidth = 1
        rectangle.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        rectangle.layer.cornerRadius = 10
        return rectangle
    }
    
    @objc func descriptionFieldDidChange(_ textField: UITextField) {
        descr = textField.text!
    }
    
    @objc func nameFieldDidChange(_ textField: UITextField) {
        name = textField.text!
    }
}
