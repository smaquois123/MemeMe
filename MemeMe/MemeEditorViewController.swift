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
    
    // MARK: - IBAction section
    
    /* if the user wants an existing image, bring up the photo album */
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /* if the camera is available, and the users selects the camera icon, get a live image from it */
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveOrSendAction(sender: AnyObject) {
        println(sender.description)
    }
    
    /* we started ok, so set up the font attrs for the meme, and various textfield attrs */
    override func viewDidLoad() {
        super.viewDidLoad()
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
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
        if( bottomTextField.editing )
        {
            //let userInfo = notification.userInfo
            //let keyboardSize = userInfo![ UIKeyboardFrameEndUserInfoKey ] as NSValue
            //self.view.frame.origin.y -= keyboardSize.CGRectValue().height
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    /* when the keyboard is about to hide, this method will be called, and we can adjust the y origin back. */
    func keyboardWillHide(notification: NSNotification){
        if( bottomTextField.editing )
        {
            //let userInfo = notification.userInfo
            //let keyboardSize = userInfo![ UIKeyboardFrameEndUserInfoKey ] as NSValue
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    /* in order to move the image so we can see it while we're typing, we've gotta know how tall the keyboard is */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
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
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    // MARK: - meme handling section
    
    func save() {
        
        // TODO: Hide toolbar and navbar    
        
        //Create the meme
        var meme = Meme(topMemeText: topTextField.text!, bottomMemeText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        appDelegate.memes.append(meme)
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