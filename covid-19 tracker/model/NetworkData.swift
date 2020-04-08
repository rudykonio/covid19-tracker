//
//  Locations.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 02/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation

struct CountriesData:Decodable{
    let latest:LatestGlobalData?
    let locations:[LocationsData]?
}

struct LatestGlobalData:Decodable {
    let confirmed:Int?
    let deaths:Int?
    let recovered:Int?
}

struct Coordinates:Decodable {
    let latitude:String?
    let longitude:String?
}

struct LatestCountryData:Decodable {
    let confirmed:Int?
    let deaths:Int?
    let recovered:Int?
}

struct Confirmed:Decodable {
    let latest:Int?
    let timeline:[String:Int]?
}

struct Deaths:Decodable {
    let latest:Int?
    let timeline:[String:Int]?
}

struct Recovered:Decodable {
    let latest:Int?
    let timeline:[String:Int]?
}

struct Timelines:Decodable {
    let confirmed:Confirmed
    let deaths:Deaths
    let recovered:Recovered
}


struct LocationsData:Decodable {
    let id:Int?
    let country:String?
    let country_code:String?
    let country_population:Int?
    let province:String?
    let last_updated:String?
    let coordinates:Coordinates?
    let latest:LatestCountryData?
}

struct CountryData:Decodable{
    let location:LocationDataWithTimelines
}

struct LocationDataWithTimelines:Decodable{
    let id:Int?
    let country:String?
    let country_code:String?
    let country_population:Int?
    let province:String?
    let last_updated:String?
    let coordinates:Coordinates?
    let latest:LatestCountryData?
    let timelines:Timelines
}
