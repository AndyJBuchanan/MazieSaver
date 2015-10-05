//
//  MazieSaverView.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 05/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Foundation

import Cocoa
import ScreenSaver

class MazieSaverView : ScreenSaverView
{
    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 3.0
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.animationTimeInterval = 3.0
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: NSRect)
    {
        let context: CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        
        let randCol = CGColor.randomColourOpaque()
        
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextSetFillColorWithColor(context, randCol )
        CGContextSetAlpha(context, 1.0)
        CGContextFillRect(context, rect )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            CGContextSetFillColorWithColor(context, CGColor.randomColourOpaque() )
            CGContextSetAlpha(context, 1.0)
            CGContextFillRect(context, CGRect(x: nx, y: ny, width: cellwide, height: cellwide) )
        }
    }
    
    override func animateOneFrame()
    {
        needsDisplay = true
    }
    
}
