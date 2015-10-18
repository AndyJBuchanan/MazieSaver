//
//  BasicTileRenderer.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import CoreGraphics

class BasicTileRenderer : TileRenderer
{
    // TileRenderer
    func renderTileToContext( context:CGContextRef, rect:CGRect, tileID: Int, wallWidth: CGFloat, backColour: CGColorRef, cellColour:CGColorRef, wallColour:CGColorRef ) -> Void
    {
        CGContextSetBlendMode(context, CGBlendMode.Clear)   // Force to clear (is there a better option for this?)
        CGContextFillRect(context, rect)

        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextSetFillColorWithColor(context, backColour )
        CGContextSetAlpha(context, 1.0)

        let cell = Cell.fromID(tileID)
        
        let (x,y,w,h) = ( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height )
        
        let x0=floor(x), x1=floor(x+wallWidth), x2=floor(x+w-wallWidth), x3=floor(x+w)
        let y0=floor(y), y1=floor(y+wallWidth), y2=floor(y+h-wallWidth), y3=floor(y+h)

        CGContextSetFillColorWithColor(context, cellColour )
        CGContextSetAlpha(context, 1.0)
        CGContextFillRect(context, CGRect(x: x1, y: y1, width: x2-x1, height: y2-y1))

        if cell.left
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0))
            CGContextFillRect(context, CGRect(x: x0, y: y2, width: x1-x0, height: y3-y2))

            CGContextSetFillColorWithColor(context, cellColour )
            CGContextFillRect(context, CGRect(x: x0, y: y1, width: x1-x0, height: y2-y1))
        }
        else
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y0, width: x1-x0, height: y3-y0))
        }
        
        if cell.right
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x2, y: y0, width: x3-x2, height: y1-y0))
            CGContextFillRect(context, CGRect(x: x2, y: y2, width: x3-x2, height: y3-y2))

            CGContextSetFillColorWithColor(context, cellColour )
            CGContextFillRect(context, CGRect(x: x2, y: y1, width: x3-x2, height: y2-y1))
        }
        else
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x2, y: y0, width: x3-x2, height: y3-y0))
        }

        if cell.top
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y2, width: x1-x0, height: y3-y2))
            CGContextFillRect(context, CGRect(x: x0, y: y2, width: x3-x2, height: y3-y2))
            
            CGContextSetFillColorWithColor(context, cellColour )
            CGContextFillRect(context, CGRect(x: x1, y: y2, width: x2-x1, height: y3-y2))
        }
        else
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y2, width: x3-x0, height: y3-y2))
        }

        if cell.bottom
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0))
            CGContextFillRect(context, CGRect(x: x0, y: y0, width: x3-x2, height: y1-y0))
            
            CGContextSetFillColorWithColor(context, cellColour )
            CGContextFillRect(context, CGRect(x: x1, y: y0, width: x2-x1, height: y1-y0))
        }
        else
        {
            CGContextSetFillColorWithColor(context, wallColour )
            CGContextFillRect(context, CGRect(x: x0, y: y0, width: x3-x0, height: y1-y0))
        }
    }

    // Local
    var dirty = true
    
    let white_col = CGColor.from_rgb(1.0, 1.0, 1.0, 1.0)
    let black_col = CGColor.from_rgb(0.0, 0.0, 0.0, 1.0)
    let clear_col = CGColor.from_rgb(0.0, 0.0, 0.0, 0.0)
    
    var backgroundColour: CGColor { didSet { dirty = true } }
    
    var wallColour: CGColor { didSet { dirty = true } }
    var cellColour: CGColor { didSet { dirty = true } }
    
    var solutionColour: CGColor { didSet { dirty = true } }
    var visitiedColour: CGColor { didSet { dirty = true } }
    
    var orphanedColour: CGColor { didSet { dirty = true } }

    var tileSize: CGSize?
    var tileWallWidth: CGFloat = 0.0
    
    var tilesEmpty : TileSet?
    var tilesVisited : TileSet?
    var tilesSolution : TileSet?
    var tilesVisitedOverlay : TileSet?
    var tilesSolutionOverlay : TileSet?
    
    init()
    {
         backgroundColour = white_col
         wallColour = black_col
         cellColour = white_col
         solutionColour = black_col
         visitiedColour = white_col
         orphanedColour = black_col
    }
    
    func buildTilesets( width width: Int, height: Int, wallWidth: Int )
    {
        if (tileSize==nil) || CGSize(width: width, height: height) != tileSize
        {
            dirty = true
        }
        if ( CGFloat(wallWidth) != tileWallWidth )
        {
            dirty = true
        }
        
        if ( dirty )
        {
            tilesEmpty = TileSet()
            tilesEmpty?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: cellColour, wallColour: wallColour)
            
            tilesVisited = TileSet()
            tilesVisited?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: visitiedColour, wallColour: wallColour)
            
            tilesSolution = TileSet()
            tilesSolution?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: solutionColour, wallColour: wallColour)

            let clearColour = clear_col
            
            tilesVisitedOverlay = TileSet()
            tilesVisitedOverlay?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: clearColour, cellColour: visitiedColour, wallColour: clearColour)

            tilesSolutionOverlay = TileSet()
            tilesSolutionOverlay?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: clearColour, cellColour: solutionColour, wallColour: clearColour)
            
            tileSize = CGSize(width: width, height: height)
            tileWallWidth = CGFloat(wallWidth)
            
            dirty = false
        }
    }
    
    func RenderWithTilesets( context:CGContextRef, rect:CGRect, maze: Maze, backgroundColour: CGColorRef, wallColour: CGColorRef, cellColour: CGColorRef, solvedCellColour: CGColorRef?, visitedCellColour: CGColorRef?, wallThickness: CGFloat, overlay: Bool = false )
    {
        CGContextSetFillColorWithColor(context, backgroundColour )
        CGContextSetAlpha(context, 1.0)
        CGContextFillRect(context, rect)

        let cwide = rect.width / CGFloat(maze.gridW)
        let chigh = rect.height / CGFloat(maze.gridH)

        let cdim = floor( min( cwide, chigh) * 1.0 )
        
        let wallWidth = max( 1.0, floor( wallThickness * cdim ) )

        self.wallColour = wallColour   // todo: property needs to set dirty only if the value is different
        self.cellColour = cellColour
        self.solutionColour = solvedCellColour ?? cellColour
        self.visitiedColour = visitedCellColour ?? cellColour
        self.orphanedColour = wallColour
        
        buildTilesets( width: Int(cdim), height: Int(cdim), wallWidth: Int(wallWidth) )
        
        let xoffs = 0.5 * ( rect.width - ( cdim * CGFloat(maze.gridW) ) )
        let yoffs = 0.5 * ( rect.height - ( cdim * CGFloat(maze.gridH) ) )

        let showSolution = ( ( solvedCellColour != nil ) || ( visitedCellColour != nil ) ) && ( maze.solution.count > 0 )
        
        for y in 0..<maze.gridH
        {
            for x in 0..<maze.gridW
            {
                let x0 = floor( xoffs + ((CGFloat(x)+0.0)*cdim) )
                let x1 = floor( xoffs + ((CGFloat(x)+1.0)*cdim) )
                let y0 = floor( yoffs + ((CGFloat(y)+0.0)*cdim) )
                let y1 = floor( yoffs + ((CGFloat(y)+1.0)*cdim) )
                let cellRect = CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0 )
                
                let useY = maze.gridH-1-y   // Need to flip the grid since we're using a traditional cartesian coordinate system for drawing

                let cell = maze.grid[useY][x]

                if ( showSolution )
                {
                    let solve = maze.solution[useY][x]
                    
                    if ( overlay )
                    {
                        CGContextDrawImage(context, cellRect, tilesEmpty!.imageCache[cell.tileID] )
                        
                        let cellOverlay = maze.cellForSolution(x,useY) ?? cell
                        
                        switch solve
                        {
                        case 2:
                            CGContextDrawImage(context, cellRect, tilesSolutionOverlay!.imageCache[cellOverlay.tileID] )
                        case 1:
                            CGContextDrawImage(context, cellRect, tilesVisitedOverlay!.imageCache[cellOverlay.tileID] )
                        default:
                            break;
                        }
                    }
                    else
                    {
                        switch solve
                        {
                        case 2:
                            CGContextDrawImage(context, cellRect, tilesSolution!.imageCache[cell.tileID] )
                        case 1:
                            CGContextDrawImage(context, cellRect, tilesVisited!.imageCache[cell.tileID] )
                        default:
                            CGContextDrawImage(context, cellRect, tilesEmpty!.imageCache[cell.tileID] )
                        }
                    }
                }
                else
                {
                    CGContextDrawImage(context, cellRect, tilesEmpty!.imageCache[cell.tileID] )
                }
            }
        }
    }
    
    func RenderDirect( context:CGContextRef, rect:CGRect, maze: Maze, backgroundColour: CGColorRef, wallColour: CGColorRef, cellColour: CGColorRef, solvedCellColour: CGColorRef?, visitedCellColour: CGColorRef?, wallThickness: CGFloat, overlay: Bool = false )
    {
        CGContextSetFillColorWithColor(context, backgroundColour )
        CGContextSetAlpha(context, 1.0)
        CGContextFillRect(context, rect)
        
        let cwide = rect.width / CGFloat(maze.gridW)
        let chigh = rect.height / CGFloat(maze.gridH)
        
        let cdim = floor( min( cwide, chigh) * 1.0 )
        
        let wallWidth = max( 1.0, wallThickness * cdim )
        
        let xoffs = 0.5 * ( rect.width - ( cdim * CGFloat(maze.gridW) ) )
        let yoffs = 0.5 * ( rect.height - ( cdim * CGFloat(maze.gridH) ) )

        let showSolution = ( ( solvedCellColour != nil ) || ( visitedCellColour != nil ) ) && ( maze.solution.count > 0 )
        
        let useSolvedColour = solvedCellColour ?? cellColour
        let useVisitedColour = visitedCellColour ?? cellColour
        
        let clearColour = CGColor.from_rgb(0.0, 0.0, 0.0, 0.0)

        for y in 0..<maze.gridH
        {
            for x in 0..<maze.gridW
            {
                let x0 = floor( xoffs + ((CGFloat(x)+0.0)*cdim) )
                let x1 = floor( xoffs + ((CGFloat(x)+1.0)*cdim) )
                let y0 = floor( yoffs + ((CGFloat(y)+0.0)*cdim) )
                let y1 = floor( yoffs + ((CGFloat(y)+1.0)*cdim) )
                let cellRect = CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0 )
                
                let useY = maze.gridH-1-y   // Need to flip the grid since we're using a traditional cartesian coordinate system for drawing
                
                let cell = maze.grid[useY][x]
  
                if ( showSolution )
                {
                    let solve = maze.solution[useY][x]
                    
                    if ( overlay )
                    {
                        renderTileToContext(context, rect: cellRect, tileID: cell.tileID, wallWidth: wallWidth, backColour: backgroundColour, cellColour: cellColour, wallColour: wallColour)
                        
                        let cellOverlay = maze.cellForSolution(x,useY) ?? cell
                        
                        switch solve
                        {
                        case 2:
                            renderTileToContext(context, rect: cellRect, tileID: cellOverlay.tileID, wallWidth: wallWidth, backColour: clearColour, cellColour: useSolvedColour, wallColour: clearColour)
                        case 1:
                            renderTileToContext(context, rect: cellRect, tileID: cellOverlay.tileID, wallWidth: wallWidth, backColour: clearColour, cellColour: useVisitedColour, wallColour: clearColour)
                        default:
                            break;
                        }
                    }
                    else
                    {
                        switch solve
                        {
                            case 2:
                                renderTileToContext(context, rect: cellRect, tileID: cell.tileID, wallWidth: wallWidth, backColour: backgroundColour, cellColour: useSolvedColour, wallColour: wallColour)
                            case 1:
                                renderTileToContext(context, rect: cellRect, tileID: cell.tileID, wallWidth: wallWidth, backColour: backgroundColour, cellColour: useVisitedColour, wallColour: wallColour)
                            default:
                                renderTileToContext(context, rect: cellRect, tileID: cell.tileID, wallWidth: wallWidth, backColour: backgroundColour, cellColour: cellColour, wallColour: wallColour)
                        }
                    }
                }
                else
                {
                    renderTileToContext(context, rect: cellRect, tileID: cell.tileID, wallWidth: wallWidth, backColour: backgroundColour, cellColour: cellColour, wallColour: wallColour)
                }
            }
        }
    }
}

