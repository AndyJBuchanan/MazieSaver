//
//  Maze.swift
//  MazieSaver
//
//  Created by Andy Buchanan on 24/09/2015.
//  Copyright © 2015 Andy Buchanan. All rights reserved.
//

import Foundation

struct Cell
{
    static let connectLeft: UInt8   = 0b0000_0001
    static let connectRight: UInt8  = 0b0000_0010
    static let connectTop: UInt8    = 0b0000_0100
    static let connectBottom: UInt8 = 0b0000_1000
    
    fileprivate var connections: UInt8 = 0
    
    static let zero = Cell()
    
    fileprivate mutating func setConnection( _ bit: UInt8, connect: Bool )
    {
        if ( connect )
        {
            connections |= bit
        }
        else
        {
            connections &= ~bit
        }
    }
    
    fileprivate func getConnection( _ bit: UInt8 ) -> Bool
    {
        return ( connections & bit ) == bit
    }
    
    var left: Bool
        {
            get { return getConnection( Cell.connectLeft ) }
            set { setConnection( Cell.connectLeft, connect: newValue ) }
        }
    var right: Bool
        {
            get { return getConnection( Cell.connectRight ) }
            set { setConnection( Cell.connectRight, connect: newValue ) }
        }
    var top: Bool
        {
            get { return getConnection( Cell.connectTop ) }
            set { setConnection( Cell.connectTop, connect: newValue ) }
        }
    var bottom: Bool
        {
            get { return getConnection( Cell.connectBottom ) }
            set { setConnection( Cell.connectBottom, connect: newValue ) }
        }

    fileprivate static let connectCounts = [ 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4 ]
    
    var count: Int
        {
            return Cell.connectCounts[ Int(connections) ]
        }
    
    var tileID: Int { return Int(connections) }
    
    static func fromID( _ id: Int ) -> Cell { return Cell(connections: UInt8(id) ) }
    
    static var validTileIDs: [Int] { return (0...15).map{ $0 } }
}

enum NavigationDirection : UInt8
{
    case left = 0, right, top, bottom
}

class Maze
{
    var grid: [[Cell]] = []
    var scores: [[Int]] = []
    var solution: [[Int]] = []
    
    var gridW = 0
    var gridH = 0
    
    var entrance = (x:0,y:0)
    var exit = (x:0,y:0)
    
