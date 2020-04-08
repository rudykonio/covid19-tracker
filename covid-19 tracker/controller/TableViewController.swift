//
//  TableViewController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 06/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class TableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!
    var countriesData:CountriesData?
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).dataController.viewContext
    var locationsDataFiltered:[LocationsData]?
    var isCurrentlyEditing = false
    var isKeyboardTriggered = false
    var tappedStarIndex:Int?
    var favoritesDic = [Int:Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationsDataFiltered = countriesData?.locations
        //favorites
        for location in locationsDataFiltered!{
            favoritesDic[location.id!] = false
        }
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        if let favorites = try? viewContext.fetch(fetchRequest){
            for favorite in favorites{
                favoritesDic[Int(favorite.id)] = favorite.isFavorite
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotifications()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let locationsDataFiltered = locationsDataFiltered{
            return locationsDataFiltered.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
        cell.favoriteIV.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(starTapped))
        cell.favoriteIV.addGestureRecognizer(tapGesture)
        let province = locationsDataFiltered![indexPath.row].province!
        if (!province.isEmpty){
            cell.countryNameL.text = "\(locationsDataFiltered![indexPath.row].country!),\(province)"
        }else{
            cell.countryNameL.text = "\(locationsDataFiltered![indexPath.row].country!)"
        }
        let fetchRequest:NSFetchRequest<Location_extra_data> = Location_extra_data.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [locationsDataFiltered![indexPath.row].id!])
        do{
            let locationExtraDataFetched = try viewContext.fetch(fetchRequest)
            //already cached
            if locationExtraDataFetched.count == 1{
                if let countryImage = locationExtraDataFetched[0].countryImage{
                    cell.countryFlagIV.image = UIImage(data: countryImage)
                }
            }//cache the image
            else if locationExtraDataFetched.count == 0{
                let locationsExtraData = Location_extra_data(context:viewContext)
                locationsExtraData.id = Int32(locationsDataFiltered![indexPath.row].id!)
                let imageUrl = URL(string:NetworkHelper.Endpoints.countryFlag.rawValue.replacingOccurrences(of: "%@", with: "\(locationsDataFiltered![indexPath.row].country_code!)"))
                cell.countryFlagIV.load(url: imageUrl!){data in
                    locationsExtraData.countryImage = data
                    try?self.viewContext.save()
                }
            }
        }catch{
            print(error)
        }
        
        if let entry = favoritesDic[locationsDataFiltered![indexPath.row].id!]{
         if entry{
                 cell.favoriteIV.image = UIImage(systemName: "star.fill")
             }else{
                 cell.favoriteIV.image = UIImage(systemName: "star")
             }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableCell
        cell.contentView.backgroundColor = .systemOrange
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            tableView.deselectRow(at: indexPath, animated: true)
            cell.contentView.backgroundColor = .systemGray6
            let countryDataVC = self.storyboard?.instantiateViewController(withIdentifier: "CountryDataVC") as! CountryDataViewController
            countryDataVC.locationsData = self.locationsDataFiltered![indexPath.row]
            self.present(countryDataVC, animated: true, completion: nil)
        }
    }
    
    @objc private func starTapped(sender: UITapGestureRecognizer) {
        var isFilledStar = false
        let tapLocation = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id=%d", argumentArray: [locationsDataFiltered![indexPath!.row].id!])
        if let favoritesFetched = try?viewContext.fetch(fetchRequest){
            if favoritesFetched.count == 1{
                let favoriteFetched = favoritesFetched[0]
                favoriteFetched.isFavorite = !favoriteFetched.isFavorite
                isFilledStar = favoriteFetched.isFavorite
            }
            else{
                let favoriteToSave = Favorites(context:viewContext)
                favoriteToSave.id = Int32(locationsDataFiltered![indexPath!.row].id!)
                favoriteToSave.isFavorite = !favoriteToSave.isFavorite
                favoriteToSave.countryName = locationsDataFiltered![indexPath!.row].country!
                favoriteToSave.province = locationsDataFiltered![indexPath!.row].province!
                isFilledStar = favoriteToSave.isFavorite
            }
            try?viewContext.save()
            if (isFilledStar){
                (self.tableView.cellForRow(at: indexPath!) as! TableCell).favoriteIV.image = UIImage(systemName: "star.fill")
                favoritesDic[locationsDataFiltered![indexPath!.row].id!] = true
            }else{
                (self.tableView.cellForRow(at: indexPath!) as! TableCell).favoriteIV.image = UIImage(systemName: "star")
                favoritesDic[locationsDataFiltered![indexPath!.row].id!] = false
            }
        }
    }
}
extension TableViewController{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        locationsDataFiltered = countriesData?.locations
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        locationsDataFiltered = [LocationsData]()
        if searchText.isEmpty {
            locationsDataFiltered = countriesData?.locations
        }else{
            for location in countriesData!.locations!{
                if location.country!.starts(with: searchText){
                    locationsDataFiltered?.append(location)
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isCurrentlyEditing = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isCurrentlyEditing = false
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if isCurrentlyEditing && !isKeyboardTriggered{
            if let keyboardSize: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardSize.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                bottomTableConstraint.constant = bottomTableConstraint.constant+keyboardHeight-searchBar.bounds.height - self.tabBarController!.tabBar.frame.size.height
                tableView.layoutIfNeeded()
                isKeyboardTriggered = true
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if isCurrentlyEditing && isKeyboardTriggered{
            if let keyboardSize: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardSize.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                bottomTableConstraint.constant = bottomTableConstraint.constant-keyboardHeight+searchBar.bounds.height + self.tabBarController!.tabBar.frame.size.height
                tableView.layoutIfNeeded()
                isKeyboardTriggered = false
            }
        }
    }
}

