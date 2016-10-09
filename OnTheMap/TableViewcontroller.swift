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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "StudentTableViewCell"
        let student = Student.Students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell?.textLabel!.text = student.firstName
        cell?.imageView!.image = UIImage(named: "Pin")
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Student.Students.count
    }
    
}
