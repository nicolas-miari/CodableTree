import Foundation

// MARK: - Regrouping

extension Node {

  /**
   Replaces the specified children with a new group node that contains them.

   Fails silently if the indes set is empty.
   */
  public func groupChildren(at indices: IndexSet, name: String) throws {
    // First, convert to Int because FUCK YOU IndexSet piece of shit good for nothing API is
    // unusable.
    let mappedIndices: [Int] = indices.map { $0 }
    guard let first = mappedIndices.first else {
      return
    }

    let selectChildren = mappedIndices.map { (index: Int) -> Node in
      return children[index]
    }

    let subfolder = Node(name: name, value: nil)
    selectChildren.reversed().forEach {
      subfolder.insertChild($0, at: 0)
    }
    insertChild(subfolder, at: first)
  }

  /**
   Removes self from parent and inserts own children starting at own original index.
   */
  public func splitGroup() throws {
    // We need our own index within out parent to insert all of our children there.
    guard let parent = parent, let index = parent.children.firstIndex(of: self) else {
      throw NodeError.invalidOperation(detail: "Cannot split orphaned node.")
    }

    // Remove self:
    removeFromParent()

    // Insert all children back to front at the same index, to rpeserve the orginal order within
    // self
    children.reversed().forEach {
      parent.insertChild($0, at: index)
    }


  }
}
