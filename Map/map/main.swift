import Foundation


struct LinearMap<K: Equatable, V>: CustomStringConvertible {
    var keys = Array<K>()
    var values = Array<V>()
    var count = 0
    
    func findKeyIndex(_ k : K)-> Int? {
        for i in 0..<keys.count {
            if keys[i] == k {
                return i
            }
        }
        return nil
    }
    
    mutating func set(_ k: K, _ v: V) {
        if findKeyIndex(k) != nil {
            values[findKeyIndex(k)!] = v
        } else {
            keys.append(k)
            values.append(v)
            count += 1
        }
    }
    
    func get(_ k: K)-> V? {
        if findKeyIndex(k) != nil {
            return values[findKeyIndex(k)!]
        }
        return nil
    }
    
    subscript(key: K)-> V? {
        get {return get(key)}
        set(newValue) {set(key, newValue!)}
    }
    
    var description: String {
        var description = "["
        for i in 0..<keys.count {
            description += "\n\(keys[i]) : \(values[i])"
        }
        description += "\n]\n"
        return description
    }
}

struct BinaryMap<K: Comparable, V>: CustomStringConvertible {
    var keys = Array<K>()
    var values = Array<V>()
    var count = 0
    
    mutating func set(_ k: K, _ v: V) {
        if binarySearch(elements: keys, target: k) != nil {
            values[binarySearch(elements: keys, target: k)!] = v
        } else {
            let insertAt = insertPosition(k)
            keys.insert(k, at: insertAt)
            values.insert(v, at: insertAt)
            count += 1
        }
        //let combined = zip(keys, values).sorted {$0.0 < $1.0}
        //keys = combined.map {$0.0}
        //values = combined.map {$0.1}
    }
    
    func get(_ k: K)-> V? {
        if binarySearch(elements: keys, target: k) != nil {
            return values[binarySearch(elements: keys, target: k)!]
        }
        return nil
    }
    
    func insertPosition(_ k: K)-> Int {
        for i in 0..<count {
            if k < keys[i] {return i}
        }
        return keys.endIndex
    }
    
    func binarySearch(elements: Array<K>, target: K) -> Int? {
        var lowerIndex = 0
        var upperIndex = elements.count - 1
        
        while true {
            let currentIndex = (lowerIndex + upperIndex) / 2
            if lowerIndex > upperIndex {
                return nil
            } else if (elements[currentIndex] == target) {
                return currentIndex
            } else {
                if (elements[currentIndex] > target) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    
    subscript(key: K)-> V? {
        get {return get(key)}
        set(newValue) {set(key, newValue!)}
    }
    
    var description: String {
        var description = "["
        for i in 0..<keys.count {
            description += "\n\(keys[i]) : \(values[i])"
        }
        description += "\n]\n"
        return description
    }
}




//
//  main.swift
//  map
//
//  Created by Joshua Shen on 10/14/18.
//  Copyright © 2018 Joshua Shen. All rights reserved.
//

import Foundation

struct HashMap<K: Hashable, V>: CustomStringConvertible {
    var keys: Array<K?>
    var values: Array<V?>
    var collisionMap = LinearMap<K, V>()
    var count = 0
    var initialArraySize: Int
    var numberCollisions = 0
    
    init(initialArraySize: Int = 2000) {
        keys = Array<K?>(repeating: nil, count: initialArraySize)
        values = Array<V?>(repeating: nil, count: initialArraySize)
        self.initialArraySize = initialArraySize
    }
    
    mutating func set(_ k: K, _ v: V) {
        let index = abs(k.hashValue % initialArraySize)
        if keys[index] == nil {
            keys[index] = k
            values[index] = v
            count += 1
        } else {
            if keys[index] == k {values[index] = v}
            else {handleCollision(k, v)}
        }
    }
    
    mutating func handleCollision(_ k: K, _ v: V) {
        let oldCollisionCount = collisionMap.count
        collisionMap.set(k, v)
        if collisionMap.count > oldCollisionCount{
            count += 1
            numberCollisions += 1
        }
    }
    
    func get(_ k: K)-> V? {
        let index = abs(k.hashValue % initialArraySize)
        if keys[index] == k {return values[index]}
        return collisionMap.get(k)
    }
    
    subscript(key: K)-> V? {
        get {return get(key)}
        set(newValue) {set(key, newValue!)}
    }
    
    var description: String {
        var description = "["
        for k in keys where k != nil {
            description += "\n\(k!) : \(get(k!)!)"
        }
        for i in 0..<numberCollisions {
            description += "\n\(collisionMap.keys[i]) : \(collisionMap.values[i])"
        }
        description += "\n]\n"
        return description
    }
}


public class MapTest {
    var stringList = [String]()
    let chars = Array("abcdefghijklmnopqrstuvwxyz".characters)
    
    let MAX_SIZE = 1000
    let NUMBER_PUTS = 1000
    
    func getRandomInt(range: Int)-> Int {
        return Int(arc4random_uniform(UInt32(range)))
    }
    
    func makeString(length: Int)-> String {
        var s = ""
        let numberChars = chars.count
        for _ in 0..<length {
            s.append(chars[getRandomInt(range: numberChars)])
        }
        return s
    }
    
    func makeStringList(size: Int) {
        stringList = [String]()
        for _ in 0..<size {
            stringList.append(makeString(length: 10))
        }
    }
    
    func testLinearMap()->Bool {
        var value = ""
        var key = ""
        var map = LinearMap<String, String>()
        for i in 0..<NUMBER_PUTS {
            map.set(stringList[i],stringList[i])
        }
        
        for index in 0..<NUMBER_PUTS {
            key = stringList[index]
            value = map.get(key)!
            if (!(value == key)) {
                return false
            }
        }
        return true
    }
    
    func testBinaryMap()-> Bool {
        var value = ""
        var key = ""
        var map = BinaryMap<String, String>()
        for i in 0..<NUMBER_PUTS {
            map.set(stringList[i], stringList[i])
        }
        
        for index in 0..<NUMBER_PUTS {
            key = stringList[index]
            value = map.get(key)!
            if (!(value == key)) {
                return false
            }
        }
        return true
    }
    
    func testHashMap()-> Bool {
        var value = ""
        var key = ""
        var map = HashMap<String, String>()
        for i in 0..<NUMBER_PUTS {
            map.set(stringList[i], stringList[i])
        }
        
        //print(map)
        
        for index in 0..<NUMBER_PUTS {
            key = stringList[index]
            value = map.get(key)!
            if value != key {
                print(value)
                print(key)
                return false
            }
        }
        print("Collisions: \(map.numberCollisions)")
        return true
    }
    
    func doTest() {
        makeStringList(size: MAX_SIZE)
        print("String List Complete")
        print("Linear: \(testLinearMap())")
        print("Binary: \(testBinaryMap())")
        print("Hash: \(testHashMap())")
    }
}


let mt = MapTest()
mt.doTest()























