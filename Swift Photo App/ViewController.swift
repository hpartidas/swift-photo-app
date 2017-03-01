//
//  ViewController.swift
//  Swift Photo App
//
//  Created by Hector Partidas on 2/10/17.
//  Copyright © 2017 Admios. All rights reserved.
//

import UIKit
import SwipeView
import FlickrKit
import PREBorderView

class ViewController: UIViewController, UISearchBarDelegate, SwipeViewDelegate, SwipeViewDataSource  {

    // Views
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var toolsView: UIStackView!
    
    // Buttons
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var blurButton: UIButton!
    @IBOutlet weak var contrastButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Labels
    @IBOutlet weak var notificationLabel: UILabel!
    
    // Properties
    lazy var flickr: FlickrKit = {
        let client = FlickrKit.shared()
        client.initialize(withAPIKey: "8a20a8e225d00fa03d1758f3e26b4609", sharedSecret: "d752ff65a5a1a02a")
        return client
    }()
    
    lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        
        return cache
    }()
    
    var photoData: Array<AnyObject>?
    var mainPhotoURL: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add a SearchBar to the TitleView
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 64))
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.isUserInteractionEnabled = true
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.returnKeyType = .search
        searchBar.placeholder = "Search Flickr"
        searchBar.delegate = self

        self.navigationItem.titleView = searchBar
        
        // Disable interface buttons while there are no images
        toggleInterfaceButtons(imageAvailable: false)
        
        swipeView.delegate = self
        swipeView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // add a one-line divider to the top of the tools view
        toolsView.addRetinaPixelBorder(with: .lightGray, at: .top)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let interesting = FKFlickrInterestingnessGetList()
        interesting.per_page = "10"
        
        // Show loading HUD
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading interesting Photos..."
        
        // Call the Flickr API
        flickr.call(interesting) { [weak self] (response, error) in
            if error != nil {
                print("Error getting interesting photos: \(error!.localizedDescription)")
            }
            else
            {
                self!.parsePhotos(response: response!)
            }
            
            // Hide the loading HUD
            DispatchQueue.main.async {
                if let this = self {
                    this.notificationLabel.isHidden = true

                    MBProgressHUD.hide(for: this.view, animated: true)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        imageCache.removeAllObjects()
    }
    
    @IBAction func photoActionPressed(_ sender: UIButton) {
        if sender == resetButton {
            if let cachedImage = imageCache.object(forKey: mainPhotoURL! as AnyObject) as? UIImage {
                mainImageView.image = cachedImage
            }
        }
        else if sender == cropButton {
            mainImageView.image = mainImageView.image?.crop(to: mainImageView.frame.size)
        }
        else if sender == blurButton {
            mainImageView.image = mainImageView.image?.gaussianBlur(withBias: 10)
        }
        else if sender == contrastButton {
            mainImageView.image = mainImageView.image?.contrastAdjustment(withValue: 50.0)
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let objectsToShare = [mainImageView.image!]
        let controller = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
    }
    
    func toggleInterfaceButtons(imageAvailable: Bool) {
        resetButton.isEnabled = imageAvailable
        cropButton.isEnabled = imageAvailable
        blurButton.isEnabled = imageAvailable
        contrastButton.isEnabled = imageAvailable
        shareButton.isEnabled = imageAvailable
    }
    
    func parsePhotos(response: Dictionary<String, Any>) {
        guard let info = response["photos"] as? Dictionary<String, Any> else {
            print("Error parsing photos.")
            return
        }
        
        photoData = info["photo"] as? Array
        
        if Thread.current.isMainThread {
            swipeView.reloadData()
        }
        else
        {
            DispatchQueue.main.async { [weak self] in
                self!.swipeView.reloadData()
            }
        }
    }
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        guard let data = photoData else {
            return 0
        }
        
        return data.count
    }
    
    func swipeView(_ swipeView: SwipeView!, didSelectItemAt index: Int) {
        // Disable controls for a second
        toggleInterfaceButtons(imageAvailable: false)
        
        guard let list = self.photoData else {
            return
        }
        

        guard let item = list[index] as? Dictionary<String, AnyObject>  else {
            return
        }
        
        let url = self.flickr.photoURL(for: FKPhotoSize.large1024, fromPhotoDictionary: item)
        
        // Save the main photo's URL
        mainPhotoURL = url
            
        
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            mainImageView.image = cachedImage
            
            toggleInterfaceButtons(imageAvailable: true)
        }
        else
        {
            mainImageView.loadImageInBackground(url: url) { [weak self] (success, image) in
                if success {
                    self?.imageCache.setObject(image!, forKey: url as AnyObject)
                }
                
                self!.toggleInterfaceButtons(imageAvailable: success)
            }
        }
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {

        guard let list = self.photoData else {
            return nil
        }
        
        guard let item = list[index] as? Dictionary<String, AnyObject> else {
            return nil
        }
        
        let url = self.flickr.photoURL(for: FKPhotoSize.medium640, fromPhotoDictionary: item)
        
        let dimensions = swipeView.frame.height
        let cornerRadius = dimensions/2.0
        let rect = CGRect(x: 0, y: 0, width: dimensions, height: dimensions)
        
        let imageView = UIImageView(frame: rect)
        imageView.layer.cornerRadius = cornerRadius
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            imageView.image = image
        }
        else
        {
            imageView.loadImageInBackground(url: url) { [weak self] (success, image) in
                if success {
                    self?.imageCache.setObject(image!, forKey: url as AnyObject)
                }
            }
        }
        
        return imageView
    }
    
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    let search = FKFlickrPhotosSearch()
    search.text = searchBar.text
    search.per_page = "10"
    
    // Show the loading HUD
    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    hud.label.text = "Searching for \'\(search.text!)\'"
    
    // Call Flickr API
    flickr.call(search) { [weak self] (response, error) in
        if error != nil {
            print("Error getting photos for keyword(s) \(searchBar.text): \(error?.localizedDescription)")
        }
        else
        {
            self?.parsePhotos(response: response!)
        }
        
        // Hide the loading HUD
        DispatchQueue.main.async {
            if let this = self {
                MBProgressHUD.hide(for: this.view, animated: true)
            }
        }
    }
    searchBar.resignFirstResponder();
}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}

