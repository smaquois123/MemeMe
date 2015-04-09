//
//  AppDelegate.swift
//  MemeMe
//
//  Created by JC Smith on 4/2/15.
//  Copyright (c) 2015 JC Smith. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //used to hold sent memes for storage.
    var memes = [Meme]()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
                
        /* if there are any sent memes, we want to start with the SentMemesTableViewController.  if not, go to the MemeEditorViewController */
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (memes.count > 0){
            var sentMemesTableViewController: SentMemesTableViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SentMemesTableViewController") as! SentMemesTableViewController
            self.window?.rootViewController = sentMemesTableViewController
        }else{
            var memeEditorViewController: MemeEditorViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
            self.window?.rootViewController = memeEditorViewController
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {
        //TODO: good place to write out the memes
    }
}