//
//  FindOnTheMapViewController.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 11/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import UIKit
import CoreLocation

class FindOntTheMapViewController: UIViewController{
    
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnTheMapActivity: UIActivityIndicatorView!
    
    var geocoder: CLGeocoder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        geocoder = CLGeocoder()
        cleanMapView()
    }
    
    private func cleanMapView(){
        locationTextField.text = ""
        findOnTheMapActivity.stopAnimating()
    }
    
    @IBAction func cancelButtonTouch(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        cleanMapView()
    }
    
    
    
    
    @IBAction func findButtonTouch(_ sender: AnyObject) {
        findOnTheMapActivity.startAnimating()
        let location = locationTextField.text!
        if location != ""{
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
                if error != nil{
                    self.displayError("Couldn't recognize the address!")
                    return
                }
                guard let placemarks = placemarks else {
                    self.displayError("Couldn't recognize the address!")
                    return
                }
                let placemark = placemarks[0]
                let latitude = placemark.location!.coordinate.latitude
                let longitude = placemark.location!.coordinate.longitude
                let country = placemark.country
                let state = placemark.administrativeArea
                let city = placemark.locality
                let locationName: String
                if country != nil && city != nil {
                    locationName = city! + ", " + (state != nil && state! != city! && state! != country! ? state! + ", " : "") + country!
                } else {
                    locationName = ""
                    self.displayError("Unable define country and city of provided location!")
                }
                let pin = MapPin(latitude: latitude, longitude: longitude, locationName: locationName)
                self.performSegue(withIdentifier: "shareUrl", sender: pin)
                self.cleanMapView()
            })

        }
        else{
            self.displayError("Location can't be empty")
        }
    }
    
    func displayError(_ errorString: String?) {
        self.findOnTheMapActivity.stopAnimating()
        guard let errorString = errorString else {
            return
        }
        
        let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareUrl" {
            let submitStudentPinVC = segue.destination as! SubmitStudentPinViewController
            let mapPin = sender as! MapPin
            submitStudentPinVC.mapPin = mapPin
        }
    }
    
}
