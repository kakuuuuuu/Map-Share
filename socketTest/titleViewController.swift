//
//  titleViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/27/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController{
    override func viewDidLoad() {
        self.loginButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "IMG_1972")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        
    }
    @IBOutlet weak var loginButton: UIButton!
}
