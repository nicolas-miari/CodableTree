import Foundation

// MARK: - Hierarchy Manipulation

extension Node {

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

  public func addChild(_ child: Node) throws {
    try insertChild(child, at: children.count)
  }

  @discardableResult
  public func removeChild(at index: Int) throws -> Node {
    guard isBranch else {
      throw NodeError.invalidOperation(detail: "Cannot remove children from a leaf node.")
    }
    let child = children.remove(at: index)
    child.parent = nil
    return child
  }

  public func removeFromParent() {
    guard let parent = parent else {
      return
    }
    guard let index = parent.children.firstIndex(where: { $0 === self }) else {
      return
    }
    _ = try? parent.removeChild(at: index)
  }

  public func swapChildren(at index1: Int, and index2: Int) throws {
    guard isBranch else {
      throw NodeError.invalidOperation(detail: "Cannot swap children in a leaf node.")
    }
    children.swapAt(index1, index2)
  }

  public static func moveNode(at srcIndex: Int, of srcParent: Node, to dstIndex: Int, of dstParent: Node) throws {
    guard srcParent !== dstParent else {
      return try srcParent.swapChildren(at: srcIndex, and: dstIndex)
    }

    let child = try srcParent.removeChild(at: srcIndex)
    try dstParent.insertChild(child, at: dstIndex)
  }
}
