//
//  TileSet.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

protocol TileRenderer
{
    func renderTileToContext( context:CGContextRef, rect:CGRect, tileID: Int, wallWidth: CGFloat, backColour: CGColorRef, cellColour:CGColorRef, wallColour:CGColorRef ) -> Void
}

class TileSet
{
    // Tile for each Cell configuration
    
    var imageCache: [Int:CGImage] = [:]       // TileID dictionary
    
    func buildTilesWith( renderer: TileRenderer, finalWidth:Int, finalHeight:Int, renderedWidth:Int, renderedHeight: Int, wallWidth: CGFloat, backColour: CGColorRef, cellColour:CGColorRef, wallColour:CGColorRef ) -> Bool
    {
        // Builds a new tile set with final dimensions w x h, by scaling tiles
        // of rw x rh rendered by the supplied renderer function. Renderer can use the imageIndex
        // to decide what tile to draw

        // todo: actually use the render size & do a nice filtered downscale. We're just drawing direct to final size at moment..
        
        //let colourSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGBLinear )
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let tileContext = CGBitmapContextCreate(UnsafeMutablePointer<Void>(), finalWidth, finalHeight, 8, 0, colourSpace, CGImageAlphaInfo.PremultipliedLast.rawValue )
        else
        {
            print("Failed to create bitmap context")
            return false
        }
        
        let adjustedWallWidth = wallWidth
        let tileRect = CGRect(x: 0, y: 0, width: finalWidth, height: finalHeight)
        
        for tileID in Cell.validTileIDs
        {
            renderer.renderTileToContext(tileContext, rect: tileRect, tileID: tileID, wallWidth: adjustedWallWidth, backColour: backColour, cellColour: cellColour, wallColour: wallColour )
            imageCache[ tileID ] = CGBitmapContextCreateImage(tileContext)
        }
        
        // What about releasing these things?
        
        return true
    }
    
}

