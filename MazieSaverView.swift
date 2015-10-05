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
        
        DEBUG_ShowSomething(context, rect: rect)

        if ( renderer==nil )
        {
            renderer = BasicTileRenderer()
        }
        
        DEBUG_ShowTiles(context, rect: rect)
        
        DrawMaze(context, rect: rect)
    }
    
    override func animateOneFrame()
    {
        newMaze()
        needsDisplay = true
    }
    
    func newMaze()
    {
        // Force regeneration of maze
        maze = nil
        needsDisplay = true;
    }

    var maze: Maze?
    var lastMazeRect = CGRect.zero

    let backCol = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)
    var cellCol = CGColorCreateGenericRGB( 1.0, 1.0, 0.0, CGFloat(1.0) )
    var wallCol = CGColorCreateGenericRGB( 0.0, 0.0, 1.0, CGFloat(1.0) )
    var solveCol = CGColorCreateGenericRGB( 1.0, 0.0, 1.0, CGFloat(1.0) )
    var vistedCol = CGColorCreateGenericRGB( 0.45, 0.0, 0.25, CGFloat(1.0) )
    
    var wallThickness:CGFloat = 0.2

    var renderer: BasicTileRenderer?
    
    private func DrawMaze( context: CGContextRef, rect: CGRect )
    {
        // Regenerate the maze if required
        if ( maze == nil ) || ( lastMazeRect != rect )
        {
            maze = Maze()
            
            let rdim = floor( CGFloat.random( min: 6.0, max: min(rect.width/20.0,10.0) ) )
            let xdim = Int( floor( rect.width / rdim ) )
            let ydim = Int( floor( rect.height / rdim ) )
            
            maze?.generateMaze(w: xdim, h: ydim)
            maze?.BruteForceSolve2()
            //maze?.BoxSolve()
            //maze?.printMazeToTTY()
            
            // Some random colours too!
            cellCol = CGColor.randomColourOpaque()
            wallCol = CGColor.randomColourOpaque()
            solveCol = CGColor.randomColourOpaque()
            vistedCol = CGColor.randomColourOpaque()
            
            wallThickness = CGFloat.random(min: 0.05, max: 0.3)
        }
        
        // Draw the Maze
        
// When I figure out why the tile renderer is fucked...
    }
    
    private func DEBUG_ShowTiles( context: CGContextRef, rect: CGRect )
    {
        let cellCol = CGColorCreateGenericRGB( 1.0, 1.0, 0.0, CGFloat(1.0) )
        let wallCol = CGColorCreateGenericRGB( 0.0, 0.0, 1.0, CGFloat(1.0) )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        let wallWide = cellwide / 5
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            renderer?.renderTileToContext( context, rect:CGRect(x: nx, y: ny, width: cellwide, height: cellwide), tileID: n, wallWidth: wallWide, backColour: CGColorGetConstantColor(kCGColorBlack)!, cellColour:cellCol, wallColour:wallCol )
        }
    }

    private func DEBUG_ShowSomething( context: CGContextRef, rect: CGRect )
    {
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
}
