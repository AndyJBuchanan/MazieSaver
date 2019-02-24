//
//  BasicTileRenderer.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

#if os(iOS)
import UIKit
import CoreGraphics
#else
import Cocoa
#endif

class BasicTileRenderer : TileRenderer
{
    // TileRenderer
    func renderTileToContext( _ context:CGContext, rect:CGRect, tileID: Int, wallWidth: CGFloat, backColour: CGColor, cellColour:CGColor, wallColour:CGColor ) -> Void
    {
        context.setBlendMode(CGBlendMode.clear)   // Force to clear (is there a better option for this?)
        context.fill(rect)

        context.setBlendMode(CGBlendMode.normal)
        context.setFillColor(backColour )
        context.setAlpha(1.0)

        let cell = Cell.fromID(tileID)
        
        let (x,y,w,h) = ( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height )
        
        let x0=floor(x), x1=floor(x+wallWidth), x2=floor(x+w-wallWidth), x3=floor(x+w)
        let y0=floor(y), y1=floor(y+wallWidth), y2=floor(y+h-wallWidth), y3=floor(y+h)

        context.setFillColor(cellColour )
        context.setAlpha(1.0)
        context.fill(CGRect(x: x1, y: y1, width: x2-x1, height: y2-y1))

        if cell.left
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0))
            context.fill(CGRect(x: x0, y: y2, width: x1-x0, height: y3-y2))

            context.setFillColor(cellColour )
            context.fill(CGRect(x: x0, y: y1, width: x1-x0, height: y2-y1))
        }
        else
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y0, width: x1-x0, height: y3-y0))
        }
        
        if cell.right
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x2, y: y0, width: x3-x2, height: y1-y0))
            context.fill(CGRect(x: x2, y: y2, width: x3-x2, height: y3-y2))

            context.setFillColor(cellColour )
            context.fill(CGRect(x: x2, y: y1, width: x3-x2, height: y2-y1))
        }
        else
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x2, y: y0, width: x3-x2, height: y3-y0))
        }

        if cell.top
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y2, width: x1-x0, height: y3-y2))
            context.fill(CGRect(x: x0, y: y2, width: x3-x2, height: y3-y2))
            
            context.setFillColor(cellColour )
            context.fill(CGRect(x: x1, y: y2, width: x2-x1, height: y3-y2))
        }
        else
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y2, width: x3-x0, height: y3-y2))
        }

        if cell.bottom
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y0, width: x1-x0, height: y1-y0))
            context.fill(CGRect(x: x0, y: y0, width: x3-x2, height: y1-y0))
            
            context.setFillColor(cellColour )
            context.fill(CGRect(x: x1, y: y0, width: x2-x1, height: y1-y0))
        }
        else
        {
            context.setFillColor(wallColour )
            context.fill(CGRect(x: x0, y: y0, width: x3-x0, height: y1-y0))
        }
    }

    // Local
    var dirty = true
    
    var backgroundColour = CGColor.white
    
    var wallColour = CGColor.black
    var cellColour = CGColor.white
    
    var solutionColour = CGColor.black
    var visitiedColour = CGColor.white
    
    var orphanedColour = CGColor.black

    var tileSize: CGSize?
    var tileWallWidth: CGFloat = 0.0
    
    var tilesEmpty : TileSet?
    var tilesVisited : TileSet?
    var tilesSolution : TileSet?
    var tilesVisitedOverlay : TileSet?
    var tilesSolutionOverlay : TileSet?
    
    func buildTilesets( width: Int, height: Int, wallWidth: Int )
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
            _ = tilesEmpty?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: cellColour, wallColour: wallColour)
            
            tilesVisited = TileSet()
            _ = tilesVisited?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: visitiedColour, wallColour: wallColour)
            
            tilesSolution = TileSet()
            _ = tilesSolution?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: backgroundColour, cellColour: solutionColour, wallColour: wallColour)

            let clearColour = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            
            tilesVisitedOverlay = TileSet()
            _ = tilesVisitedOverlay?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: clearColour, cellColour: visitiedColour, wallColour: clearColour)

            tilesSolutionOverlay = TileSet()
            _ = tilesSolutionOverlay?.buildTilesWith(self, finalWidth: width, finalHeight: height, renderedWidth: 128, renderedHeight: 128, wallWidth: CGFloat(wallWidth), backColour: clearColour, cellColour: solutionColour, wallColour: clearColour)
            
            tileSize = CGSize(width: width, height: height)
            tileWallWidth = CGFloat(wallWidth)
            
            dirty = false
        }
    }
    
    func RenderWithTilesets( _ context:CGContext, rect:CGRect, maze: Maze, backgroundColour: CGColor, wallColour: CGColor, cellColour: CGColor, solvedCellColour: CGColor?, visitedCellColour: CGColor?, wallThickness: CGFloat, overlay: Bool = false )
    {
        context.setFillColor(backgroundColour )
        context.setAlpha(1.0)
        context.fill(rect)

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
                        context.draw(tilesEmpty!.imageCache[cell.tileID]!, in: cellRect)
                        
                        let cellOverlay = maze.cellForSolution(x,useY) ?? cell
                        
                        switch solve
                        {
                        case 2:
                            context.draw(tilesSolutionOverlay!.imageCache[cellOverlay.tileID]!, in: cellRect)
                        case 1:
                            context.draw(tilesVisitedOverlay!.imageCache[cellOverlay.tileID]!, in: cellRect)
                        default:
                            break;
                        }
                    }
                    else
                    {
                        switch solve
                        {
                        case 2:
                            context.draw(tilesSolution!.imageCache[cell.tileID]!, in: cellRect)
                        case 1:
                            context.draw(tilesVisited!.imageCache[cell.tileID]!, in: cellRect)
                        default:
                            context.draw(tilesEmpty!.imageCache[cell.tileID]!, in: cellRect)
                        }
                    }
                }
                else
                {
                    context.draw(tilesEmpty!.imageCache[cell.tileID]!, in: cellRect)
                }
            }
        }
    }
    
    func RenderDirect( _ context:CGContext, rect:CGRect, maze: Maze, backgroundColour: CGColor, wallColour: CGColor, cellColour: CGColor, solvedCellColour: CGColor?, visitedCellColour: CGColor?, wallThickness: CGFloat, overlay: Bool = false )
    {
        context.setFillColor(backgroundColour )
        context.setAlpha(1.0)
        context.fill(rect)
        
        let cwide = rect.width / CGFloat(maze.gridW)
        let chigh = rect.height / CGFloat(maze.gridH)
        
        let cdim = floor( min( cwide, chigh) * 1.0 )
        
        let wallWidth = max( 1.0, wallThickness * cdim )
        
        let xoffs = 0.5 * ( rect.width - ( cdim * CGFloat(maze.gridW) ) )
        let yoffs = 0.5 * ( rect.height - ( cdim * CGFloat(maze.gridH) ) )

        let showSolution = ( ( solvedCellColour != nil ) || ( visitedCellColour != nil ) ) && ( maze.solution.count > 0 )
        
        let useSolvedColour = solvedCellColour ?? cellColour
        let useVisitedColour = visitedCellColour ?? cellColour
        
        let clearColour = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

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

