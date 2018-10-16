//
//  EventCellItem.swift
//  EventsInfo
//
//  Created by Tharun Nallamothu on 10/1/18.
//  Copyright © 2018 tharun. All rights reserved.
//

import UIKit

///Custom cell design to display Events info for every Event
///
///eventName is display name of event
///eventDate is to display date
///eventLocation is to display location of event
///eventLogo is to display event image
///favoriteIcon is to show favorited event
class EventCellItem: UITableViewCell {
    
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLogo: UIImageView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventLogo.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
