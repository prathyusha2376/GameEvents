//
//  EventsListDetailedVC.swift
//  EventsInfo
//
//  Created by Tharun Nallamothu on 10/1/18.
//  Copyright © 2018 tharun. All rights reserved.
//

import UIKit

///EventsListDetailedVC is to show detailed view of each selected event while showing it's image, eventtime and location
class EventsListDetailedVC: UIViewController {
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var timeOfEvent: UILabel!
    @IBOutlet weak var eventLogo: UIImageView!
    var eventLocation: String? = ""
    var eventImage: UIImage? = nil
    var eventTime: String? = ""
    var eventName: String? = ""
    var eventNameString: String? = ""
    var eventId: String = ""
    var favorite = true
    let heart = UIButton(type: .custom)
    let defaults = UserDefaults.standard
    var navBarLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Navigation bar setup with text
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .automatic
        
        //adding label to navbar
        self.deviceOrientationChange()
        //changing lable frame depending on orientation
        self.navigationBarSubView()
        
        //initializing notification for device oreinatation
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        //Assign values to the detailed screen
        self.location.text = eventLocation
        self.timeOfEvent.text = eventTime
        self.eventLogo.image = eventImage
        eventLogo.layer.cornerRadius = 10
        
        //Adding heart Icon to navigationbar rightbarbuttonitem
        self.addHeartIconToBarButtonItem()
        
        //Assigning favorite,notFavorite images to rightbarbuttonitem by checking, it set to be favorite or not before(saving eventId and bool to user defaults will known that event is fav or not)..
        let isFavorite = defaults.bool(forKey: eventId)
        if isFavorite{
            heart.setImage(UIImage(named: "favorite"), for: .normal)
        }else{
            heart.setImage(UIImage(named: "notFavorite"), for: .normal)
        }
    }
    
    //deinializing notification
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navBarLabel.removeFromSuperview()
    }
    
    // MARK: - Private instance methods
    
    //adding label to navigation bar
    func navigationBarSubView(){
        
        if let navigationBar = self.navigationController?.navigationBar {
            
            //triming text if there is any parenthesis
            if let word = eventName{
                if let index = word.range(of: "(")?.lowerBound {
                    let substring = word[..<index]
                    let string = String(substring)
                    eventNameString = string
                }else{
                    eventNameString = word
                }
            }
            navBarLabel.text = eventNameString
            navBarLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            navBarLabel.textColor = UIColor.black
            navBarLabel.numberOfLines = 0
            navBarLabel.sizeToFit()
            
            
            navigationBar.addSubview(navBarLabel)
        }
    }
    
    //oreintation change action by changing navigation bar height
    @objc func deviceOrientationChange() {
        if UIDevice.current.orientation.isLandscape {
            navBarLabel.removeFromSuperview()
            if  let navigationBar = self.navigationController?.navigationBar{
                let firstFrame = CGRect(x: 120, y: navigationBar.frame.height/3, width: navigationBar.frame.width - 240, height: navigationBar.frame.height - (navigationBar.frame.height))
                navBarLabel = UILabel(frame: firstFrame)
            }
            self.navigationBarSubView()
        }else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown{
            navBarLabel.removeFromSuperview()
            if  let navigationBar = self.navigationController?.navigationBar{
                let firstFrame = CGRect(x: 150, y: navigationBar.frame.height/3, width: navigationBar.frame.width - 300, height: navigationBar.frame.height - (navigationBar.frame.height))
                navBarLabel = UILabel(frame: firstFrame)
            }
            self.navigationBarSubView()
        }else {
            navBarLabel.removeFromSuperview()
            if  let navigationBar = self.navigationController?.navigationBar{
                if self.navigationController?.navigationBar.frame.height == 96{
                    let firstFrame = CGRect(x: 50, y: navigationBar.frame.height/2.5, width: navigationBar.frame.width - 100, height: navigationBar.frame.height - (navigationBar.frame.height/2.5))
                    navBarLabel = UILabel(frame: firstFrame)
                }else if self.navigationController?.navigationBar.frame.height == 130{
                    let firstFrame = CGRect(x: 50, y: navigationBar.frame.height/3, width: navigationBar.frame.width - 100, height: navigationBar.frame.height - (navigationBar.frame.height/2.5))
                    navBarLabel = UILabel(frame: firstFrame)
                }
                else{
                    let firstFrame = CGRect(x: 50, y: navigationBar.frame.height - 5, width: navigationBar.frame.width - 100, height: navigationBar.frame.height - (navigationBar.frame.height/2.5))
                    navBarLabel = UILabel(frame: firstFrame)
                }
                
            }
            self.navigationBarSubView()
        }
    }
    
    func addHeartIconToBarButtonItem(){
        
        if favorite {
            heart.setImage(UIImage(named: "notFavorite"), for: .normal)
        } else {
            heart.setImage(UIImage(named: "favorite"), for: .normal)
        }
        
        heart.addTarget(self, action: #selector(self.favoriteButtonTapped(_:)), for: .touchUpInside)
        let favoriteButton = UIBarButtonItem(customView: heart)
        
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    @objc func favoriteButtonTapped(_ heart: UIButton?) {
        if heart?.image(for: .normal)?.isEqual(UIImage(named: "notFavorite")) ?? false {
            // setting local flag and userdefaults
            favorite = false
            defaults.set(true, forKey: eventId)
            
            //chnaging image of barbutton item
            heart?.setImage(UIImage(named: "favorite"), for: .normal)
            
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(0.0)), animations: {
                
                // Heart expands
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.10, animations: {
                    heart?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                })
                
                // Heart contracts.
                UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.25, animations: {
                    heart?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                
            })
        }else{
            // setting local flag and userdefaults
            favorite = true
            defaults.set(false, forKey: eventId)
            
            //chnaging image of barbutton item
            heart?.setImage(UIImage(named: "notFavorite"), for: .normal)
            
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(0.0)), animations: {
                
                // Heart expands
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.10, animations: {
                    heart?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                })
                
                // Heart contracts.
                UIView.addKeyframe(withRelativeStartTime: 0.15, relativeDuration: 0.25, animations: {
                    heart?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                
            })
        }
    }
}

