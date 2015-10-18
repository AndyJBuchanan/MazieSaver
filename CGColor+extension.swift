//
//  CGColor+extension.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 18/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import CoreGraphics

#if os(iOS)
import UIKit
#endif

extension CGColor
{
    static func from_rgb( red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat ) -> CGColor
    {
        #if os(iOS)
            return UIColor( red: red, green: green, blue: blue, alpha: alpha ).CGColor
        #else
            return CGColorCreateGenericRGB( red, green, blue, alpha )
        #endif
    }
}



