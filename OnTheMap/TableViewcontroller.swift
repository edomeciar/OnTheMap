//
//  TableViewcontroller.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import UIKit

class TableViewControlle: UITableViewController{
    
    
    @IBOutlet var StudentTableView: UITableView!
    
    @IBAction func logoutButtonTouch(_ sender: AnyObject) {
        UdacityClient.sharedInstance().deleteSession{ success, errorString in
            DispatchQueue.main.async(execute: {
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.displayError(errorString)
                }
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UdacityClient.sharedInstance().getUserData(){ (students, error) in
            if let students = students {
                DispatchQueue.main.async {
                    self.StudentTableView.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    func displayError(_ errorString: String?) {
        guard let errorString = errorString else {
            return
        }
        
        let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "StudentTableViewCell"
        let student = Student.Students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell?.textLabel!.text = "\(student.firstName) \(student.lastName)"
        cell?.imageView!.image = UIImage(named: "Pin")
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Student.Students.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSudent = Student.Students[indexPath.row]
        
        guard let url = selectedSudent.mediaURL as? String else {
            print("URL is empty for the selected Student")
            return
        }
        let trimmedUrl = url.trimmingCharacters(in: CharacterSet.whitespaces)
        
        guard let nsurl = URL(string: trimmedUrl) else {
            print("URL is invalid.")
            return
        }
        
        UIApplication.shared.openURL(nsurl)
    }
    
    
}
