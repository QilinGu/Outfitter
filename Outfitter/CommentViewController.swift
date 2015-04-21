//
//  CommentViewController.swift
//  Outfitter
//
//  Created by Michael Luo on 4/19/15.
//  Copyright (c) 2015 Outfitter Group. All rights reserved.
//

import UIKit


class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    
    var items: [String] = ["We", "Heart", "Swift"]
    var items2: [String] = ["I", "am", "poop"]
    let basicCellIdentifier = "BasicCell"
    var showDelete:String!
    var comments=[PFObject]()
    var submissionID:String!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        // Do any additional setup after loading the view, typically from a nib.
        //comments=[PFObject]()
        submissionID = self.valueForKey("submissionID") as! String
        showDelete = self.valueForKey("showDelete") as! String
        getComments(callback)
        
    }
    
    func hideButtons(cell:BasicCell)
    {
        if (showDelete == "false")
        {
            cell.deleteButton.hidden=true
            cell.upvoteButton.hidden=false
        }else{
            cell.deleteButton.hidden=false
            cell.upvoteButton.hidden=true
            cell.upvoteCount.hidden=true
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")

    }
    
    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count;
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            return basicCellAtIndexPath(indexPath)
    }
    
    func basicCellAtIndexPath(indexPath:NSIndexPath) -> BasicCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(basicCellIdentifier) as! BasicCell
        cell.subtitleLabel.text = self.comments[indexPath.row]["userId"] as? String
        cell.titleLabel?.text = self.comments[indexPath.row]["comment"] as? String
        cell.commentID = self.comments[indexPath.row].objectId
        cell.getAndSetUpvote()
        hideButtons(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
    func callback()
    {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.reloadTableViewContent()
    }
    
    func reloadTableViewContent() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        })
    }

    
    func getComments(callback:(()->Void)){
        var query = PFQuery(className:"Comment")
        query.whereKey("submissionId", equalTo:submissionID)
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDModeIndeterminate
        loadingNotification.labelText = "Loading Submissions"
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.comments.append(object)
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
    
    @IBAction func done()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addComment()
    {
        var addCommentView = UIAlertView(title: "Add comment", message: "Type comment here", delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Add")
        //var addCommentView = UIAlertView(title: "Add comment", message: "Type comment here", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Submit")

        addCommentView.alertViewStyle = UIAlertViewStyle.PlainTextInput

        addCommentView.show()

    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println("enter alertview")
        if (buttonIndex == 1)
        {
            addComment(alertView.textFieldAtIndex(0)!.text!, submissionId: submissionID, userId: PFUser.currentUser().objectId, callback: nil, filterDictionary: NSDictionary())
        }
    }
    
    // The callback function is optional, it will be called when the comment is finally saved and it will be passed the new comments objectId
    func addComment(commentString:String, submissionId:String, userId:String, callback:((objectId: String)->Void)! = nil, filterDictionary:NSDictionary){

        var newCommentString = filterBadWords(commentString, filterDictionary: filterDictionary)

        var comment = PFObject(className: "Comment")
        comment.setObject(submissionId, forKey: "submissionId")
        comment.setObject(userId, forKey: "userId")
        //comment.setObject(commentString, forKey: "comment")
        comment.setObject(newCommentString, forKey: "comment")

        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDModeIndeterminate
        loadingNotification.labelText = "Saving Comment"
        
        comment.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                if ((callback) != nil){
                    callback(objectId: comment.objectId)
                }
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            } else {
                NSLog("%@", error!)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let alert = UIAlertController(title: "Error", message: "There was an error when submitting your comment...Please try again soon!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            }
        }
    }
    
    
    func filterBadWords(commentString:String, filterDictionary:NSDictionary) -> String{
        var newString = commentString
        for word in filterDictionary.allKeys{
            var filterWord = filterDictionary.objectForKey(word) as! String
            newString = newString.stringByReplacingOccurrencesOfString(word as! String, withString: filterWord, options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        return newString
    }
    
    
}