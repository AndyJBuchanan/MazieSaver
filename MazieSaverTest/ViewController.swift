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
    var animationTimer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startAnimation()
    }

    override var representedObject: AnyObject?
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
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval( saver.animationTimeInterval, target: saver, selector: "animateOneFrame", userInfo: nil, repeats: true);
        }
    }
    
    func stopAnimation()
    {
        self.animationTimer?.invalidate();
        self.animationTimer = nil;
    }

}

