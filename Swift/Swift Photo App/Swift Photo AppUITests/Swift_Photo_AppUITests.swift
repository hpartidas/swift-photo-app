//
//  Swift_Photo_AppUITests.swift
//  Swift Photo AppUITests
//
//  Created by Hector Partidas on 2/23/17.
//  Copyright © 2017 Admios. All rights reserved.
//

import XCTest
@testable import Swift_Photo_App

class Swift_Photo_AppUITests: XCTestCase {
    
    var sut: ViewController!
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // Use recording to get started writing UI tests.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
    
    
    // Moved this back to Tests Target due to solution found here: https://github.com/Quick/Quick/issues/415#issuecomment-154757318
    // for the following error:
    /*
        Undefined symbols for architecture x86_64:
        "type metadata accessor for Swift_Photo_App.ViewController", referenced from:
        type metadata accessor for Swift_Photo_App.ViewController! in Swift_Photo_AppUITests.o
        ld: symbol(s) not found for architecture x86_64
        clang: error: linker command failed with exit code 1 (use -v to see invocation)
     */
    func testBtnResetShouldRestoreMainImageViewState() {
        let mainImageView = self.sut.mainImageView!
        let url = URL(fileURLWithPath: TestOptions.url.rawValue)
    
        let loadImageInBackgroundExpectation = expectation(description: "Wait for UIImageView.loadImageInBackground to complete")
    
        mainImageView.loadImageInBackground(url: url) { [weak self] (success, image) in
            if success {
                self!.sut.imageCache.setObject(image!, forKey: url as AnyObject)
                mainImageView.image = image!
                self!.sut.mainPhotoURL = url
            } else {
                XCTFail("Was not able to download image from source.")
            }
            loadImageInBackgroundExpectation.fulfill()
        }
    
        let timeout: TimeInterval = 5
    
        waitForExpectations(timeout: timeout) { error in
            if error != nil {
                XCTFail("Expectation `loadImageInBackgroundExpectation` failed with error: \(error)")
            }
        }
    
        guard let mainImage = self.sut.mainImageView.image else {
            XCTFail("Main Image has not been set.")
            return
        }
    
        self.sut.photoActionPressed(self.sut.resetButton)
    
        let mainImageAfterAction = self.sut.mainImageView.image!
    
        XCTAssertTrue(mainImage.isEqual(mainImageAfterAction))
    }
}

enum TestOptions: String {
    case url = "https://farm1.staticflickr.com/288/19317057739_99ef1262ca_b.jpg"

}
