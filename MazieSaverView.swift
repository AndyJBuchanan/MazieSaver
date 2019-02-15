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
    
    override func draw(_ rect: NSRect)
    {
        let context: CGContext = NSGraphicsContext.current!.cgContext
        
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

    let backCol = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var cellCol = CGColor( red: 1.0, green: 1.0, blue: 0.0, alpha: CGFloat(1.0) )
    var wallCol = CGColor( red: 0.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
    var solveCol = CGColor( red: 1.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
    var vistedCol = CGColor( red: 0.45, green: 0.0, blue: 0.25, alpha: CGFloat(1.0) )
    
    var wallThickness:CGFloat = 0.2

    var renderer: BasicTileRenderer?
    
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
    
    fileprivate func DEBUG_ShowTiles( _ context: CGContext, rect: CGRect )
    {
        let cellCol = CGColor( red: 1.0, green: 1.0, blue: 0.0, alpha: CGFloat(1.0) )
        let wallCol = CGColor( red: 0.0, green: 0.0, blue: 1.0, alpha: CGFloat(1.0) )
        
        let nwide = rect.width / 8
        let nhigh = rect.height / 2
        let cellwide = min(nwide, nhigh) * 0.9
        let wallWide = cellwide / 5
        for n in 0...15
        {
            let nx = CGFloat( n % 8 ) * nwide
            let ny = CGFloat( n / 8 ) * nhigh
            
            renderer?.renderTileToContext( context, rect:CGRect(x: nx, y: ny, width: cellwide, height: cellwide), tileID: n, wallWidth: wallWide, backColour: CGColor.black, cellColour:cellCol, wallColour:wallCol )
        }
    }

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
}
