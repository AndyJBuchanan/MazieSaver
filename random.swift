//
//  random.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 28/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Foundation

extension Int
{
    static func random() -> Int
    {
        return Int( arc4random() )
    }

    static func random( n: Int ) -> Int
    {
        let r = Int( arc4random() ) % n
        return r
    }

    static func random( min min: Int, max: Int ) -> Int
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

    static func random( min min: CGFloat, max: CGFloat ) -> CGFloat
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

    static func random( min min: Float, max: Float ) -> Float
    {
        return min+( Float.random()*(max-min) )
    }
}

extension CGColor
{
    static func randomColourOpaque() -> CGColor
    {
        let col = CGColorCreateGenericRGB(CGFloat.random(), CGFloat.random(), CGFloat.random(), 1.0 )
        return col
    }
}

