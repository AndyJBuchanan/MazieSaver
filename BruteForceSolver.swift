//
//  BruteForceSolver.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 27/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

extension Maze
{
    final func BruteForceSolve() -> Bool
    {
        func recursiveSolve( _ x: Int, _ y: Int ) -> Bool
        {
            if ( ( x < 0 ) || ( x >= gridW )  ){ return false }
            if ( ( y < 0 ) || ( y >= gridH )  ){ return false }
            
            if ( solution[ y ][ x ] != 0 ){ return false }    // Already visited?
            
            solution[ y ][ x ] = 1; // Visited
            
            if ( ( x == exit.x ) && ( y == exit.y ) )
            {
                solution[ y ][ x ] = 2; // Exited!
                return true;
            }
            
            var cell = grid[ y ][ x ]
            if ( cell.left ){ if ( recursiveSolve( x-1, y ) ) { solution[ y ][ x ] = 2; return true; } }
            if ( cell.right ){ if ( recursiveSolve( x+1, y ) ) { solution[ y ][ x ] = 2; return true; } }
            if ( cell.top ){ if ( recursiveSolve( x, y-1 ) ) { solution[ y ][ x ] = 2; return true; } }
            if ( cell.bottom ){ if ( recursiveSolve( x, y+1 ) ) { solution[ y ][ x ] = 2; return true; } }
            
            return false
        }
        
        solution = []
        solution.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            solution.append( Array<Int>(repeating: 0, count: gridW) )
        }
        
        return recursiveSolve( entrance.x, entrance.y )
    }

    // With a manual stack. A bit more tortuous, but should avoid running out of space
    final func BruteForceSolve2() -> Bool
    {
        typealias stackEntry = (x:Int,y:Int)
        var stack:[stackEntry] = []
        
        func solve( _ x: Int, _ y: Int ) -> Bool
        {
            var x = x, y = y
            while true
            {
                if ( x < 0 ) || ( x >= gridW ) || ( y < 0 ) || ( y >= gridH ) || ( solution[ y ][ x ] > 0 )
                {
                    // Terminate
                    if ( stack.count > 0 )
                    {
                        (x,y)=stack.removeLast()
                        continue
                    }
                    else
                    {
                        return false
                    }
                }
                
                if ( solution[ y ][ x ] == 0 )
                {
                    solution[ y ][ x ] = -1;    // Mark Start of Visit
                }
                
                if ( ( x == exit.x ) && ( y == exit.y ) )
                {
                    // Exited! Mark all the squares!
                    solution[ y ][ x ] = 2;
                    for (x,y) in stack
                    {
                        solution[y][x] = 2
                    }
                    return true;
                }
                
                var cell = grid[ y ][ x ]
                
                if ( cell.left && ( x>0 ) && ( solution[y][x-1]==0 ) )
                {
                    stack.append( (x,y) )
                    x -= 1
                    continue
                }
                if ( cell.right && ( x<gridW-1 ) && ( solution[y][x+1]==0 ) )
                {
                    stack.append( (x,y) )
                    x += 1
                    continue
                }

                if ( cell.top && ( y>0 ) && ( solution[y-1][x]==0 ) )
                {
                    stack.append( (x,y) )
                    y -= 1
                    continue
                }
                if ( cell.bottom && ( y<gridH-1 ) && ( solution[y+1][x]==0 ) )
                {
                    stack.append( (x,y) )
                    y += 1
                    continue
                }
                
                solution[ y ][ x ] = 1;    // Mark End of Visit, all paths tried
            }
        }
        
        solution = []
        solution.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            solution.append( Array<Int>(repeating: 0, count: gridW) )
        }
        
        return solve( entrance.x, entrance.y )
    }
    
    // todo: might be able to save more time by following non-decision routes without stacking
}

