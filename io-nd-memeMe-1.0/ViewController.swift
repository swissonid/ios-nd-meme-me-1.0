//
//  ViewController.swift
//  io-nd-memeMe-1.0
//
//  Created by Patrice Müller on 11.10.16.
//  Copyright (c) 2016 swissonid. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var innerContainer: UIView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var bottomText: UITextField!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
    
   
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscriptToKeyBoardNotification()
    
        setAllText()
        addDoubleTabRecognizer()
    }
    
    func setAllText(){
        topText.attributedPlaceholder = getPlaceHolder(.placeholder_toptext)
        bottomText.attributedPlaceholder = getPlaceHolder(.placeholder_bottomtext)
        albumButton.title = getString(.label_album)
        cancelBarButton.title = getString(.label_cancel)
    }
    
    func addDoubleTabRecognizer(){
        let doubleTabRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleDoubleTap))
        doubleTabRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTabRecognizer)
    }
    
    func getPlaceHolder(_ placeHolderText: TranslationKey) -> NSAttributedString {
        return NSAttributedString(string:getString(placeHolderText),attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.delegate = self
        bottomText.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        unsubscriptToKeyBoardNotfication()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: false, completion: nil)
        if let picketImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setImage(picketImage)
        }
        
    }
    
    func setImage(_ picketImage: UIImage) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = picketImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    
    func takePictureFrom(sourceType: UIImagePickerControllerSourceType){
        let uiPickerController =  UIImagePickerController()
        uiPickerController.delegate = self
        uiPickerController.sourceType = sourceType
        present(uiPickerController, animated:true, completion:nil)

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscriptToKeyBoardNotification() {
        let center = NotificationCenter.default
        
        center.addObserver(self
            , selector:#selector(ViewController.keyboardWillShow(_:))
            , name: .UIKeyboardWillShow
            , object:nil
        )
        
        center.addObserver(self
            , selector:#selector(ViewController.keyboardDidDisapear(_:))
            , name: .UIKeyboardWillHide
            , object:nil
        )
        
    }
    
    func unsubscriptToKeyBoardNotfication() {
        let center = NotificationCenter.default
        center.removeObserver(self
            , name: .UIKeyboardWillShow
            , object: nil)
        center.removeObserver(self
            , name: .UIKeyboardWillHide
            , object: nil)
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        //view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardDidDisapear(_ notfication: NSNotification) {
        //view.frame.origin.y += getKeyboardHeight(notfication)
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func handleDoubleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            toogleToolbars()
        }
    }
    
    func toogleToolbars(){
        print("try to hide toolbar")
        self.navigationController?.setToolbarHidden(true, animated:true)
    }
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        //render view to an image
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        innerContainer.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        return memedImage;
    }
    

    @IBAction func openAlbum(_ sender: AnyObject) {
        takePictureFrom(sourceType: .photoLibrary)
    }
    
    @IBAction func openCamera(_ sender: AnyObject) {
       takePictureFrom(sourceType: .camera)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        topText.text = nil
        bottomText.text = nil
        imageView.contentMode = .center
        imageView.image = #imageLiteral(resourceName: "image_place_holder")
    }

}
