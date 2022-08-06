import Foundation

// MARK: - Hierarchy Manipulation

extension Node {

  /**
   (Pretty much what says in the box)
   */
  public func insertChild(_ child: Node, at index: Int) throws {
    guard isBranch else {
      throw NodeError.invalidOperation(detail: "Cannot insert children into a leaf node.")
    }
    child.removeFromParent()

    var children = self.children
    children.insert(child, at: index)
    child.parent = self
    self.nodeType = .branch(children: children)
  }

  /**
   Same as calling `insertChild(_:at:)` passing the maximum valid index (`self.children.count`).
   */
  public func addChild(_ child: Node) throws {
    try insertChild(child, at: children.count)
  }

  /**
   Removes the child node at the specified index from the node's children, and returns it.
   */
  @discardableResult
  public func removeChild(at index: Int) throws -> Node {
    guard isBranch else {
      throw NodeError.invalidOperation(detail: "Cannot remove children from a leaf node.")
    }
    let child = children.remove(at: index)
    child.parent = nil
    return child
  }

  /**
   Removes the node from its parent node's children, and sets `parent` to `nil`.
   */
  public func removeFromParent() {
    guard let parent = parent else {
      return
    }
    guard let index = parent.children.firstIndex(where: { $0 === self }) else {
      return
    }
    _ = try? parent.removeChild(at: index)
  }

  /**
   Exchanges the positions of the two child nodes at the specified indices.
   */
  public func swapChildren(at index1: Int, and index2: Int) throws {
    guard isBranch else {
      throw NodeError.invalidOperation(detail: "Cannot swap children in a leaf node.")
    }
    children.swapAt(index1, index2)
  }

  /**
   Transplants a child node from one parent to another.

   If `srcParent` and `dstParent` are the same, this is equivalent to calling
   `swapChildren(at:and:)` on either parent.
   */
  public static func moveNode(at srcIndex: Int, of srcParent: Node, to dstIndex: Int, of dstParent: Node) throws {
    guard srcParent !== dstParent else {
      return try srcParent.swapChildren(at: srcIndex, and: dstIndex)
    }

    let child = try srcParent.removeChild(at: srcIndex)
    try dstParent.insertChild(child, at: dstIndex)
  }
}
