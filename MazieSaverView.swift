//
//  MazieSaverView.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 05/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Foundation
import CoreGraphics

class MazieSaverCore
{
    var renderer: BasicTileRenderer?
    
    func DEBUG_ShowSomething( context: CGContextRef, rect: CGRect )
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
    
    private func DEBUG_ShowTiles( context: CGContextRef, rect: CGRect )
    {
        let cellCol = CGColor.from_rgb( 1.0, 1.0, 0.0, 1.0 )
        let wallCol = CGColor.from_rgb( 0.0, 0.0, 1.0, 1.0 )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        let wallWide = cellwide / 5
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            renderer?.renderTileToContext( context, rect:CGRect(x: nx, y: ny, width: cellwide, height: cellwide), tileID: n, wallWidth: wallWide, backColour: CGColor.from_rgb(0.0, 0.0, 0.0, 1.0), cellColour:cellCol, wallColour:wallCol )
        }
    }

    var maze: Maze?
    var lastMazeRect = CGRect.zero
    
    let backCol = CGColor.from_rgb( 0.0, 0.0, 0.0, 1.0 )
    var cellCol = CGColor.from_rgb( 1.0, 1.0, 0.0, CGFloat(1.0) )
    var wallCol = CGColor.from_rgb( 0.0, 0.0, 1.0, CGFloat(1.0) )
    var solveCol = CGColor.from_rgb( 1.0, 0.0, 1.0, CGFloat(1.0) )
    var vistedCol = CGColor.from_rgb( 0.45, 0.0, 0.25, CGFloat(1.0) )
    
    var wallThickness:CGFloat = 0.2
    
    var tiledRender = true
    
    private func DrawMaze( context: CGContextRef, rect: CGRect )
    {
        // Regenerate the maze if required
        if ( maze == nil ) || ( lastMazeRect != rect )
        {
            maze = Maze()
            
            let rdim = floor( CGFloat.random( min: 3.0, max: min(rect.width/20.0,8.0) ) )
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
        if ( tiledRender )
        {
            renderer?.RenderWithTilesets(context, rect: rect, maze: maze!, backgroundColour: backCol, wallColour: wallCol, cellColour: cellCol, solvedCellColour: solveCol, visitedCellColour: vistedCol, wallThickness: 0.2, overlay: true )
        }
        else
        {
            renderer?.RenderDirect(context, rect: rect, maze: maze!, backgroundColour: backCol, wallColour: wallCol, cellColour: cellCol, solvedCellColour: solveCol, visitedCellColour: vistedCol, wallThickness: 0.2, overlay: true )
        }
    }

    func drawRect(rect: CGRect, context: CGContextRef)
    {
        DEBUG_ShowSomething(context, rect: rect)
        
        if ( renderer==nil )
        {
            renderer = BasicTileRenderer()
        }
        
        DEBUG_ShowTiles(context, rect: rect)
        
        DrawMaze(context, rect: rect)
    }
    
    func newMaze()
    {
        // Force regeneration of maze
        maze = nil
    }
}

#if os(iOS)

    import UIKit

    class MazieSaverView : ScreenSaverView
    {
        var core = MazieSaverCore()
        
        override init(frame: CGRect, isPreview: Bool)
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
        
        override func drawRect(rect: CGRect)
        {
            if let context = UIGraphicsGetCurrentContext()
            {
                core.drawRect(rect, context: context)
            }
        }

        override func animateOneFrame()
        {
            newMaze()
            setNeedsDisplay()
        }
        
        func newMaze()
        {
            // Force regeneration of maze
            core.newMaze()
            setNeedsDisplay()
        }
    }

#else

import ScreenSaver

class MazieSaverView : ScreenSaverView
{
    var core = MazieSaverCore()
    
    override init?(frame: CGRect, isPreview: Bool)
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
    
    override func drawRect(rect: CGRect)
    {
        let context: CGContextRef = NSGraphicsContext.currentContext()!.CGContext
        core.drawRect(rect, context: context)
    }
    
    override func animateOneFrame()
    {
        newMaze()
        needsDisplay = true
    }
    
    func newMaze()
    {
        // Force regeneration of maze
        core.newMaze()
        needsDisplay = true;
    }
}

#endif

