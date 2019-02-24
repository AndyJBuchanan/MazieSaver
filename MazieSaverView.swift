//
//  MazieSaverView.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 05/10/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

// Note! Screen Savers are stored in '~/Library/Screen Savers'

// todo: draw maze, then solution, then new maze?

import Foundation

#if os(iOS)
    import UIKit
    import CoreGraphics
#else
    import Cocoa
    import ScreenSaver
#endif

class MazieSaverCore
{
    var renderer: BasicTileRenderer?
    
    fileprivate func DEBUG_ShowSomething( _ context: CGContext, rect: CGRect )
    {
        let randCol = CGColor.randomColourOpaque()
        
        context.setBlendMode(CGBlendMode.normal)
        context.setFillColor(randCol )
        context.setAlpha(1.0)
        context.fill(rect )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            context.setFillColor(CGColor.randomColourOpaque() )
            context.setAlpha(1.0)
            context.fill(CGRect(x: nx, y: ny, width: cellwide, height: cellwide) )
        }
    }
    
    fileprivate func DEBUG_ShowTiles( _ context: CGContext, rect: CGRect )
    {
        let cellCol = CGColor.from_RGBA( red: 1.0, green: 1.0, blue: 0.0, alpha: CGFloat(1.0) )
        let wallCol = CGColor.from_RGBA( red: 0.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        let wallWide = cellwide / 5
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            renderer?.renderTileToContext( context, rect:CGRect(x: nx, y: ny, width: cellwide, height: cellwide), tileID: n, wallWidth: wallWide, backColour: CGColor.getBlack(), cellColour:cellCol, wallColour:wallCol )
        }
    }
    
    var maze: Maze?
    var lastMazeRect = CGRect.zero
    
    let backCol = CGColor.from_RGBA(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var cellCol = CGColor.from_RGBA( red: 1.0, green: 1.0, blue: 0.0, alpha: CGFloat(1.0) )
    var wallCol = CGColor.from_RGBA( red: 0.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
    var solveCol = CGColor.from_RGBA( red: 1.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
    var vistedCol = CGColor.from_RGBA( red: 0.45, green: 0.0, blue: 0.25, alpha: CGFloat(1.0) )

    var wallThickness:CGFloat = 0.2
    
    // Note: The Tile renderer is significantly quicker, try to always use it!
    var tiledRender = true

    fileprivate func DrawMaze( _ context: CGContext, rect: CGRect )
    {
        // Regenerate the maze if required
        if ( maze == nil ) || ( lastMazeRect != rect )
        {
            maze = Maze()
            
            let rdim = floor( CGFloat.random( min: 3.0, max: min(rect.width/20.0,8.0) ) )
            let xdim = Int( floor( rect.width / rdim ) )
            let ydim = Int( floor( rect.height / rdim ) )
            
            maze?.generateMaze(w: xdim, h: ydim)
            _ = maze?.BruteForceSolve2()
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
    
    func draw(_ rect: CGRect, _ context: CGContext)
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

class MazieSaverView : UIView
{
    var core = MazieSaverCore()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let animationTimeInterval = TimeInterval(3)
        Timer.scheduledTimer( timeInterval: animationTimeInterval, target: self, selector:  #selector(animateOneFrame), userInfo: nil, repeats: true )
    }
    
    required init?(coder: NSCoder)
    {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)

        let animationTimeInterval = TimeInterval(3)
        Timer.scheduledTimer( timeInterval: animationTimeInterval, target: self, selector:  #selector(animateOneFrame), userInfo: nil, repeats: true )
    }
    
    override func draw(_ rect: CGRect)
    {
        if let context = UIGraphicsGetCurrentContext()
        {
            core.draw(rect, context)
        }
    }
    
    @objc func animateOneFrame()
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
    
    override func draw(_ rect: NSRect)
    {
        let context: CGContext = NSGraphicsContext.current!.cgContext
        core.draw( rect, context )
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


