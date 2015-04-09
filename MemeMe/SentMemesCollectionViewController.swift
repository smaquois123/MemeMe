//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by JC Smith on 4/4/15.
//  Copyright (c) 2015 JC Smith. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController:  UICollectionViewController {
    var memes: [Meme]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let object = UIApplication.sharedApplication().delegate as! AppDelegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }
   
    /*
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier
        ("CustomMemeCell", forIndexPath: indexPath) as CustomMemeCell
        let meme = memes[indexPath.item]
        cell.setText(meme.topMemeText, bottomString: meme.bottomMemeText)
        let imageView = UIImageView(image: meme.originalImage)
        cell.backgroundView = imageView
        
        return cell
    }
    */
}