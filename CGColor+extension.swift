//
//  CGColor+extension.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/02/2019.
//  Copyright © 2019 Andy Buchanan. All rights reserved.
//

#if os(iOS)
    import UIKit
    import CoreGraphics
#else
    import Cocoa
#endif

extension CGColor
{
    static func from_RGBA( red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat ) -> CGColor
    {
        #if os(iOS)
            let col = UIColor( red: red, green: green, blue: blue, alpha: alpha )
            return col.cgColor
        #else
            let col = CGColor( red: red, green: green, blue: blue, alpha: alpha )
            return col
        #endif
    }

//    #if os(iOS)
//    let white: CGColor = UIColor.white.cgColor;  // Extensions cannot store properties. Bah!
//    let black: CGColor = UIColor.black.cgColor;
//    #endif

    static func getWhite() -> CGColor
    {
        #if os(iOS)
        return UIColor.white.cgColor
        #else
        return CGColor.white
        #endif
    }

    static func getBlack() -> CGColor
    {
        #if os(iOS)
        return UIColor.black.cgColor
        #else
        return CGColor.black
        #endif
    }
}

