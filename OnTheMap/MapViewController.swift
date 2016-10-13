//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{

    
    @IBOutlet weak var mapView: MKMapView!
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPins()
    }
    
    func displayError(_ errorString: String?) {
        guard let errorString = errorString else {
            return
        }
        
        let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func loadPins() {
        UdacityClient.sharedInstance().getUserData(){ (students, error) in
            guard let error = error else{
                self.displayError("Loading Students Pins into the map Failed")
                return
            }
            if let students = students {
                var annotations = [MKPointAnnotation]()
                
                for student in Student.Students {
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "Name: \(student.firstName) \(student.lastName)"
                    annotation.subtitle = student.mediaURL
                    annotations.append(annotation)
                }
                
                
                self.mapView.addAnnotations(annotations)
                
            } else {
                self.displayError(error)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    

    
    
    
}
