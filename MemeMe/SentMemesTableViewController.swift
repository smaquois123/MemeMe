//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by JC Smith on 4/4/15.
//  Copyright (c) 2015 JC Smith. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    var memes: [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate as AppDelegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }
    
}
