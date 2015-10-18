//
//  CGRect+extension.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 26/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import CoreGraphics

extension CGRect
{
    static var unit: CGRect { return CGRect(x:0, y:0, width:1, height:1 )  }
    
    func toString() -> String
    {
        return "CGRect( x:\(origin.x) y:\(origin.y) width:\(size.width) height:\(size.height)"
    }
}

