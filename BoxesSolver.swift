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
        solution.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            solution.append( Array<Int>(count: gridW, repeatedValue: 2) )
        }

        var gridCopy = grid
        
        var deletedSquares = 1
        var passCount = 0
        while( deletedSquares > 0 )
        {
            deletedSquares = 0
            
            for y in 0..<gridH
            {
                for x in 0..<gridW
                {
                    let c = gridCopy[y][x]
                    
                    if c.count == 1
                    {
                        solution[y][x] = 0
                        gridCopy[y][x] = Cell.zero

                        if ( x>0 )      { gridCopy[y][x-1].right=false }
                        if ( x<gridW-1 ){ gridCopy[y][x+1].left=false }
                        if ( y>0 )      { gridCopy[y-1][x].bottom=false }
                        if ( y<gridH-1 ){ gridCopy[y+1][x].top=false }
                        
                        ++deletedSquares
                    }
                }
            }
            
            ++passCount
        }

        print("Boxes Solve took \(passCount) passes")
        
        return true
    }
}

// No refine step yet, no point whilst the core performance is still so bad


