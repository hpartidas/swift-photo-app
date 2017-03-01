//
//  Swift_Photo_AppTests.swift
//  Swift Photo AppTests
//
//  Created by Hector Partidas on 2/10/17.
//  Copyright © 2017 Admios. All rights reserved.
//

import XCTest
@testable import Swift_Photo_App

class ViewControllerTests: XCTestCase {
    // System Under Test
    var sut: ViewController!
    
    override func setUp() {
        super.setUp()

        let sut = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewController") as! ViewController
        
        // This must be invoked in order for the view to load
        // VERY IMPORTANT WHEN TDDing VIEW CONTROLLERS
        sut.view.layoutSubviews()
        
        self.sut = sut
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func testMainImageViewShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.mainImageView)
    }
    
    func testSwipeViewShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.swipeView)
    }
    
    func testToolsViewShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.toolsView)
    }
    
    func testBtnResetShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.resetButton)
    }
    
    func testBtnCropShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.cropButton)
    }
    
    func testBtnBlurShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.blurButton)
    }
    
    func testBtnContrastShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.contrastButton)
    }
    
    func testBtnShareShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.shareButton)
    }
    
    func testNotificationLabelShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.notificationLabel)
    }
    
    func testMainImageViewShouldNotHaveAnImageLoaded() {
        XCTAssertNil(self.sut.mainImageView.image)
    }
    
    func testBtnResetShouldHaveRotateImageAssigned() {
        let currentImage = self.sut.resetButton.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, ViewControllerButtonOptions.resetImage))
    }
    
    func testBtnCropHasShouldHaveCropImageAssigned() {
        let currentImage = self.sut.cropButton.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, ViewControllerButtonOptions.cropImage))
    }
    
    func testBtnBlurShouldHaveBlurImageAssigned() {
        let currentImage = self.sut.blurButton.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, ViewControllerButtonOptions.blurImage))
    }
    
    func testBtnContrastShouldHaveContrastImageAssigned() {
        let currentImage = self.sut.contrastButton.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, ViewControllerButtonOptions.constrastImage))
    }
    
    func testBtnResetActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.resetButton!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, ViewControllerButtonOptions.photoButtonAction, UIControlEvents.touchUpInside))
    }
    
    func testBtnCropActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.cropButton!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, ViewControllerButtonOptions.photoButtonAction, UIControlEvents.touchUpInside))
    }
    
    func testBtnBlurActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.blurButton!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, ViewControllerButtonOptions.photoButtonAction, UIControlEvents.touchUpInside))
    }
    
    func testBtnContrastActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.contrastButton!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, ViewControllerButtonOptions.photoButtonAction, UIControlEvents.touchUpInside))
    }
    
    func testBtnShareActionShouldBeShareButtonPressed() {
        let currentButton = self.sut.shareButton!

        XCTAssertTrue(currentButton.action == #selector(ViewController.shareButtonPressed(_:)))
    }
    
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
        loadMainImageViewImage()
        
        waitForExpectations(timeout: TimeInterval(ViewControllerTestOptions.expectationTimeout.rawValue)!) { error in
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
    
    func testBtnBlurGaussianBlurToMainImageViewPerformance() {
        loadMainImageViewImage()
        
        waitForExpectations(timeout: TimeInterval(ViewControllerTestOptions.expectationTimeout.rawValue)!) { error in
            if error != nil {
                XCTFail("Expectation `loadImageInBackgroundExpectation` failed with error: \(error)")
            }
        }
        
        measure {
            self.sut.photoActionPressed(self.sut.blurButton)
        }
    }
    
    // Helper Functions
    func buttonShouldHaveImage(_ currentImage: UIImage, _ image: ViewControllerButtonOptions) -> Bool {
        let shouldBeImage = UIImage(named: image.rawValue)
        
        return currentImage.isEqual(shouldBeImage)
    }
    
    func buttonShouldHaveAction(_ button: UIButton, _ action: ViewControllerButtonOptions, _ event: UIControlEvents) -> Bool {
        guard let actions = button.actions(forTarget: self.sut, forControlEvent: UIControlEvents.touchUpInside) else {
            return false
        }
        
        return actions.contains(action.rawValue)
    }
    
    func loadMainImageViewImage() {
        let mainImageView = self.sut.mainImageView!
        let url = URL(string: ViewControllerTestOptions.url.rawValue)!
        
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
    }
}

enum ViewControllerButtonOptions: String {
    case photoButtonAction = "photoActionPressed:"
    case resetImage = "icon_rotate"
    case cropImage = "icon_crop"
    case blurImage = "icon_blur"
    case constrastImage = "icon_constrast"
}

enum ViewControllerTestOptions: String {
    case url = "https://farm1.staticflickr.com/288/19317057739_99ef1262ca_b.jpg"
    case expectationTimeout = "5"
}
