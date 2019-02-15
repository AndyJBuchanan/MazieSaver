//
//  ViewController.swift
//  MazieSaverTest
//
//  Created by Andy Buchanan on 05/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Cocoa
import ScreenSaver

class ViewController: NSViewController
{
    var animationTimer: Timer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startAnimation()
    }

    override var representedObject: Any?
    {
        didSet
        {
            // Update the view, if already loaded.
            self.startAnimation()
        }
    }

    func startAnimation()
    {
        if ( self.animationTimer != nil )
        {
            return;
        }
        
        if let saver = self.view as? ScreenSaverView
        {
            self.animationTimer = Timer.scheduledTimer( timeInterval: saver.animationTimeInterval, target: saver, selector: #selector(ScreenSaverView.animateOneFrame), userInfo: nil, repeats: true);
        }
    }
    
    func stopAnimation()
    {
        self.animationTimer?.invalidate();
        self.animationTimer = nil;
    }

}

