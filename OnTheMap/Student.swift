//
//  Student.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

struct Student{
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    
    init(dictionary: [String: AnyObject]){
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mapString = dictionary["mapString"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mediaURL = dictionary["mediaURL"] as! String
    }
    
    static var Students: [Student] = [Student]()
    
    static func studentsFromResult(results: [[String: AnyObject]]) ->[Student]{
        var students = [Student]()
        for result in results {
            students.append(Student(dictionary: result))
        }
        //not sure if this is good for now
        self.Students = students
        return students
    }
   
}

extension Student: Equatable {}
    
func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}

