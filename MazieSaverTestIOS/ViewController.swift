//
//  ViewController.swift
//  MazieSaverTestIOS
//
//  Created by Andy Buchanan on 17/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var animationTimer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.startAnimation()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
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

