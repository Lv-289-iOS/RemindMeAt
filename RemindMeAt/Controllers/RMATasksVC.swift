//
//  RMATasksVC.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/7/18.
//  Edited by Artem Rieznikov on 2/13/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "listCell"

class RMATasksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var taskList: Results<RMATask>?
    
    var isEditingMode = false
    
    var currentCreateAction: UIAlertAction!
    
    @IBOutlet weak var taskListsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        readTasksAndUpdateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.calendarNotification()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readTasksAndUpdateUI() {
        taskList = RMARealmManager.getAllTasks()
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - User Actions -
    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if let tasks = taskList {
            if sender.selectedSegmentIndex == 0 {
                self.taskList = RMARealmManager.sortTasksByName(listsTasks: tasks)
            } else {
                self.taskList = RMARealmManager.sortTasksByDate(listsTasks: tasks)
            }
            self.taskListsTableView.reloadData()
        }
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.taskListsTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        displayAlertToAddTask(nil)
    }
    
    // Enable the create action of the alert only if textfield text is not empty
    @objc func listNameFieldDidChange(_ textField: UITextField) {
        self.currentCreateAction.isEnabled = (textField.text?.count)! > 0
    }
    
    func displayAlertToAddTask(_ updatedTask: RMATask!) {
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil {
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let newTaskName = alertController.textFields?.first?.text
            
            if updatedTask != nil {
                // update mode
                RMARealmManager.updateTaskName(updatedTask: updatedTask, taskName: newTaskName!)
                self.readTasksAndUpdateUI()
            } else {
                let newTask = RMATask()
                newTask.name = newTaskName!
                
                newTask.date = NSDate()
                
                let newTag1 = RMATag()
                newTag1.name = "Tag #1"
                
                let newTag2 = RMATag()
                newTag2.name = "Tag #2"
                newTag2.color = UIColor.blue.hexString()
                
                newTask.tags.append(newTag1)
                newTask.tags.append(newTag2)

                newTask.location = RMALocation()
                newTask.location?.name = "Lviv"
                newTask.location?.latitude = 49.8383
                newTask.location?.longitude = 24.0232
                
                RMARealmManager.addTask(newTask: newTask)
                self.readTasksAndUpdateUI()
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(RMATasksVC.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedTask != nil {
                textField.text = updatedTask.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listsTasks = taskList {
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        
        if let list = taskList?[indexPath.row] {
            cell?.textLabel?.text = list.name
            cell?.detailTextLabel?.text = "\(list.tags.count) tags"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            // Deletion will go here
            if let taskToBeDeleted = self.taskList?[indexPath.row] {
                RMARealmManager.deleteTask(taskToBeDeleted: taskToBeDeleted)
                self.readTasksAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            // Editing will go here
            if let taskToBeUpdated = self.taskList?[indexPath.row] {
                self.displayAlertToAddTask(taskToBeUpdated)
            }
        }
        return [deleteAction, editAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedTaskList = self.taskList?[indexPath.row] {
            self.performSegue(withIdentifier: "TaskListVCToNewTaskVC", sender: selectedTaskList)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTaskViewController = segue.destination as! NewTaskViewController
        newTaskViewController.taskToBeUpdated = sender as? RMATask
    }

}
