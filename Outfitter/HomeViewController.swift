//
//  ViewController.swift
//  Outfitter
//
//  Created by Michael Luo on 2/2/15.
//  Copyright (c) 2015 Outfitter Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PFLogInViewControllerDelegate {
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        // Do any additional setup after loading the view, typically from a nib.
        showLoginView()
        
    }
    
    func showLoginView(){
        if (PFUser.currentUser() == nil) {
            var logInController = PFLogInViewController()
            logInController.fields = (PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.Facebook)
            logInController.delegate=self
            let newLogo = UILabel()
            newLogo.textColor = UIColor.blackColor()
            newLogo.text = "Outfitter"
            newLogo.sizeToFit()
            logInController.logInView.logo=newLogo
            self.presentViewController(logInController, animated:true, completion: nil)
        }
    }
    
    @IBAction func logout(){
        PFUser.logOut()
        var currentUser = PFUser.currentUser() // this will now be nil
        showLoginView()
    }
    
    func logInViewController(controller: PFLogInViewController, didLogInUser user: PFUser!) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(controller: PFLogInViewController) -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

