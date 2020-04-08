//
//  ViewController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 02/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController,MKMapViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var globalDataTV: UITextView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    var countriesData:CountriesData?
    var latLongToLocationsData = [String:LocationsData]()
    @IBAction func tryAgainBtnClick(_ sender: Any) {
         NetworkHelper.fetchLocations(self)
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        setZoomLevel()
        NetworkHelper.fetchLocations(self)
    }
}

//map related
extension MapViewController{
    func setZoomLevel(){
        let zoomLevel = 5000000
        let location = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let region = MKCoordinateRegion( center: location, latitudinalMeters: CLLocationDistance(exactly:zoomLevel)!, longitudinalMeters: CLLocationDistance(exactly: zoomLevel)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        configurePinColor(pinAnnotationView: pinView!)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let lat = view.annotation?.coordinate.latitude,let long = view.annotation?.coordinate.longitude{
                if let dicEntry = latLongToLocationsData["\(lat)_\(long)"]{
                    let countryDataVC = self.storyboard?.instantiateViewController(withIdentifier: "CountryDataVC") as! CountryDataViewController
                    countryDataVC.locationsData = dicEntry
                    present(countryDataVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func configurePinColor(pinAnnotationView:MKPinAnnotationView){
        if let pinAnnotation =  pinAnnotationView.annotation, let subtitle = pinAnnotation.subtitle{
            if let _ = (subtitle!.lastIndex(of: ":")),let _ = (subtitle!.lastIndex(of: "%")){
                let deathRatio = Double(subtitle!.components(separatedBy: "ratio:")[1].components(separatedBy: "%")[0])!
                switch deathRatio {
                case 0...1.00:
                    pinAnnotationView.pinTintColor = .systemGreen
                    pinAnnotationView.tintColor = .systemGreen
                case 1.01...5.00:
                    pinAnnotationView.pinTintColor = .systemYellow
                    pinAnnotationView.tintColor = .systemYellow
                case 5.01...100.00:
                    pinAnnotationView.pinTintColor = .systemRed
                    pinAnnotationView.tintColor = .systemRed
                default:
                    pinAnnotationView.pinTintColor = .systemGreen
                    pinAnnotationView.tintColor = .systemGreen
                }
            }
        }
    }
}
//text related
extension MapViewController{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

