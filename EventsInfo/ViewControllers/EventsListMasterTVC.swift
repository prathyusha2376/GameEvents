//
//  EventsListMasterTVC.swift
//  EventsInfo
//
//  Created by Tharun Nallamothu on 10/1/18.
//  Copyright © 2018 tharun. All rights reserved.
//

import UIKit

class EventsListMasterTVC: UITableViewController {
    
    //Instance of GetListFromSeatGeekAPI 
    let updatedListInfo = GetListFromSeatGeekAPI()
    //Instance of searchController
    let searchController = UISearchController(searchResultsController: nil)
    
    var teamList = [[String: String]]()
    var filteredTeamList = [[String: String]]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up navigation bar style
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Setting up searchController and searchBar
        self.searchControllerAndBarDisplay()
        
        //Initiating EventCellItem on tableview cell
        self.tableView.register(UINib(nibName: "EventCellItem", bundle: Bundle.main), forCellReuseIdentifier: "EventCellItem")
        
        //Service request to get Event list when viewcontroller loads
        updatedListInfo.getListFromSeatGeekAPI(queryString: "", completionHandler: { (isListAvailable, eventsList :[[String : String]]) in
            if isListAvailable {
                
                self.teamList = eventsList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //bar tint color
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 2.0/255.0, green: 28.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        
        //deselecting cell when comes back from detailedVC
        self.tableView.reloadData()
    }
    
    //status bar style setting it to lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Assigning results before and after filtering
        if isFiltering() {
            return filteredTeamList.count
        }
        
        return teamList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:EventCellItem = self.tableView.dequeueReusableCell(withIdentifier: "EventCellItem", for: indexPath) as! EventCellItem
        
        var event: [String:String] = [:]
        
        //Assigning results before and after filtering
        if isFiltering() {
            if !filteredTeamList.isEmpty {
                event = filteredTeamList[indexPath.row]
            }
        } else {
            event = teamList[indexPath.row]
        }
        
        //Assigning activityIndicator on imageView
        let activityIndicator = UIActivityIndicatorView(frame: cell.eventLogo.bounds)
        activityIndicator.hidesWhenStopped = true
        
        //Assiging data to cell 
        if let dateString = event["datetime_local"]{
            //to get required date formatt
            let date = dateString.dateFormatted(dateString: dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
            cell.eventDate.text = date
        }
        cell.eventName.text = event["title"]
        cell.eventLocation.text = event["display_location"]
        cell.eventLogo.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        if let imageUrl = event["image"]{
            //to get image data
            updatedListInfo.getImageFromUrl(imageString: imageUrl) { (isImageAvailable, data: Data) in
                if isImageAvailable{
                    DispatchQueue.main.async {
                        cell.eventLogo.image = UIImage(data: data)
                        activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
        //Assigning favorite,notFavorite images by checking, it set to be favorite or not before(saving eventId and bool to user defaults will known that event is fav or not)..
        if let teamId = event["id"]{
            let isFavorite = defaults.bool(forKey: teamId)
            if isFavorite{
                cell.favoriteIcon.isHidden = false
            }else{
                cell.favoriteIcon.isHidden = true
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            //Gettting event cell instance
            let cell = tableView.cellForRow(at: indexPath) as! EventCellItem
            
            var event: [String:String] = [:]
            if isFiltering() {
                event = filteredTeamList[indexPath.row]
            } else {
                event = teamList[indexPath.row]
            }
            
            //Passing data from Master to Detailed viewcontroller and preseting deatiled viewcontroller
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "detailedVC") as! EventsListDetailedVC
            controller.eventLocation = cell.eventLocation.text
            controller.eventTime = cell.eventDate.text
            controller.eventImage = cell.eventLogo.image
            controller.eventName = cell.eventName.text
            if let eventId = event["id"]{
                controller.eventId = eventId
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
    }
    
    
    // MARK: - Private instance methods
    
    // Setup the Search Controller
    func searchControllerAndBarDisplay(){
        let sc = searchController
        let searchBar = sc.searchBar
        sc.delegate = self
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchBar.tintColor = UIColor.white
        
        if #available(iOS 11.0, *) {
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 248.0/255.0, alpha: 0.5)
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10
                    backgroundview.clipsToBounds = true
                    
                }
            }
        }
    }
    
    //Service request to get Event list when search bar active with text entered.
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText != " " {
            let convertedSearchText = searchText.replacingOccurrences(of: " ", with: "+")
            
            updatedListInfo.getListFromSeatGeekAPI(queryString: convertedSearchText, completionHandler: { (isListAvailable, eventsList :[[String : String]]) in
                if isListAvailable {
                    
                    self.filteredTeamList = eventsList
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension EventsListMasterTVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension EventsListMasterTVC : UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        // update text color
        searchController.searchBar.textField?.textColor = .white
    }
}

extension UISearchBar {
    
    var textField: UITextField? {
        for subview in subviews.first?.subviews ?? [] {
            if let textField = subview as? UITextField {
                return textField
            }
        }
        return nil
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}

extension Formatter {
    static let date = DateFormatter()
}

extension String {
    //Converting date to required formatt
    func dateFormatted(dateString: String, dateFormat: String) -> String? {
        
        Formatter.date.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        Formatter.date.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = Formatter.date.date(from: dateString)
        Formatter.date.dateFormat = "EEE, dd MMM yyyy hh:mm a"
        Formatter.date.amSymbol = "AM"
        Formatter.date.pmSymbol = "PM"
        let convertedString = "\(Formatter.date.string(from: dateObj!))"
        
        return convertedString
    }
}

