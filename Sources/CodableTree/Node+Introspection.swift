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
  public func isDescendant(of otherNode: Node) -> Bool {
    guard let parent = parent else {
      return false
    }
    if parent == otherNode {
      return true
    }
    return parent.isDescendant(of: otherNode)
  }
}
