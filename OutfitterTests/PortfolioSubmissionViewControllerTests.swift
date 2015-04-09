//
//  PortfolioSubmissionViewControllerTests.swift
//  Outfitter
//
//  Created by Ian Eckles on 4/9/15.
//  Copyright (c) 2015 Outfitter Group. All rights reserved.
//

import UIKit
import XCTest
import Outfitter


class PortfolioSubmissionViewControllerTests: BaseTests {
    var viewController: PortfolioSubmissionViewController!
    
    override func setUp() {
        
        super.setUp();
        
        viewController = storyBoard.instantiateViewControllerWithIdentifier("PortfolioSubmissionViewController") as PortfolioSubmissionViewController
        
        viewController.loadView()
    }
    
    func testViewDidLoad()
    {
        // we only have access to this if we import our project above
        let v = viewController
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(v.view,"Not Nil")
    }
    
    func testUserExists()
    {
        // we only have access to this if we import our project above
        let v = viewController
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(PFUser.currentUser(),"Not Nil")
    }

    func testOpenWithSubmission()
    {
        // we only have access to this if we import our project above
        let v = viewController
        
        let expectation = self.expectationWithDescription("Load submissions")
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(v.view,"Not Nil")
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(PFUser.currentUser(),"Not Nil")
        
        var query = PFQuery(className:"Submission")
        query.whereKey("submittedByUser", equalTo:PFUser.currentUser().username)

        var submissionThing: PFObject!
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        submissionThing = object
                        break
                    }
                    
                    let subObj = SubmissionObject(submissionThing: submissionThing!)
                    v.setValue(subObj, forKey: "submissionObj")
                    XCTAssertTrue(v.valueForKey("submissionObj") as SubmissionObject == subObj, "Correctly passed the submission object")
                    expectation.fulfill()
                }
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
                XCTFail("Could not get the submissions")
            }
        }
        
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            if(error != nil) {
                XCTFail("FAILED due to " + error.description)
            }
        }
    }
    
    func getRatings(obj: PFObject) -> (liked: Int, disliked: Int){
        NSLog("In get ratings")
        var query = PFQuery(className:"RatingActivity")
        query.whereKey("submissionId", equalTo:obj.objectId)
        
        var ratings = [PFObject]()
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        ratings.append(object)
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
        sleep(2)
        var liked = 0
        var disliked = 0
        for rating in ratings {
            if rating.objectForKey("votedYes") as Bool{
                liked += 1
            } else {
                disliked += 1
            }
        }
        return (liked, disliked)
    }
    
    func testCurrentStatisticsAreCorrect()
    {
        // we only have access to this if we import our project above
        let v = viewController
        
        let expectation = self.expectationWithDescription("Load submissions")
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(v.view,"Not Nil")
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(PFUser.currentUser(),"Not Nil")
        
        var query = PFQuery(className:"Submission")
        query.whereKey("submittedByUser", equalTo:PFUser.currentUser().username)
        
        var submissionThing: PFObject!
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        submissionThing = object
                        break
                    }
                    
                    let subObj = SubmissionObject(submissionThing: submissionThing!)
                    v.setValue(subObj, forKey: "submissionObj")
                    v.setValue(UIImage(), forKey: "image")
                    v.viewDidAppear(false)
                    let result = self.getRatings(submissionThing)
                    XCTAssertTrue(v.getLikeCount() == result.liked, "Correct like count")
                    XCTAssertTrue(v.getDislikedCount() == result.disliked, "Correct dislike count")
                    expectation.fulfill()
                }
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
                XCTFail("Could not get the submissions")
            }
        }
        
        self.waitForExpectationsWithTimeout(9.0) { (error) in
            if(error != nil) {
                XCTFail("FAILED due to " + error.description)
            }
        }
    }

}
