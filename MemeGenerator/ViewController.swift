//
//  ViewController.swift
//  MemeGenerator
//
//  Created by Alex Perez on 7/5/16.
//  Copyright © 2016 Alex Perez. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var memeTextField1: UITextField!
    @IBOutlet weak var memeTextField2: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2.0
    ]
    
    struct Meme {
        
        var topText: String!
        var bottomText: String!
        var image:UIImage!
        var memedImage: UIImage!
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        shareButton.enabled = false
        
        
        memeTextField1.enabled = false
        memeTextField2.enabled = false
        
        memeTextField1.delegate = self
        memeTextField2.delegate = self
        
        memeTextField1.textAlignment = .Center
        memeTextField2.textAlignment = .Center
        
        memeTextField1.defaultTextAttributes = memeTextAttributes
        memeTextField2.defaultTextAttributes = memeTextAttributes
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()


    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    //Keyboard Part
    //-----------------------------------------------------------------------------------------------------------------
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillGoAway(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //if memeTextField2.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)/2
        //}
    }
    
    func keyboardWillGoAway(notification: NSNotification){
        //if memeTextField1.isFirstResponder(){
            self.view.frame.origin.y += getKeyboardHeight(notification)/2
        //}
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
        
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    //-----------------------------------------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------------------------------------
    //Image Part
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
            
            //Enable Share and textfields since there is an image in the imageView
            shareButton.enabled = true
            memeTextField1.enabled = true
            memeTextField2.enabled = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //-----------------------------------------------------------------------------------------------------------------

    
    // Create a UIImage that combines the Image View and the Textfields
    //Saving Imae/Sharing
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        
        toolbar.hidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar
        
        toolbar.hidden = false
        return memedImage
    }
    
    func save() {
        //Create the meme
        let meme = Meme(topText: memeTextField1.text!, bottomText: memeTextField2.text!, image: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        //genearate memed image
        let finalImage: UIImage = generateMemedImage()
        
        //define instance of ActivityViewController
        let activityController = UIActivityViewController(activityItems:[finalImage], applicationActivities: nil)
        
        self.save()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //Present the bottom popup of the activity to show options given to the user
        presentViewController(activityController, animated: true, completion: nil)}
    //-----------------------------------------------------------------------------------------------------------------
}

