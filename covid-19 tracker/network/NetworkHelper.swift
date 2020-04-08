//
//  NetworkHelper.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 02/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import MapKit
import CoreData
class  NetworkHelper {
    private init(){}
    enum Endpoints : String{
        case locationsData = "https://covid-tracker-us.herokuapp.com/v2/locations"
        case locationExtraData = "https://covid-tracker-us.herokuapp.com/v2/locations/%@"
        case countryFlag = "https://countryflags.io/%@/flat/64.png"
    }
    static func fetchLocations(_ viewController:MapViewController){
        let request = URLRequest(url: URL(string: Endpoints.locationsData.rawValue)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                let fetchRequest:NSFetchRequest<Locations_data> = Locations_data.fetchRequest()
                let locationsFetched = try? viewController.viewContext.fetch(fetchRequest)
                if(locationsFetched?.count == 1){
                    if let locationsCachedData = locationsFetched?[0]{
                        handleLocationsData(viewController: viewController,data: Data(locationsCachedData.cached_location_response!.utf8))
                    }
                }
                else{
                    handleNetworkError(viewController: viewController, error: error)
                    viewController.tabBarController?.tabBar.isUserInteractionEnabled = false
                }
                return
            }
            DispatchQueue.main.async{
                viewController.tryAgainBtn.isHidden=true
                
            }
            
            //save in coreData for caching
            DispatchQueue.main.async{
                let strData = String(decoding: data!, as: UTF8.self)
                let fetchRequest:NSFetchRequest<Locations_data> = Locations_data.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [0])
                let locationsFetched = try? viewController.viewContext.fetch(fetchRequest)
                if locationsFetched?.count == 0{
                    let locationsData = Locations_data(context: viewController.viewContext)
                    locationsData.cached_location_response = strData
                }else{
                    locationsFetched![0].cached_location_response = strData
                }
                try? viewController.viewContext.save()
            }
            handleLocationsData(viewController: viewController,data: data!)
        }
        task.resume()
    }
    static func fetchLocationExtraData(_ viewController:CountryDataViewController){
        viewController.activityIndicator.isHidden = false
        let request = URLRequest(url: URL(string: Endpoints.locationExtraData.rawValue.replacingOccurrences(of: "%@", with: String(viewController.locationsData!.id!)))!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [viewController.locationsData!.id!])
                let locationExtraDataFetched = try? viewController.viewContext.fetch(fetchRequest)
                if(locationExtraDataFetched?.count == 1){
                    if let locationExtraDataCached = locationExtraDataFetched?[0],let _ = locationExtraDataCached.cached_location_extra_response{
                        do{
                            let decoder = JSONDecoder()
                            let countryData = try decoder.decode(CountryData.self, from:Data(locationExtraDataCached.cached_location_extra_response!.utf8))
                            DispatchQueue.main.async {
                             viewController.countryFlagIV.image = UIImage(data: locationExtraDataCached.countryImage!)
                            }
                            handleLocationsDataExtra(countryData: countryData, viewController: viewController, data: Data(locationExtraDataCached.cached_location_extra_response!.utf8))
                        }catch{
                            print(error)
                        }
                    }
                    else{
                        handleNetworkError(viewController: viewController, error: error)
                    }
                }else{
                    handleNetworkError(viewController: viewController, error: error)
                }
                return
            }
            DispatchQueue.main.async{
                viewController.tryAgainBtn.isHidden=true
            }
            
            if let countryCode = viewController.locationsData?.country_code{
                let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [viewController.locationsData!.id!])
                let locationExtraDataFetched = try? viewController.viewContext.fetch(fetchRequest)
                if locationExtraDataFetched?.count == 1{
                    if let locationExtraDataCached = locationExtraDataFetched?[0]{
                        if let countryImage = locationExtraDataCached.countryImage{
                            DispatchQueue.main.async {
                             viewController.countryFlagIV.image = UIImage(data: countryImage)
                            }
                        }
                    }
                }else{
                    let imageUrl = URL(string:Endpoints.countryFlag.rawValue.replacingOccurrences(of: "%@", with: "\(countryCode.lowercased())"))
                    viewController.countryFlagIV.load(url: imageUrl!){ data in
                        let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [viewController.locationsData!.id!])
                        let updatedLocationExtraDataFetched = try? viewController.viewContext.fetch(fetchRequest)
                        if let locationExtraDataCached = updatedLocationExtraDataFetched?[0]{
                            locationExtraDataCached.countryImage = data
                            try?viewController.viewContext.save()
                        }
                    }
                }
            }
            
            //save in coreData for caching
            do{
                let decoder = JSONDecoder()
                let countryData = try decoder.decode(CountryData.self, from: data!)
                DispatchQueue.main.async{
                    let strData = String(decoding: data!, as: UTF8.self)
                    let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [countryData.location.id!])
                    let locationsExtraDataFetched = try? viewController.viewContext.fetch(fetchRequest)
                    if locationsExtraDataFetched?.count == 0{
                        let locationsExtraData = Location_extra_data(context: viewController.viewContext)
                        locationsExtraData.cached_location_extra_response = strData
                        locationsExtraData.id = Int32(countryData.location.id!)
                    }else{
                        locationsExtraDataFetched![0].cached_location_extra_response = strData
                    }
                    try? viewController.viewContext.save()
                }

                handleLocationsDataExtra(countryData:countryData,viewController: viewController, data: data!)
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    static func handleNetworkError(viewController:UIViewController,error:Error?){
        if error != nil {
            let alertController = UIAlertController(title: "Network Error", message:  error!.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                DispatchQueue.main.async{
                    alertController.dismiss(animated: true, completion: {
                        switch viewController{
                        case is MapViewController:
                            GeneralHelper.toggleViews(countryDataVC: nil, mapVC: viewController as? MapViewController)
                        case is CountryDataViewController:
                            GeneralHelper.toggleViews(countryDataVC: viewController as? CountryDataViewController, mapVC: nil)
                        default:()
                        }
                    })
                }
            }))
            DispatchQueue.main.async{
                viewController.present(alertController, animated: true, completion: nil)
            }
            return
        }
    }
    
    static func handleLocationsData(viewController:MapViewController,data:Data){
        do{
            let decoder = JSONDecoder()
            let countriesData = try decoder.decode(CountriesData.self, from: data)
            viewController.countriesData = countriesData
            if let locations = countriesData.locations{
                var annotations = [MKPointAnnotation]()
                for location in locations{
                    if let coordinates = location.coordinates,let lat = coordinates.latitude,let long = coordinates.longitude,let country = location.country,let province = location.province,let latest = location.latest,let confirmed = latest.confirmed,let deaths = latest.deaths{
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!,longitude: Double(long)!)
                        annotation.title = "\(country)"
                        if(!province.isEmpty){
                            annotation.title?.append(", \(province)")
                        }
                        var subtitle = "cases:\(confirmed) deceased:\(deaths)"
                        if confirmed>=deaths && confirmed != 0{
                            let deathRatio = Double((Double(deaths)/Double(confirmed)))*100
                            subtitle = "\(subtitle) ratio:\(String(format: "%.2f", deathRatio))%"
                        }
                        annotation.subtitle = subtitle
                        annotations.append(annotation)
                        viewController.latLongToLocationsData["\(lat)_\(long)"] = location
                    }
                }
                DispatchQueue.main.async{
                    viewController.mapView.addAnnotations(annotations)
                    viewController.mapView.isHidden = false
                    viewController.activityIndicator.isHidden = true
                    if let latest = countriesData.latest,let confirmed = latest.confirmed,let deaths = latest.deaths{
                        if confirmed>0{
                            let deathRatio = String(format: "%.2f",Double(Double(deaths)/Double(confirmed))*100)
                            viewController.globalDataTV.text = "Cases:\(confirmed)\nDeceased:\(deaths)\nRatio:\(deathRatio)%"
                        }
                    }
                    viewController.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
        }catch{
            print(error)
        }
    }
    
    static func handleLocationsDataExtra(countryData:CountryData,viewController:CountryDataViewController,data:Data){
        DispatchQueue.main.async {
            if let cases = countryData.location.timelines.confirmed.latest,let deceased = countryData.location.timelines.deaths.latest{
                viewController.casesIV.isHidden = false
                viewController.casesL.text = "\(cases)"
                viewController.deceasedIV.isHidden = false
                viewController.deceasedL.text = "\(deceased)"
                viewController.deathPrecentageIV.isHidden = false
                viewController.deathPrecentageL.text = "\(String(format: "%.2f",Double(Double(deceased)/Double(cases))*100))%"
                let coordinates = viewController.locationsData?.coordinates
                if let coordinates = coordinates,let lat = Double(coordinates.latitude!),let long = Double(coordinates.longitude!){
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let distanceSpan:CLLocationDistance = 1000000
                    let region = MKCoordinateRegion(center: location, latitudinalMeters:distanceSpan , longitudinalMeters: distanceSpan)
                    viewController.mapView.setRegion(region, animated: true)
                    viewController.mapView.isHidden = false
                }
                if let confirmedTimeline = countryData.location.timelines.confirmed.timeline,let deceasedTimeLine = countryData.location.timelines.deaths.timeline{
                    GeneralHelper.configureGraph(cases: confirmedTimeline, deceased: deceasedTimeLine, lineChartView: viewController.linearChartView)
                    viewController.linearChartView.isHidden = false
                }
            }
            viewController.activityIndicator.isHidden = true
        }
    }
}
