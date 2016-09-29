import Foundation
import UIKit
func empty<Element>() -> [Element] {
    return []
}
func isEmpty<Element>(set: [Element]) -> Bool {
    return set.isEmpty
}
func contains<Element: Equatable>(x: Element, _ set: [Element]) -> Bool {
    return set.contains(x)
}
func insert<Element: Equatable>(x: Element, _ set:[Element]) -> [Element] {
    return contains(x: x, set) ? set : [x] + set
}
indirect enum BinarySearchTree<Element: Comparable> {
    case Leaf
    case Node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

extension BinarySearchTree {
    init () {
        self = .Leaf
    }
    init (_ value: Element) {
        self = .Node(.Leaf, value, .Leaf)
    }
    var count: Int {
        switch self { case .Leaf:
            return 0
        case let .Node(left, _, right ):
            return 1 + left . count + right.count }
    }
    var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, x, right ):
            return left .elements + [x] + right.elements }
    }
    var isEmpty: Bool {
        if case .Leaf = self {
            return true
        }
        return false
    }
}
extension Swift.Sequence {
    func all ( predicate: (Iterator.Element) -> Bool) -> Bool {
        for x in self where !predicate(x) {
            return false
        }
        return true
    }
}
extension BinarySearchTree {
    func contains(x: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(_, y, _) where x == y:
            return true
        case let .Node(left, y, _) where x < y:
            return left.contains(x: x)
        case let .Node(_, y, right) where x > y:
            return right.contains(x: x)
        default:
            fatalError("The impossible occurred") }
    }
}

extension BinarySearchTree {
    mutating func insert(x: Element) {
        switch self {
        case .Leaf:
            self = BinarySearchTree(x)
        case .Node(var left, let y, var right ):
            if x < y { left.insert(x: x) }
            if x > y { right.insert(x: x) }
            self = .Node(left, y, right)
        } }
}


extension BinarySearchTree where Element: Comparable {
    var isBST: Bool {
        switch self {
        case .Leaf:
            return true
        case let .Node(left, x, right ):
            return left . elements.all { y in y < x } && right.elements.all { y in y > x }
                && left.isBST && right.isBST
        }
    }
}
let leaf: BinarySearchTree<Int> = .Leaf
let  five: BinarySearchTree<Int>= .Node(leaf,5,leaf)
        
let myTree: BinarySearchTree<Int> = BinarySearchTree()
var copied = myTree
copied.insert(x: 5)
copied.insert(x: 7)
copied.insert(x: 3)
copied.insert(x: 1)
copied.insert(x: 1)
copied.insert(x: 2)
(myTree.elements, copied.elements)


func autoComplete( history: [String], textEntered: String) -> [String] {
    return history.filter { $0.hasPrefix(textEntered)}
}

/*
 
 "Tries, also known as digital search trees, are a particular kind of ordered tree. Typically, tries are used to look up a string, which consists of a list of characters. Instead of storing
 strings in a binary search tree, it can be more efficient to store them in a structure that repeatedly branches over the strings’ constituent characters."
 */


struct Trie<Element: Hashable> {
    var isElement: Bool
    var children: [Element: Trie<Element>]
}

extension Dictionary {
    
    init(_ slice: Slice<Dictionary>) {
        self = [:]
        
        for (key, value) in slice {
            self[key] = value
        }
    }
    
}


/*
Make it to false because we don't want an empty string to be a member of the empty trie
 */
extension Trie {
    init () {
        isElement = false
        children = [:]
    }
}


extension Trie {
    var elements : [[Element]] {
    var result: [[Element]] = isElement ? [[]] : [] //is it a member of the trie? Is so, we still need to keep traversing. If it's not, let's get the word
    for (key, value) in children {
        result += value.elements.map{ [key] + $0}
    }
    return result
    }
}

