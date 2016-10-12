//
//  SubmitStudentPinViewController.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 11/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import UIKit
import MapKit

class SubmitStudentPinViewController: UIViewController, MKMapViewDelegate{
    
    var mapPin: MapPin!
    
    @IBOutlet weak var submitUrlText: UITextField!
    @IBOutlet weak var submitMapView: MKMapView!
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        showMapPin()
        cleanSubmitView()
    }
    @IBAction func cancelButtonTouch(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        cleanSubmitView()
    }
    
    private func cleanSubmitView(){
        submitActivityIndicator.stopAnimating()
        submitUrlText.text = ""
    }
    
    @IBAction func submitButtonTouch(_ sender: AnyObject) {
        let url = submitUrlText.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        guard let _ = URL(string: url) else {
            displayMessage("URL is invalid.",okAction: nil)
            return
        }
        mapPin.mediaURL = submitUrlText!.text
        UdacityClient.sharedInstance().postStudentPin(mapPin) { success, errorString in
            DispatchQueue.main.async(execute: {
                if success {
                    self.displayMessage("Your information has been successfully posted!") { (alertAction) in
                        DispatchQueue.main.async(execute: {
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            self.cleanSubmitView()
                        })
                    }
                } else {
                    self.displayMessage(errorString, okAction: nil)
                }
            })
        }
        
    }
    
    func displayMessage(_ message: String?, okAction: ((UIAlertAction) -> Void)?) {
        let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: okAction))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func showMapPin(){
        submitMapView.removeAnnotations(submitMapView.annotations)
        
        let annotation = MKPointAnnotation()
        let latitude = CLLocationDegrees(mapPin.latitude)
        let longitude = CLLocationDegrees(mapPin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.coordinate = coordinate
        
        submitMapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        submitMapView.setRegion(coordinateRegion, animated: true)
    }
    
}
