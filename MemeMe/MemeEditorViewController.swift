//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by JC Smith on 4/2/15.
//  Copyright (c) 2015 JC Smith. All rights reserved.
//
//  This class contains code to manage creating and sending a meme

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - IBOutlet section
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - IBAction section
    
    /* if the user wants an existing image, bring up the photo album */
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        shareButton.enabled = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /* if the camera is available, and the users selects the camera icon, get a live image from it */
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        shareButton.enabled = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        //if(imagePickerView.image != nil){
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.setToolbarHidden(true, animated: false)

            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            self.save(appDelegate)
            var aMeme = appDelegate.memes[appDelegate.memes.count - 1]
        
            if ((appDelegate.memes.last ) != nil){
                var someImage: UIImage = aMeme.memedImage
                let activityVC = UIActivityViewController(activityItems: [someImage], applicationActivities: nil)
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        //}
    }
    
    @IBAction func showSentMemes(sender: AnyObject) {
        let sentMemesVC = SentMemesTableViewController()
        self.presentViewController(sentMemesVC, animated: true, completion: nil)
    }
    
    /* we started ok, so set up the font attrs for the meme, and various textfield attrs */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         * the line: NSForegroundColorAttributeName : UIColor.blackColor(), doesn't appear to have any effect.
         */
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.whiteColor(),
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : NSNumber(float: 3.0)
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.Center
        topTextField.clearsOnBeginEditing = true
        topTextField.borderStyle = UITextBorderStyle.None
        topTextField.delegate = self
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.clearsOnBeginEditing = true
        bottomTextField.borderStyle = UITextBorderStyle.None
        bottomTextField.delegate = self
        
        shareButton.enabled = false
    }
    
    // MARK: - overrides section
    
    /* things are about to start up, so this is a good place to check if a camera is available, and to subscribe to keyboard notifications */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
    }
    
    /* things are closing down, so stop listening for keyboards */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    /* hide the status bar for this viewcontroller */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - controllers section
    
    /* pull up the photo library, assuming the user allowed it */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    /* cancel button was pressed, so dismiss the view */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - keyboard handling section
    
    /* when the keyboard is about to show, this method will be called, and we can adjust the y origin of the image appropriately. */
    func keyboardWillShow(notification: NSNotification){
        if( bottomTextField.editing ){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    /* when the keyboard is about to hide, this method will be called, and we can adjust the y origin back. */
    func keyboardWillHide(notification: NSNotification){
        if( bottomTextField.editing ){
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    /* in order to move the image so we can see it while we're typing, we've gotta know how tall the keyboard is */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    /* sign up to get notified when the keyboard is about to show, and about to hide */
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /* hide the keyboard when the return key is pressed */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    // MARK: - meme handling section
    
    func save(appDelegate: AppDelegate) {
        
        //Hide toolbar and navbar - i think it makes more sense here
        navigationBar.hidden = true
        toolbar.hidden = true
        
        //Create the meme
        var meme = Meme(topMemeText: topTextField.text!, bottomMemeText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        appDelegate.memes.append(meme)
        
        //Unhide bars
        navigationBar.hidden = false
        toolbar.hidden = false
    }
    
    func generateMemedImage() -> UIImage
    {
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
}