extension Array {
    var decompose: (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}
//how to decompose with a generic collection
extension Collection {
    var decompose : (Iterator.Element, SubSequence)? {
        return isEmpty ? nil : (self.first!, self.dropFirst())
    }
}

func sum(xs:[Int]) -> Int {
    guard let (head, tail) = xs.decompose else {return 0 }
    print(tail)
    return head + sum(xs: tail)
}

func qsort(input: [Int]) -> [Int] {
    guard let (pivot, rest) = input.decompose else {return []}
    let lesser = rest.filter { $0 < pivot}
    let greater = rest.filter { $0 >= pivot}
    let pivArray = [pivot]
    return qsort(input: lesser) + pivArray + qsort(input: greater)
}

func one<T>(x: T?) -> AnyIterator<T> {
    return AnyIterator(IteratorOverOne(_elements: x))
}


extension BinarySearchTree {
    var inOrder: AnyIterator<Element> {
        switch self {
        case .Leaf:
            return AnyIterator{ return nil }
        case .Node(let left, let x, let right):
            return left.inOrder
        }
    }
}

extension Trie {
    
    /*
    First case: return a boolean indicating whether or not the string described by the trie is a current node
     Second case: the key is non empty but doesn't exist in the trie. In this case, we return false
     Thrid case: so if it exists, we keep looking in the subtrie
     
     */
    func lookup (key: [Element]) -> Bool {
        guard let (head,tail) = key.decompose else { return isElement}
        guard let subtrie = children[head] else { return false}
        return subtrie.lookup(key: tail)
    }
}


extension Trie {
    func withPrefix( prefix: [Element]) -> Trie<Element>? {
        guard let (head, tail) = prefix.decompose else {return self}
        guard let remainder = children[head] else { return nil}
        return remainder.withPrefix(prefix: tail)
    }
}


extension Trie {
    func autocomplete(key: [Element]) -> [[Element]] {
        return withPrefix(prefix: key)?.elements ?? []
    }
}


extension Trie {
    init(_ key: [Element]) {
        if let (head, tail) = key.decompose { //if the key is non-empty
            //we decompose it and create a Trie recursively from the tail.
        
            //then we create a dictionary of the childrens.
            let children = [head:  Trie(tail)]
            //then we create a Trie from the dictionary
            self = Trie(isElement: false, children: children)
            
        } else {
            //if it's empty, we create an empty trie story the empty string with an empty childrens
            self = Trie(isElement: true, children: [:])
        }
    }
}

/*
 
 var decompose: (Element, [Element])? {
 return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
 }
 */

//extension Trie {
////
////    //create a mutating version of the function
////    //func insert(key: [Element]) -> Trie<Element>  
////    if you want this to take a collection
////    func insert<Sequence :Collection> (key : Sequence) -> Trie<Element> where Sequence.Iterator.Element == Element {
//func insert(key: [Element]) -> Trie<Element>  {
//        guard let (head, tail) = key.decompose else {
//            //if empty, we set isElement to true and keep the children as empty
//            return Trie(isElement: true, children: children)
//        }
//        
//        
//        var newChildren = children
//        if let nextTrie = children[head] {
//            //if it's non-empty and the head exists in the children node, we just insert the tail in the next trie
//            newChildren[head] = nextTrie.insert(key: tail)
//        }
//        else {
//            //if it's non-empty and we don't have the head in the child, we just create a new Trie with the remainder f the data
//            newChildren[head] = Trie(tail)
//        }
//    
//        return Trie(isElement: isElement, children: newChildren)
//    }
//}


extension Trie {
    /*
     struct Trie<Element: Hashable> {
     let isElement: Bool
     let children: [Element: Trie<Element>]
     }
     
     */

    mutating func insert(key : [Element]) {
        guard let (head, tail) = key.decompose else {
            isElement = true
            children = [Element: Trie<Element>]()
            return
        }
        if children[head] != nil {
            children[head]?.insert(key: tail)
        }
        else {
            children[head] = Trie(tail)
        }
    }
}

func buildStringTrie(words: [String]) -> Trie<Character> {
    let emptyTrie = Trie<Character>()
    return words.reduce(emptyTrie) {
        trie, word in
        var trie = trie as  Trie<Character>
            trie.insert(key: Array(word.characters))
        return trie
    }
}
print("here")
func autoCompleteString(knownWords: Trie<Character>, word: String) -> [String] {
    let chars = Array(word.characters)
    let completed = knownWords.autocomplete(key: chars)
    return completed.map { chars in word + String(chars)}
}

let contents = ["cat", "car", "cart", "dog"]
let trieOfWords = buildStringTrie(words: contents)
print(autoCompleteString(knownWords: trieOfWords, word: "car"))
print(copied.contains(x: 5))
print(copied.elements)



