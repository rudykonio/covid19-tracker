//
//  FavoritesTableViewController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 08/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class FavoritesTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext
    var favorites:[Favorites]?
    var countriesData:CountriesData?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favTableCell", for: indexPath) as! FavTableCell
        let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [favorites![indexPath.row].id])
        do{
            let locationExtraDataFetched = try?viewContext.fetch(fetchRequest)
            if locationExtraDataFetched!.count == 1{
                if let countryImage = locationExtraDataFetched![0].countryImage{
                    cell.countryFlagIV.image = UIImage(data: countryImage)
                }
            }
        }
        cell.countryNameL.text = favorites![indexPath.row].countryName
        let province = favorites![indexPath.row].province
        if (!province!.isEmpty){
            cell.countryNameL.text?.append(",\(province!)")
        }
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "isFavorite=%d", argumentArray: [true])
        fetchRequest.sortDescriptors = [sort]
        if let favoritesCached = try? viewContext.fetch(fetchRequest){
            favorites = favoritesCached
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let favorites = favorites{
            return favorites.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavTableCell
        cell.contentView.backgroundColor = .systemOrange
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            tableView.deselectRow(at: indexPath, animated: true)
            cell.contentView.backgroundColor = .systemGray6
            let countryDataVC = self.storyboard?.instantiateViewController(withIdentifier: "CountryDataVC") as! CountryDataViewController
            for location in self.countriesData!.locations!{
                if location.country == self.favorites![indexPath.row].countryName! && location.province == self.favorites![indexPath.row].province!{
                    countryDataVC.locationsData = location
                    self.present(countryDataVC, animated: true, completion: nil)
                    break
                }
            }
        }
    }
}
