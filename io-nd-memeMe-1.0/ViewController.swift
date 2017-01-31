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

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!

    private var keyboardIsOpen = false;
    private var currentMeme: Meme? = nil
    private var topTextValue: String?
    private var bottomTextValue: String?
    private var isImageSet = false
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        enableCancelAndShareButton()
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
        isImageSet = true
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    
    func takePictureFrom(sourceType: UIImagePickerControllerSourceType){
        let uiPickerController = UIImagePickerController()
        uiPickerController.delegate = self
        uiPickerController.sourceType = sourceType
        present(uiPickerController, animated:true, completion:nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableCancelAndShareButton()
    }
    
    func enableCancelAndShareButton() {
        let isEnabled = !topText.text!.isEmpty
            || !bottomText.text!.isEmpty
            || isImageSet
        cancelBarButton.isEnabled = isEnabled
        shareButton.isEnabled = isEnabled
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
        if keyboardIsOpen { return }
        if topText.isFirstResponder { return }
        view.frame.origin.y -= getKeyboardHeight(notification)
        keyboardIsOpen = true;
    }
    
    func keyboardDidDisapear(_ notfication: NSNotification) {
        if !keyboardIsOpen { return }
        view.frame.origin.y += getKeyboardHeight(notfication)
        keyboardIsOpen = false
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
        topToolbar.isHidden = !topToolbar.isHidden
        bottomToolbar.isHidden = !bottomToolbar.isHidden
    }
    
    func save() {
        let memedImage = generateMemedImage()
        currentMeme = Meme(topText: topText.text!, bottomText: bottomText.text!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        toogleToolbars();
        //render view to an image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        innerContainer.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toogleToolbars();
        return memedImage;
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        save()
        let memeToShare = [currentMeme?.memedImage]
        let activityUi = UIActivityViewController(activityItems: memeToShare, applicationActivities: nil)
        activityUi.popoverPresentationController?.barButtonItem = sender
        self.present(activityUi,animated:true, completion:nil)
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
        isImageSet = false
        enableCancelAndShareButton()
    }

}
