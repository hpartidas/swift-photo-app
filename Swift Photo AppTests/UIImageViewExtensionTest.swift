//
//  UIImageViewExtensionTest.swift
//  Swift Photo App
//
//  Created by Hector Partidas on 2/24/17.
//  Copyright © 2017 Admios. All rights reserved.
//

import XCTest
@testable import Swift_Photo_App

class UIImageViewExtensionTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImageShouldDownloadInBackground() {
        let imageView = UIImageView()
        
        let url = URL(string: ImageViewTestOptions.url.rawValue)!
        
        let loadImageInBackgroundExpectation = expectation(description: "Wait for UIImageView.loadImageInBackground to complete")
        
        imageView.loadImageInBackground(url: url) { (success, image) in
            if success {
                imageView.image = image!
            }
            
            loadImageInBackgroundExpectation.fulfill()
        }
        
        let timeout: TimeInterval = 5
        
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                XCTFail("Could not download image @: \(ImageViewTestOptions.url.rawValue), with error: \(error)")
            }
        }
        
        XCTAssertTrue(imageView.image != nil)
    }
    
}

enum ImageViewTestOptions: String {
    case url = "https://farm1.staticflickr.com/288/19317057739_99ef1262ca_b.jpg"
}
