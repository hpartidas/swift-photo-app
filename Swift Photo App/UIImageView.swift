//
//  UIImageView.swift
//  Swift Photo App
//
//  Created by Hector Partidas on 2/13/17.
//  Copyright © 2017 Admios. All rights reserved.
//

extension UIImageView {
    func loadImageInBackground(url: URL, completion: ((_ success: Bool, _ image: UIImage?) -> ())? = nil) {
        // Nested Function
        // Returns activity to main thread
        func returnToMainThread(activityIndicator: UIActivityIndicatorView, status: Bool, image: UIImage, completion: ((_ success: Bool, _ image: UIImage?) -> ())? = nil) {
            DispatchQueue.main.async { [weak self] in
                if  let view = self {
                    view.image = image
                }
                activityIndicator.removeFromSuperview()
                completion?(status, image)
            }
        }
        
        // Execute in main thread
        let largeSide = max(frame.height, frame.width)
        let loadingSpinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: largeSide, height: largeSide))
        loadingSpinner.activityIndicatorViewStyle = (self.image == nil ? UIActivityIndicatorViewStyle.gray : UIActivityIndicatorViewStyle.white)
        self.addSubview(loadingSpinner)
        
        // Queue in GCD
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let imageData = try Data(contentsOf: url)
                
                guard let downloadedImage = UIImage(data: imageData) else {
                    returnToMainThread(activityIndicator: loadingSpinner, status: false, image: UIImage(named: "icon_empty")!, completion: completion)
                    return
                }
                
                returnToMainThread(activityIndicator: loadingSpinner, status: true, image: downloadedImage, completion: completion)
            } catch let error {
                print("Error loading from URL \(url), \(error.localizedDescription)")
                
                returnToMainThread(activityIndicator: loadingSpinner, status: false, image: UIImage(named: "icon_empty")!, completion: completion)
            }
        }
    }
}
