//
//  ViewController.swift
//  Notes
//
//  Created by Francisco Ragland Jr on 10/24/16.
//  Copyright © 2016 Francisco Ragland Jr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var noteField: UITextView!
    var visualEffectView: UIVisualEffectView!
    var noteFieldIsUp = false
    var animationRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newNote))
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(toolbar)
        
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let dismissNoteFieldGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissNoteField))
        view.addGestureRecognizer(dismissNoteFieldGestureRecognizer)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func newNote() {
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = view.bounds
        visualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        view.addSubview(visualEffectView)
        
        noteField = UITextView(frame: CGRect(x: 0, y: -self.view.frame.height, width: self.view.frame.width * 0.9 , height: (self.view.frame.height) - (self.navigationController!.navigationBar.frame.height) - (UIApplication.shared.statusBarFrame.height) * 2))
        noteField.center.x = view.center.x
        noteField.layer.cornerRadius = 10
        noteField.clipsToBounds = true
        noteField.alpha = 0.8
        
        view.addSubview(noteField)
        
        doAnimation()
    }
    
    func dismissNoteField() {
        guard animationRunning == false else { return }
        if noteFieldIsUp {
            doAnimation()
        }
    }
    
    func doAnimation() {
        
        UIView.animate(withDuration: 0.66, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 3, options: [], animations: { [unowned self] in
            switch self.noteFieldIsUp {
            case false:
                
                self.animationRunning = true
                
                self.noteField.transform = CGAffineTransform(translationX: 0, y: (self.view.bounds.height) + self.navigationController!.navigationBar.frame.height + (UIApplication.shared.statusBarFrame.height) * 1.5)
                self.noteField.becomeFirstResponder()
                
                self.noteFieldIsUp = true
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            case true:
                
                self.animationRunning = true
                
                self.noteField.resignFirstResponder()
                self.noteFieldIsUp = false
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }) { [unowned self] (completed: Bool) in
            
            if self.noteFieldIsUp == true {
                self.animationRunning = false
            }

            if self.noteFieldIsUp == false {
                for subView in self.view.subviews {
                    if subView is UIVisualEffectView {
                        UIView.animate(withDuration: 0.66, animations: {
                            subView.alpha = 0
                            self.noteField.transform = CGAffineTransform.identity
                            self.animationRunning = false
                        }) { (completed: Bool) in
                            //Save the note here
                            subView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            noteField.contentInset = UIEdgeInsets.zero
        } else {
            noteField.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        noteField.scrollIndicatorInsets = noteField.contentInset
        
        let selectedRange = noteField.selectedRange
        noteField.scrollRangeToVisible(selectedRange)
        
    }
}

