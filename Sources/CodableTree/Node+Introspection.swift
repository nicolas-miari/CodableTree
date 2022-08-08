//
//  File.swift
//  
//
//  Created by Nicolás Miari on 2022/08/06.
//

import Foundation

// MARK: - Node Introspection

extension Node {

  /**
   Returns `true` if the node is of **leaf** type.
   */
  public var isLeaf: Bool {
    switch nodeType {
    case .leaf:
      return true
    case .branch:
      return false
    }
  }

  /**
   Returns `true` if the node is of **branch** type.
   */
  public var isBranch: Bool {
    switch nodeType {
    case .branch:
      return true
    case .leaf:
      return false
    }
  }

  /**
   An array containing a branch node's child nodes.

   For a **leaf** node, this property always returns an empty array, and attempting to set a value
   fails silently (this is OK because the setter is internal to the package, and all public methods
   check for the node type before setting this property).
   */
  public internal(set) var children: [Node] {
    get {
      switch nodeType {
      case .branch(let children):
        return children

      case .leaf:
        return []
      }
    }
    set {
      switch nodeType {
      case .branch:
        self.nodeType = .branch(children: newValue)
      case .leaf:
        break
      }
    }
  }

  /**
   A leaf node's payload (content).

   For a **branch** node, this property always returns `nil`, and attempting to set a value fails
   silently (this is OK because the setter is internal to the package, and all public methods check
   for the node type before setting this property).
   */
  public internal(set) var payload: String? {
    get {
      switch nodeType {
      case .leaf(let payload):
        return payload
      case .branch:
        return nil
      }
    }
    set {
      switch nodeType {
      case .leaf:
        if let value = newValue {
          self.nodeType = .leaf(payload: value)
        }
      case .branch:
        break
      }
    }
  }

  /**
   Returns `nil` if there is no parent.
   */
  public var indexInParent: Int? {
    guard let parent = parent else {
      return nil
    }
    guard let index = parent.children.firstIndex(of: self) else {
      fatalError("Node: \(name) not found among its parent's children. ")
    }
    return index
  }

  /**
   Returns `true` if `otherNode` can be reached by recusrively traversing `parent` links from
   `self`.
   */
  func isDescendant(of otherNode: Node) -> Bool {
    guard let parent = parent else {
      return false
    }
    if parent == otherNode {
      return true
    }
    return parent.isDescendant(of: otherNode)
  }
}
