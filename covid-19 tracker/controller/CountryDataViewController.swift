//
//  CountryDataViewController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 03/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import UIKit
import Charts
import MapKit
class CountryDataViewController:UIViewController{
    var locationsData:LocationsData?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBAction func tryAgainBtnClick(_ sender: Any) {
        tryAgainBtn.isHidden = true
        NetworkHelper.fetchLocationExtraData(self)
    }
    @IBOutlet weak var countryFlagIV: UIImageView!
    @IBOutlet weak var casesL: UILabel!
    @IBOutlet weak var deceasedL: UILabel!
    @IBOutlet weak var casesIV: UIImageView!
    @IBOutlet weak var deceasedIV: UIImageView!
    @IBOutlet weak var deathPrecentageIV: UIImageView!
    @IBOutlet weak var deathPrecentageL: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linearChartView: LineChartView!
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkHelper.fetchLocationExtraData(self)

    }
}
