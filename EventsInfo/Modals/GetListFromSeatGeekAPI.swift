//
//  GetListFromSeatGeekAPI.swift
//  EventsInfo
//
//  Created by Tharun Nallamothu on 10/1/18.
//  Copyright © 2018 tharun. All rights reserved.
//

import Foundation

class GetListFromSeatGeekAPI {
    
    ///Request the Events Info based on search text if it's empty it will return all events that are available.
    ///
    ///
    /// - Parameter queryString: search feild text
    
    func getListFromSeatGeekAPI(queryString: String, completionHandler handler: @escaping (Bool,[[String : String]]) -> Swift.Void){
        
        var listDict : [[String : String]] = []
        
        //Getting Baseurl and Clientid from info.plist
        if let baseurl = Bundle.main.infoDictionary?["Baseurl"],  let cleintID = Bundle.main.infoDictionary?["Clientid"] {
            
            // Set up the url based on queryString
            let url: String = "\(baseurl)events?client_id=\(cleintID)&q=\(queryString)"
            
            // Set up the request
            if let urlRequest = URL(string: url as String) {
                
                let urlRequest = URLRequest(url: urlRequest)
                // Set up the session
                let session = URLSession.shared
                let task = session.dataTask(with: urlRequest) { (data, response, error) in
                    
                    guard error == nil else {
                        handler(false,[[:]])
                        return
                    }
                    guard let responseData = data else {
                        handler(false,[[:]])
                        return
                    }
                    //After getting the data retrieving events from it and from each record of event we are retrieving...
                    //
                    //datetime_utc
                    //datetime_local
                    //title
                    //id
                    //venue ->display_location
                    //performers-> image (event logo)
                    do {
                        if let rawJSON = try JSONSerialization.jsonObject(with: responseData, options:[]) as? [String: Any]{
                            if let results = rawJSON["events"] as? [[String: Any]]{
                                for resultSplit in results{
                                    
                                    //eventList dict using to store each record info
                                    var eventList: [String : String] = [:]
                                    
                                    if let datetimeutc = resultSplit["datetime_utc"] as? String{
                                        
                                        eventList["datetime_utc"] = datetimeutc
                                    }
                                    if let datetimelocal = resultSplit["datetime_local"] as? String{
                                        
                                        eventList["datetime_local"] = datetimelocal
                                    }
                                    if let title = resultSplit["title"] as? String{
                                        
                                        eventList["title"] = title
                                    }
                                    if let id = resultSplit["id"] as? Int{
                                        
                                        eventList["id"] = "\(id)"
                                    }
                                    if let venue = resultSplit["venue"] as? [String:Any] {
                                        if let displayLocation = venue["display_location"] as? String{
                                            eventList["display_location"] = displayLocation
                                        }
                                    }else if let venues = resultSplit["venue"] as? [[String:Any]]{
                                        let venue = venues[0]
                                        if let displayLocation = venue["display_location"] as? String{
                                            eventList["display_location"] = displayLocation
                                        }
                                    }
                                    
                                    if let performers = resultSplit["performers"] as? [[String:Any]]{
                                        let performer = performers[0]
                                        if let image = performer["image"] as? String{
                                            eventList["image"] = image
                                        }else{
                                            eventList["image"] = "https://chairnerd.global.ssl.fastly.net/images/performers-landscape/texas-rangers-22f171/16/huge.jpg"
                                        }
                                    }
                                    //Ading each event to listDict
                                    listDict.append(eventList)
                                }
                                //Passing appended list listDict to completion handler
                                handler(true,listDict)
                            }
                        }
                        
                    }catch let error as NSError{
                        print(error)
                    }
                    
                }
                
                task.resume()
            }
        }
    }
    
    
    ///Request the Image data based on url string.
    ///
    /// - Parameter imageString: image url used to retrive image data
    func getImageFromUrl(imageString: String, completionHandler handler: @escaping (Bool,Data) -> Swift.Void){
        if  let url = URL(string: imageString){
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url){
                    //passing image data to completion handler
                    handler(true,data)
                }
                
            }
        }
    }
    
}
