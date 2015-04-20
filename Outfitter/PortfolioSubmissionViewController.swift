//
//  PortfolioSubmissionViewController.swift
//  Outfitter
//
//  Created by Michael Luo on 4/7/15.
//  Copyright (c) 2015 Outfitter Group. All rights reserved.
//

import UIKit

public class PortfolioSubmissionViewController: UIViewController {
    
    var image:UIImage!
    @IBOutlet var selectedImage:UIImageView!
    var submissionObj:SubmissionObject!
    
    @IBOutlet var outfitType:UISegmentedControl!
    @IBOutlet var genderFeedback:UISegmentedControl!
    var ratings:[PFObject]!
    //var negativeRatings:[PFObject]!
    @IBOutlet var likePercent :UILabel!
    @IBOutlet var dislikePercent :UILabel!
    @IBOutlet var totalRatings :UILabel!
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        image = self.valueForKey("image") as! UIImage
        selectedImage.image = image
        submissionObj = self.valueForKey("submissionObj") as! SubmissionObject
        let articleNum = submissionObj.getArticle()
        
        outfitType.selectedSegmentIndex=articleNum
        outfitType.userInteractionEnabled=false
        
        let maleFeedback = submissionObj.getMaleFeedback() as Bool
        let femaleFeedback = submissionObj.getFemaleFeedback() as Bool
        if (maleFeedback && femaleFeedback){
            genderFeedback.selectedSegmentIndex=0
        }else if (maleFeedback)
        {
            genderFeedback.selectedSegmentIndex=1
        }else if (femaleFeedback)
        {
            genderFeedback.selectedSegmentIndex=2
        }
        genderFeedback.userInteractionEnabled = false
        
        ratings = [PFObject]()
        getImageStats(callback)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePortfolio(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func getStats() -> (liked: Int, disliked: Int){
        var like = 0
        var dislike = 0
        for object in ratings{
            if object.objectForKey("votedYes") as! Bool{
                like += 1
            } else {
                dislike += 1
            }
        }
        return (like, dislike)
    }
    
    public func refreshStats(){
        ratings.removeAll(keepCapacity: false)
        getImageStats(callback)
    }
    
    func callback(){
        NSLog("enter callback")
        var tempStats = getStats()
        var likeCount = tempStats.liked
        var dislikeCount = tempStats.disliked
        if dislikeCount == 0 && likeCount == 0
        {
            likePercent.text = "100"
            dislikePercent.text = "0"
        }
        var likeFloat = Double(likeCount)
        var dislikeFloat = Double(dislikeCount)
        likePercent.text = String(format:"%.2f",likeFloat/(likeFloat+dislikeFloat) * 100)
        dislikePercent.text = String(format:"%.2f",dislikeFloat/(likeFloat+dislikeFloat) * 100)
        totalRatings.text = "Total Ratings: " + String(likeCount+dislikeCount)
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func getImageStats(callback:(()->Void)){
        var query = PFQuery(className:"RatingActivity")
        query.whereKey("submissionId", equalTo:submissionObj.objectID)
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDModeIndeterminate
        loadingNotification.labelText = "Loading Data"
        
        performQuery(query, callback: callback)
        
    }
    
    func performQuery(query:PFQuery, callback:(()->Void)){
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.ratings.append(object)
                    }
                }
                callback()
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
                callback()
            }
        }
    }
}



