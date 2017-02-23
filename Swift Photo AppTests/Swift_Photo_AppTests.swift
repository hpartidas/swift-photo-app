//
//  Swift_Photo_AppTests.swift
//  Swift Photo AppTests
//
//  Created by Hector Partidas on 2/10/17.
//  Copyright © 2017 Admios. All rights reserved.
//

import XCTest
@testable import Swift_Photo_App

class Swift_Photo_AppTests: XCTestCase {
    
    static let PHOTO_ACTION_PRESSED = "photoActionPressed:"
    
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
        XCTAssertNotNil(self.sut.btnReset)
    }
    
    func testBtnCropShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.btnCrop)
    }
    
    func testBtnBlurShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.btnBlur)
    }
    
    func testBtnContrastShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.btnContrast)
    }
    
    func testBtnShareShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.btnShare)
    }
    
    func testNotificationLabelShouldBeConnected() {
        // then
        XCTAssertNotNil(self.sut.notificationLabel)
    }
    
    func testMainImageViewShouldNotHaveAnImageLoaded() {
        XCTAssertNil(self.sut.mainImageView.image)
    }
    
    func testBtnResetShouldHaveRotateImageAssigned() {
        let currentImage = self.sut.btnReset.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, "icon_rotate"))
    }
    
    func testBtnCropHasShouldHaveCropImageAssigned() {
        let currentImage = self.sut.btnCrop.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, "icon_crop"))
    }
    
    func testBtnBlurShouldHaveBlurImageAssigned() {
        let currentImage = self.sut.btnBlur.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, "icon_blur"))
    }
    
    func testBtnContrastShouldHaveContrastImageAssigned() {
        let currentImage = self.sut.btnContrast.currentImage!
        
        XCTAssertTrue(buttonShouldHaveImage(currentImage, "icon_constrast"))
    }

    // Note: Couldn't find a way to test if the SystemItem is set accordingly
    // Properly seems to be internal and does not have any public getters or setters.
    
//    func testBtnShareSystemItemShouldBeAction() {
//        let currentButton = self.sut.btnShare!
//        let shouldBeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: currentButton.target, action:#selector(ViewController.shareButtonPressed(_:)))
//        shouldBeButton.style = UIBarButtonItemStyle.plain
//        
//        print("============================== \(currentButton.) \(currentButton.action) \(currentButton.style) ==============================")
//        
//        print("============================== \(shouldBeButton.target) \(shouldBeButton.action) \(shouldBeButton.style) ==============================")
//        
//        XCTAssertTrue(currentButton.action == #selector(ViewController.shareButtonPressed(_:)))
//    }
    
    func testBtnResetActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.btnReset!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, type(of: self).PHOTO_ACTION_PRESSED, UIControlEvents.touchUpInside))
    }
    
    func testBtnCropActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.btnCrop!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, type(of: self).PHOTO_ACTION_PRESSED, UIControlEvents.touchUpInside))
    }
    
    func testBtnBlurActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.btnBlur!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, type(of: self).PHOTO_ACTION_PRESSED, UIControlEvents.touchUpInside))
    }
    
    func testBtnContrastActionShouldBePhotoActionPressed() {
        let currentButton = self.sut.btnContrast!
        XCTAssertTrue(buttonShouldHaveAction(currentButton, type(of: self).PHOTO_ACTION_PRESSED, UIControlEvents.touchUpInside))
    }
    
    func testBtnShareActionShouldBeShareButtonPressed() {
        let currentButton = self.sut.btnShare!

        XCTAssertTrue(currentButton.action == #selector(ViewController.shareButtonPressed(_:)))
    }
    
    func testBtnResetShouldRestoreMainImageViewState() {
        guard let mainImage = self.sut.mainImageView.image else {
            XCTFail("Main Image has not been set.")
            return
        }
        
        self.sut.photoActionPressed(self.sut.btnReset)
        
        let mainImageAfterAction = self.sut.mainImageView.image!
        
        XCTAssertTrue(mainImage.isEqual(mainImageAfterAction))
    }
    
    
    // Helper Functions
    
    func buttonShouldHaveImage(_ currentImage: UIImage, _ image: String) -> Bool {
        let shouldBeImage = UIImage(named: image)
        
        return currentImage.isEqual(shouldBeImage)
    }
    
    func buttonShouldHaveAction(_ button: UIButton, _ action: String, _ event: UIControlEvents) -> Bool {
        guard let actions = button.actions(forTarget: self.sut, forControlEvent: UIControlEvents.touchUpInside) else {
            return false
        }
        
        return actions.contains(action)
    }
}
