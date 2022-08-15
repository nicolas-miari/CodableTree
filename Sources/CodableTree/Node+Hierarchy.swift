import Foundation

// MARK: - Hierarchy Manipulation

extension Node {

  /**
   (Pretty much what says in the box)
   */
  public func insertChild(_ child: Node, at index: Int) {
    child.removeFromParent()
    children.insert(child, at: index)
    child.parent = self
  }

  /**
   Same as calling `insertChild(_:at:)` passing the maximum valid index (`self.children.count`).
   */
  public func addChild(_ child: Node) {
    insertChild(child, at: children.count)
  }

  /**
   Removes the child node at the specified index from the node's children, and returns it.
   */
  @discardableResult
  public func removeChild(at index: Int) -> Node {
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
    _ = parent.removeChild(at: index)
  }

  /**
   Exchanges the positions of the two child nodes at the specified indices.
   */
  public func swapChildren(at index1: Int, and index2: Int) {
    children.swapAt(index1, index2)
  }

  /**
   Transplants a child node from one parent to another.

   If `srcParent` and `dstParent` are the same, this is equivalent to calling
   `swapChildren(at:and:)` on either parent.
   */
  public static func moveNode(at srcIndex: Int, of srcParent: Node, to dstIndex: Int, of dstParent: Node) {
    guard srcParent !== dstParent else {
      return srcParent.swapChildren(at: srcIndex, and: dstIndex)
    }
    let child = srcParent.removeChild(at: srcIndex)
    dstParent.insertChild(child, at: dstIndex)
  }
}
