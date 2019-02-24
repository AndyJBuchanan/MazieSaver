//
//  random.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 28/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

#if os(iOS)
import UIKit
import CoreGraphics
#else
import Cocoa
import ScreenSaver
#endif

extension Int
{
    static func random() -> Int
    {
        return Int( arc4random() )
    }

    static func random( _ n: Int ) -> Int
    {
        let r = Int( arc4random() ) % n
        return r
    }

    static func random( min: Int, max: Int ) -> Int
    {
        let r = Int( arc4random() ) % (max-min)
        return r + min
    }
}

extension CGFloat
{
    static func random() -> CGFloat
    {
        let r = Double( arc4random() ) / Double( UInt32.max )
        return CGFloat(r)
    }

    static func random( min: CGFloat, max: CGFloat ) -> CGFloat
    {
        return min+( CGFloat.random()*(max-min) )
    }
}

extension Float
{
    static func random() -> Float
    {
        let r = Double( arc4random() ) / Double( UInt32.max )
        return Float(r)
    }

    static func random( min: Float, max: Float ) -> Float
    {
        return min+( Float.random()*(max-min) )
    }
}

extension CGColor
{
    // todo: move to own file
    static func fromRGBA( red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat ) -> CGColor
    {
        #if os(iOS)
            let col = UIColor( red: red, green: green, blue: blue, alpha: alpha )
            return col.cgColor
        #else
            let col = CGColor( red: red, green: green, blue: blue, alpha: alpha )
            return col
        #endif
    }
    
    static func randomColourOpaque() -> CGColor
    {
        #if os(iOS)
            let col = UIColor( red: CGFloat.random(), green: CGFloat.random(), blue: CGFloat.random(), alpha: 1.0 )
            return col.cgColor
        #else
            let col = CGColor( red: CGFloat.random(), green: CGFloat.random(), blue: CGFloat.random(), alpha: 1.0 )
            return col
        #endif
    }
}

