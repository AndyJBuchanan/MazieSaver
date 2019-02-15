//
//  TileSet.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Cocoa

protocol TileRenderer
{
    func renderTileToContext( _ context:CGContext, rect:CGRect, tileID: Int, wallWidth: CGFloat, backColour: CGColor, cellColour:CGColor, wallColour:CGColor ) -> Void
}

class TileSet
{
    // Tile for each Cell configuration
    
    var imageCache: [Int:CGImage] = [:]       // TileID dictionary
    
    func buildTilesWith( _ renderer: TileRenderer, finalWidth:Int, finalHeight:Int, renderedWidth:Int, renderedHeight: Int, wallWidth: CGFloat, backColour: CGColor, cellColour:CGColor, wallColour:CGColor ) -> Bool
    {
        // Builds a new tile set with final dimensions w x h, by scaling tiles
        // of rw x rh rendered by the supplied renderer function. Renderer can use the imageIndex
        // to decide what tile to draw

        // todo: actually use the render size & do a nice filtered downscale. We're just drawing direct to final size at moment..
        
        let colourSpace = CGColorSpace( name: CGColorSpace.genericRGBLinear )
        
        guard let tileContext = CGContext(data: nil, width: finalWidth, height: finalHeight, bitsPerComponent: 8, bytesPerRow: 0, space: colourSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue )
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
            imageCache[ tileID ] = tileContext.makeImage()
        }
        
        // What about releasing these things?
        
        return true
    }
    
}

