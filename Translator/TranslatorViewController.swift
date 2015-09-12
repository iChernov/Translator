//
//  ViewController.swift
//  Translator
//
//  Created by IVAN CHERNOV on 11/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import UIKit

class TranslatorViewController: UIViewController, UITextFieldDelegate, UIActionSheetDelegate {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var detectionErrorLabel: UILabel!
    @IBOutlet weak var langChangeHintLabel: UILabel!
    @IBOutlet weak var translationProgressActivityIndicator: UIActivityIndicatorView!
    
    var translator = Translator()
    var internetConnectivityAvailable = true
    
    override func viewDidLoad() {
        self.setTitles()
        self.setupGradient()
        let internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "reachabilityChanged:",
            name: kReachabilityChangedNotification,
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inputTextField.becomeFirstResponder()
        self.removeHints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: custom UI changes
    
    private func setupGradient() {
        let initialCenter = UIColor(hue: 0.45, saturation: 0.5, brightness: 0.9, alpha: 0.5)
        let initialValue = CenterColorGradient(centerColor: initialCenter, hueVariance: 0.2)
        gradientView.gradient = initialValue
    }
    
    private func removeHints() {
        self.delay(3, closure: { () -> () in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.langChangeHintLabel.alpha = 0
                }, completion: { (completed: Bool) -> Void in
                    self.langChangeHintLabel.removeFromSuperview()
            })
        })
    }
    
    private func setTitles() {
        fromButton.setTitle(self.translator.currentSourceLanguage(), forState: .Normal)
        toButton.setTitle(self.translator.currentTargetLanguage(), forState: .Normal)
    }
    
    private func presentImagePicker() {
        
    }
    
    private func presentGradientPicker() {
        
    }
    
    private func blinkGreen() {
        UIView.animateWithDuration(0.3, delay: 1, options: .Repeat | .Autoreverse, animations: { () -> Void in
            UIView.setAnimationRepeatCount(1.5)
            self.inputTextField.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.7)
            }, completion: { (completed: Bool) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.inputTextField.backgroundColor = UIColor.whiteColor()
                })
        })
    }
    
    private func blinkOrange() {
        UIView.animateWithDuration(0.3, delay: 1, options: .Repeat | .Autoreverse, animations: { () -> Void in
            UIView.setAnimationRepeatCount(1.5)
            self.inputTextField.backgroundColor = UIColor(red: 1, green: 0.65, blue: 0, alpha: 0.7)
            }, completion: { (completed: Bool) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.inputTextField.backgroundColor = UIColor.whiteColor()
                })
        })
    }
    
    private func rotateInputField() {
        UIView.animateWithDuration(0.4, delay: 0, options: .Autoreverse, animations: { () -> Void in
        self.inputTextField.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI),0.0,1.0,0.0)
        }, completion: { (completed: Bool) -> Void in
        self.inputTextField.layer.transform = CATransform3DMakeRotation(0,0.0,1.0,0.0)
        })
    }
    
// MARK: UI interactions methods
    
    @IBAction func changeBackground(sender: UIButton) {
        self.inputTextField.resignFirstResponder()
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Set background image", style:UIAlertActionStyle.Default, handler:{ action in
            self.presentImagePicker()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Change background gradient", style:UIAlertActionStyle.Default, handler:{ action in
            self.presentGradientPicker()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel, handler:nil))
        presentViewController(settingsActionSheet, animated:true, completion:nil)
    }
    
    @IBAction func inputTextFieldDidBeginEditing(sender: UITextField) {
        self.errorLabel.text = ""
    }
    
    @IBAction func inputTextFieldEditingChanged(sender: UITextField) {
        self.detectionErrorLabel.text = ""
        if(internetConnectivityAvailable) {
            self.translator.detectLanguage(sender.text, customCompletion: { (err: NSError!, detectedSource: String!, confidence: Float) -> Void in
                if(err != nil) {
                    self.detectionErrorLabel.text = err.localizedDescription
                    return
                } else {
                    self.translator.defSource = detectedSource
                    self.setTitles()
                }
            })
        }
        
        /*
        OFFLINE variation of language detection, works not as good
        
        var textLangToken = CFStringTokenizerCopyBestStringLanguage(sender.text as CFString, CFRangeMake(0, count(sender.text) > 50 ? 50 : count(sender.text)))
        NSLog("Language detected: %@", textLangToken != nil ? String(textLangToken) : "NOT DETECTED")
        */
    }
    
    @IBAction func changeSourceLanguage(sender: UIButton) {
        //not required now, but probably would be used in a future
    }
    
    
    @IBAction func changeTargetLanguage(sender: UIButton) {
    }
    
// MARK: TextField delegate methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.rotateInputField()
        
        if(internetConnectivityAvailable) {
            self.translationProgressActivityIndicator.startAnimating()
            self.translator.translate(textField.text, customCompletion: { (err: NSError!, translation: String!, source: String!) -> Void in
                self.translationProgressActivityIndicator.stopAnimating()
                if(err != nil) {
                    self.blinkOrange()
                    self.errorLabel.text = err.localizedDescription
                    return
                } else {
                    self.blinkGreen()
                    self.translationTextField.hidden = false
                    self.translationTextField.text = translation
                }
            })
        }
        
        textField.resignFirstResponder()
        return true
    }
    
// MARK services methods
    
    private func reachabilityChanged(notice: NSNotification) {
        let reach = notice.object as? Reachability
        if let remoteHostStatus = reach?.currentReachabilityStatus()
        {
            if(remoteHostStatus.value == NotReachable.value)
            {
                internetConnectivityAvailable = false
                errorLabel.text = "Cannot connect to the server. Please check your internet connection"
            }
            else
            {
                internetConnectivityAvailable = true
                errorLabel.text = ""
            }
        }
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

