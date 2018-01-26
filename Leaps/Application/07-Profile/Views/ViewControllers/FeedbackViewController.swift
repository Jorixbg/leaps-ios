//
//  FeedbackViewController.swift
//  Leaps
//
//  Created by Slav Sarafski on 14/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didCancelSelected(_ sender: UISlider) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didSendSelected(_ sender: UISlider) {
        
    }
}
