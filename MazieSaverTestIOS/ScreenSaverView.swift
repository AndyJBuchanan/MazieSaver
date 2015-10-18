//
//  ScreenSaverView.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 17/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import UIKit

public class ScreenSaverView : UIView
{
    public init(frame: CGRect, isPreview: Bool)
    {
        super.init(frame: frame)
    }
    public convenience override init(frame: CGRect)
    {
        self.init(frame: frame, isPreview: false )
    }

    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    public var animationTimeInterval: NSTimeInterval = 0.0
    
    public func startAnimation(){}
    public func stopAnimation(){}
    public var animating: Bool = false
    
    public override func drawRect(rect: CGRect){}
    public func animateOneFrame(){}
    
    public func hasConfigureSheet() -> Bool { return false }
    public func configureSheet() -> UIWindow? { return nil }
    
    public var preview: Bool = false
}

