//
//  BoxesSolver.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 28/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Cocoa

extension Maze
{
    final func BoxSolve() -> Bool
    {
        // Count initial connections
        solution = []
        solution.reserveCapacity( gridH )
        for y in 0..<gridH
        {
            solution.append( [Int]() )
            for x in 0..<gridW
            {
                solution[y].append( grid[y][x].count )
            }
        }
        
        var deletedSquares = 1
        var passCount = 0
        while( deletedSquares > 0 )
        {
            deletedSquares = 0
            
            for y in 0..<gridH
            {
                for x in 0..<gridW
                {
                    if solution[y][x] == 1
                    {
                        solution[y][x] = 0

                        var c = grid[y][x]
                        
                        if ( x>0 ) && (c.left) { solution[y][x-1]-- }
                        if ( x<gridW-1 ) && (c.right){ solution[y][x+1]-- }
                        if ( y>0 ) && (c.top){ solution[y-1][x]-- }
                        if ( y<gridH-1 ) && (c.bottom){ solution[y+1][x]-- }
                        
                        ++deletedSquares
                    }
                }
            }
            
            ++passCount
        }

        print("Boxes Solve took \(passCount) passes")
        
        for y in 0..<gridH
        {
            for x in 0..<gridW
            {
                if ( solution[y][x] != 0 )
                {
                    solution[y][x] = 2
                }
            }
        }
        
        return true
    }
}

// No refine step yet, no point whilst the core performance is still so bad


