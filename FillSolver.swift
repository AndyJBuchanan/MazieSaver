//
//  FillSolver.swift
//  MazieSaver
//
//  Created by Andrew Buchanan on 31/05/2023.
//  Copyright © 2023 Andy Buchanan. All rights reserved.
//

extension Maze
{
    final func LowestScoredNeighbour( _ x: Int , _ y: Int ) -> (Int , Int)
    {
        var neighbor = (x:0,y:0)
        var bestScore = Int.max
        
        if grid[y][x].left && x>0
        {
            if scores[y][x-1] < bestScore
            {
                bestScore = scores[y][x-1]
                neighbor = (x-1,y)
            }
        }

        if grid[y][x].right && x<gridW-1
        {
            if scores[y][x+1] < bestScore
            {
                bestScore = scores[y][x+1]
                neighbor = (x+1,y)
            }
        }

        if grid[y][x].top && y>0
        {
            if scores[y-1][x] < bestScore
            {
                bestScore = scores[y-1][x]
                neighbor = (x,y-1)
            }
        }

        if grid[y][x].bottom && y<gridH-1
        {
            if scores[y+1][x] < bestScore
            {
                bestScore = scores[y+1][x]
                neighbor = (x,y+1)
            }
        }

        return neighbor;
    }
    // todo: remove the edge checks
    
    final func FillSolve() -> Bool
    {
        // Maze generation has already populated the score grid with distance from entrance metrics

        solution.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            solution.append( Array<Int>(repeating: 0, count: gridW) )
        }

        var ff = exit
        while ( ff != entrance )
        {
            let ffNext = LowestScoredNeighbour( ff.x, ff.y )
            solution[ ff.y ][ ff.x ] = 2;
            ff = ffNext;
        }
        
        return true
    }
}


