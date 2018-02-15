//
//  NewTaskViewController.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController {
    
    var editIsTapped = false
    var taskIdentifier = 0
    
    var tags:[Tag] = []
    var theSubviews:[UIView] = []
    
    let defaultImage = #imageLiteral(resourceName: "defaultPic")
    var name: String?
    var date: NSDate?
    var formattedDate: String?
    var location: String?
    var image: UIImage?
    var descr: String?
    
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
            if taskIdentifier == 0 {
                if name == nil || name?.count == 0 {
                    let alertController = UIAlertController(title: "Empty name field", message: "give a name to the task", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ok", style: .destructive, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: false, completion: nil)
                    editIsTapped = !editIsTapped
                } else {
                    editAndSaveButton.setTitle("edit", for: .normal)
                    addNewTaskToDB()
                }
            }
        }
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations:
            { () -> Void in
                self.tableView.reloadData()
        },
                          completion: nil);
    }
    
    func addNewTaskToDB() {
        let newTask = RMATask()
        newTask.name = name!
        if date != nil {
            newTask.date = date
        }
        if location != nil {
            let newLocation = RMALocation()
            newLocation.latitude = 0.0
            newLocation.longitude = 0.0
            newLocation.radius = 50.0
            newLocation.name = location!
            newTask.location = newLocation
        }
        
        if descr != nil {
            newTask.fullDescription = descr
        }
        
        for tag in tags {
            if tag.isTagChoosen {
                if let rmaTag = RMARealmManager.getTagByName(name: tag.tagName) {
                    newTask.tags.append(rmaTag)
                }
            }
        }
        
        RMARealmManager.addTask(newTask: newTask)
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
        }
        self.tableView.reloadData()
        updateConstraints()
    }
    
    
    func formatDate(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        return dateFormatter.string(from: date as Date)
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
                //                performSegue(withIdentifier: "toCalendar", sender: self)
                print("add date")
            } else if indexPath.row == 2 {
                print("add location")
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
        print("picture tapped")
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
            if !editIsTapped {
                tableView.isUserInteractionEnabled = false
                
            } else {
                tableView.isUserInteractionEnabled = true
            }
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameTVCell
                cell.nameLabel.text = "name: "
                cell.putNameHere.textAlignment = .right
                cell.putNameHere.textContainer.maximumNumberOfLines = 1
                cell.putNameHere.delegate = self
                cell.putNameHere.tag = 1
                if name == nil {
                    cell.putNameHere.text = "put the name for task here"
                    cell.putNameHere.textColor = UIColor.lightGray
                } else {
                    print("the name is'\(String(describing: name))'")
                    cell.putNameHere.text = name
                    cell.putNameHere.textColor = UIColor.black
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
                cell.informationLabel.textAlignment = .right
                cell.fieldNameLabel.text = "date: "
                if date == nil {
                    cell.informationLabel.text = "select date"
                    cell.informationLabel.textColor = UIColor.lightGray
                } else {
                    cell.informationLabel.text = formatDate(date: date!)
                    cell.informationLabel.textColor = UIColor.black
                }
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateOrLocationTVCell
                cell.informationLabel.textAlignment = .right
                cell.fieldNameLabel.text = "location: "
                if location == nil {
                    cell.informationLabel.text = "select location"
                    cell.informationLabel.textColor = UIColor.lightGray
                } else {
                    cell.informationLabel.text = location
                    cell.informationLabel.textColor = UIColor.black
                }
                
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageAndDescr") as! ImageAndDescrTVCell
                cell.descrTextView.text = "information: "
                cell.pictureView.image = image
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(sender:)))
                cell.pictureView.addGestureRecognizer(tapGesture)
                
                if image == nil {
                    cell.pictureView.image = defaultImage
                }
                cell.descrTextView.textAlignment = .right
                cell.descrTextView.delegate = self
                cell.descrTextView.tag = 2
                if descr == nil {
                    cell.descrTextView.text = "put a task description here, if you wish :)"
                    cell.descrTextView.textColor = UIColor.lightGray
                } else {
                    cell.descrTextView.text = descr
                    cell.descrTextView.textColor = UIColor.black
                }
                return cell
            }
            else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as! TagsTVCell
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
            }  else {
                fatalError("wrong cell counter")
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
        rectangle.backgroundColor = color
        rectangle.layer.borderWidth = 1
        rectangle.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        rectangle.layer.cornerRadius = 10
        return rectangle
    }
}

extension NewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if textView.tag == 1 {
            textView.text = name
        } else if textView.tag == 2 {
            textView.text = descr
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 1 {
            name = textView.text
        } else if textView.tag == 2 {
            descr = textView.text
        }
    }
}