    fileprivate func initialiseGrid( width: Int, height: Int )
    {
        gridW = max(width, 5)
        gridH = max(height, 5)
        
        grid = []
        grid.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            grid.append( Array<Cell>(repeating: Cell.zero, count: gridW) )
        }
    }
    
    fileprivate func connectionCount( _ x: Int, _ y: Int ) -> Int
    {
        let cell = grid[y][x]
        var count = 0
        if cell.left { count += 1 }
        if cell.right { count += 1 }
        if cell.top { count += 1 }
        if cell.bottom { count += 1 }
        return count
    }
    
    fileprivate func connectionSet( _ x: Int, _ y: Int, dir: NavigationDirection, make: Bool ) -> Bool
    {
        if ( y==0 ) && ( dir == .top ){ return false }
        if ( y==(gridH-1) ) && ( dir == .bottom ){ return false }
        
        switch dir
        {
        case .left:
            if x==0 { return false }
            (grid[y][x]).left = make
            (grid[y][x-1]).right = make
        case .right:
            if x==(gridW-1) { return false }
            (grid[y][x]).right = make
            (grid[y][x+1]).left = make
        case .top:
            if y==0 { return false }
            (grid[y][x]).top = make
            (grid[y-1][x]).bottom = make
        case .bottom:
            if y==(gridH-1) { return false }
            (grid[y][x]).bottom = make
            (grid[y+1][x]).top = make
        }
        
        return true
    }

    fileprivate func connectOne( _ x: Int, _ y: Int, dir: NavigationDirection ) -> Bool
    {
        return connectionSet(x, y, dir: dir, make: true )
    }

    fileprivate func disconnectOne( _ x: Int, _ y: Int, dir: NavigationDirection ) -> Bool
    {
        return connectionSet(x, y, dir: dir, make: false )
    }
    
    fileprivate func randomGrid()
    {
        // Make sure grid is fully unconnected
        initialiseGrid( width: gridW, height: gridH )
        
        for y in 0..<gridH
        {
            for x in 0..<gridW
            {
                var numConnections = connectionCount( x,  y )
                var targetConnections = 0
                if Float.random() > 0.75 { targetConnections = 0 }
                else { targetConnections = 1 }
                
                while ( numConnections < targetConnections )
                {
                    let randomDirection = NavigationDirection( rawValue: UInt8( Int.random(4) ) )
                    connectOne( x,  y, dir: randomDirection! )
                    numConnections = connectionCount( x, y )
                }
            }
        }
    }
    
    fileprivate func pickExits()
    {
        if ( Float.random() < 0.5 )
        {
            entrance = ( x:Int.random(gridW), y:0 )
            exit = ( x:Int.random(gridW), y:gridH-1 )
            (grid[entrance.y][entrance.x]).top = true
            (grid[exit.y][exit.x]).bottom = true
        }
        else
        {
            entrance = ( x:0, y:Int.random(gridH) )
            exit = ( x:gridW-1, y:Int.random(gridH) )
            (grid[entrance.y][entrance.x]).left = true
            (grid[exit.y][exit.x]).right = true
        }
    }
    
    fileprivate func hasUnconnectedNeighbours( _ x: Int, _ y: Int ) -> Bool
    {
        var score = 0
        if ( x > 0 ){ score += scores[y][x-1] }
        if ( x < (gridW-1) ){ score += scores[y][x+1] }
        if ( y > 0 ){ score += scores[y-1][x] }
        if ( y < (gridH-1) ){ score += scores[y+1][x] }
        return score != 0
    }
    
    typealias ScoreStackEntry = (x:Int, y:Int, score:Int, exit:Bool)
    
    fileprivate func recursiveScore( _ x: Int, _ y: Int, score: Int, scoreStack: inout [ScoreStackEntry] ) -> Bool
    {
        if ( ( x < 0 ) || ( x >= gridW  ) ){ return false } // Off Maze edge?
        if ( ( y < 0 ) || ( y >= gridH  ) ){ return false }
        
        if ( scores[ y ][ x ] > 0 ){ return false }         // Already visited?
        
        scores[ y ][ x ] = score;                           // Store score
        
        if ( ( x == exit.x ) && ( y == exit.y ) )
        {
            // Found the exit! ( Make note of this interesting occurrence at the base of the stack! )
            scoreStack.insert((x:x, y:y, score:score, exit:false), at: 0)
            scoreStack.insert((x:x, y:y, score:100000, exit:true), at: 0)
            // todo: should be able to change to clearing the stack if/when we decide to process orphans separately
            return true;
        }
        
        let high = ( scoreStack.last?.score ?? 0 ) // unwrapped value or default
        
        if ( score > high )
        {
            if ( hasUnconnectedNeighbours( x, y ) )
            {
                // Tag highest scoring (furthest away) cell with unconnected neighbours
                // we might want to connect to!
                scoreStack.append( ( x:x, y:y, score:score, exit:false ) );
            }
        }
        
        var cell = grid[ y ][ x ];
        if ( cell.left ){ recursiveScore( x-1, y, score: score+1, scoreStack: &scoreStack ) }
        if ( cell.right ){ recursiveScore( x+1, y, score: score+1, scoreStack: &scoreStack ) }
        if ( cell.top ){ recursiveScore( x, y-1, score: score+1, scoreStack: &scoreStack ) }
        if ( cell.bottom ){ recursiveScore( x, y+1, score: score+1, scoreStack: &scoreStack ) }
        
        return true;
    }
    
    // Pick an unconnected neighbour. Optimised version. Less random
    fileprivate func pickUnscored( _ x: Int, _ y: Int ) -> NavigationDirection?
    {
        let leftDir: NavigationDirection? = ( ( x>0 ) && ( scores[y][x-1] == 0 ) ) ? .left : nil
        let rightDir: NavigationDirection? = ( ( x<gridW-1) && ( scores[y][x+1] == 0 ) ) ? .right : nil
        let topDir: NavigationDirection? = ( ( y>0 ) && ( scores[y-1][x] == 0 ) ) ? .top : nil
        let bottomDir: NavigationDirection? = ( ( y<gridH-1 ) && ( scores[y+1][x] == 0 ) ) ? .bottom : nil

        if ( Float.random() > 0.31 )
        {
            let r = Float.random()
            if r > 0.75
            {
                return leftDir ?? rightDir ?? topDir ?? bottomDir
            }
            else if r > 0.5
            {
                return bottomDir ?? leftDir ?? rightDir ?? topDir
            }
            else if r > 0.25
            {
                return topDir ?? bottomDir ?? leftDir ?? rightDir
            }
            else
            {
                return rightDir ?? topDir ?? bottomDir ?? leftDir
            }
            
        }
        else
        {
            return leftDir ?? rightDir ?? topDir ?? bottomDir
        }
        
    }
    
    fileprivate func scoreAndJoin() -> Bool
    {
        // Empty Scores
        scores = []
        scores.reserveCapacity( gridH )
        for _ in 0..<gridH
        {
            scores.append( Array<Int>(repeating: 0, count: gridW) )
        }
        
        // Score recursively from entrance & exits
        var scorestack: [ScoreStackEntry] = [];
        recursiveScore( entrance.x, entrance.y, score: 1, scoreStack: &scorestack );
        
        // Now attempt to recursively connect to the exit
        while( scorestack.count > 0 )
        {
            let top = scorestack.removeLast()
            if ( top.exit == true ){ return true; }
            
            if let newDir = pickUnscored( top.x, top.y )
            {
                connectOne( top.x, top.y, dir: newDir );
                scores[ top.y ][ top.x ] = 0;
                recursiveScore( top.x, top.y, score: top.score, scoreStack: &scorestack );
            }
        }
        
        // Failed to connect to exit by normal means
        return false;
    }
    
    final func generateMaze( w: Int, h: Int )
    {
        initialiseGrid(width: w, height: h )
        randomGrid()
        pickExits()
        if ( !scoreAndJoin() )
        {
            // Failed to connect, try in reverse before giving up
            // ( This should not happen... )
            ( entrance, exit ) = ( exit, entrance )
            if ( !scoreAndJoin() )
            {
                // Woah, this is really bad!
                // Emergency! Make another maze!
                return generateMaze(w: w, h: h)
            }
            ( entrance, exit ) = ( exit, entrance )
        }
    }
    
    // For debug, dirty tty print of grid
    final func printMazeToTTY()
    {
        for y in 0..<gridH
        {
            var line0 = ""
            var line1 = ""
            var line2 = ""

            for x in 0..<gridW
            {
                var cell0 = [ "X", "X", "X" ]
                var cell1 = [ "X", " ", "X" ]
                var cell2 = [ "X", "X", "X" ]
                
                let c = grid[y][x]
                
                if ( c.left ){ cell1[0]=" " }
                if ( c.right ){ cell1[2]=" " }
                if ( c.top ){ cell0[1]=" " }
                if ( c.bottom ){ cell2[1]=" " }
                
                if ( solution.count > 0 )
                {
                    let s = solution[y][x]
                    if s == 2 { cell1[1]="." }
                }
                
                line0 = line0 + cell0[0]
                line0 = line0 + cell0[1]
                line0 = line0 + cell0[2]
                
                line1 = line1 + cell1[0]
                line1 = line1 + cell1[1]
                line1 = line1 + cell1[2]

                line2 = line2 + cell2[0]
                line2 = line2 + cell2[1]
                line2 = line2 + cell2[2]
            }
            
            print( line0 )
            print( line1 )
            print( line2 )
        }
    }
    
    final func cellForSolution( _ x: Int, _ y: Int ) -> Cell?
    {
        if ( x<0 ){ return nil }
        if ( y<0 ){ return nil }
        if ( x>=gridW ){ return nil }
        if ( y>=gridH ){ return nil }
        if ( solution.count == 0 ){ return nil }
        
        let cell = grid[y][x]
        
        var solutionCell = Cell.zero
        
        if ( cell.left   && (x>0) && (solution[y][x-1] != 0) ){ solutionCell.left = true }
        if ( cell.right  && (x<gridW-1) && (solution[y][x+1] != 0) ){ solutionCell.right = true }
        
        if ( cell.top    && (y>0) && (solution[y-1][x] != 0) ){ solutionCell.top = true }
        if ( cell.bottom && (y<gridH-1) && (solution[y+1][x] != 0) ){ solutionCell.bottom = true }

        return solutionCell
    }
}

// todo: solvers
// todo: renderers
// todo: abstract maze grid and keep seperate from generators, allow other maze toppolgies by abstracting the connectivity operations

// Tilesets
