import XCTest
@testable import CodableTree

final class NodeTests: XCTestCase {

  // MARK: - Codable

  func testEncodeDecodePreservesEquality() throws {

    // GIVEN:
    let node = Node(name: "Root")
     node.addChild(Node(name: "Child 1", value: "123456"))
     node.addChild(Node(name: "Child 2", value: "789012"))
     let subfolder = Node(name: "Subfolder 1")
     subfolder.addChild(Node(name: "Child 3", value: "456789"))
     node.addChild(subfolder)

    // WHEN:
    let data = try JSONEncoder().encode(node)
    let recovered = try JSONDecoder().decode(Node.self, from: data)

    // THEN:
    XCTAssertEqual(node, recovered)
  }

  // MARK: - Contents

  func testDifferentNamesAreUnequal() {
    // GIVEN:
    let node1 = Node(name: "Node 1", value: "12345")
    let node2 = Node(name: "Node 2", value: "12345")

    // THEN:
    XCTAssertNotEqual(node1, node2)
  }

  func testDifferentPayloadsAreUnequal() {
    // GIVEN:
    let node1 = Node(name: "Node 1", value: "12345")
    let node2 = Node(name: "Node 1", value: "67890")

    // THEN:
    XCTAssertNotEqual(node1, node2)
  }

  func testDifferentTypesAreUnequal() {
    // GIVEN:
    let node1 = Node(name: "Node", value: "123456")
    let node2 = Node(name: "Node")

    // THEN:
    XCTAssertNotEqual(node1, node2)
  }

  func testDifferentNumberOfChildrenAreUnequal() {
    // GIVEN:
    let child1 = Node(name: "Child 1", value: "12345")
    let folder1 = Node(name: "Folder", children: [child1])
    let child2 = Node(name: "Child 2", value: "67890")
    let child3 = Node(name: "Child 3", value: "10111")
    let folder2 = Node(name: "Folder", children: [child2, child3])

    // THEN:
    XCTAssertNotEqual(folder1, folder2)
  }

  func testSameNumberOfChildrenButDifferentChildrenAreUnequal() {
    // GIVEN:
    let child1 = Node(name: "Child 1", value: "12345")
    let folder1 = Node(name: "Folder", children: [child1])
    let child2 = Node(name: "Child 2", value: "67890")
    let folder2 = Node(name: "Folder", children: [child2])

    // THEN:
    XCTAssertNotEqual(folder1, folder2)
  }

  func testGetPayload() throws {
    // GIVEN:
    let payload = "123456"
    let node = Node(name: "Node 1", value: payload)
    let folder = Node(name: "Folder 1")

    // THEN:
    XCTAssertEqual(node.value, payload)
    XCTAssertNil(folder.value)
  }

  func testSetPayload() throws {
    // GIVEN:
    let payload = "123456"
    let node = Node(name: "Node 1", value: payload)

    // WHEN:
    let newPayload = "7890"
    node.value = newPayload

    // THEN:
    XCTAssertEqual(node.value, newPayload)
  }

  func testChildren() throws {
    // GIVEN:
    let payload = "123456"
    let node = Node(name: "Node 1", value: payload)
    let folder = Node(name: "Folder 1", children: [node])

    XCTAssertEqual(node.children.count, 0)
    XCTAssertEqual(folder.children.count, 1)
  }

  // MARK: - Node Hierarchy

  func testAddChild() throws {
    // GIVEN:
    let node = Node(name: "Root")
    let child0 = Node(name: "Child 0", value: "123456")
    let child1 = Node(name: "Child 1", value: "789101")
     node.addChild(child0)
     node.addChild(child1)

    // THEN
    XCTAssertEqual(node.children[0], child0)
    XCTAssertEqual(node.children[1], child1)
  }

  func testRemoveChild() throws {
    // GIVEN:
    let node = Node(name: "Child")
    let parent = Node(name: "Parent", children: [node])

    // WHEN:
    parent.removeChild(at: 0)

    // THEN:
    XCTAssertNil(node.parent)
    XCTAssertEqual(parent.children.count, 0)
  }

  func testRemoveFromParent() throws {
    // GIVEN:
    let node = Node(name: "Child")
    let parent = Node(name: "Parent", children: [node])

    // WHEN:
    node.removeFromParent()

    // THEN:
    XCTAssertNil(node.parent)
    XCTAssertEqual(parent.children.count, 0)
  }

  func testRemoveFromMissingParent() throws {
    // GIVEN:
    let node = Node(name: "Child")

    // WHEN:
    node.removeFromParent()

    // THEN:
    XCTAssertNil(node.parent)
  }

  func testSwapChldren() throws {
    // GIVEN:
    let children = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent = Node(name: "Parent", children: children)

    // WHEN:
    let index1 = 3
    let index2 = 7
    parent.swapChildren(at: index1, and: index2)

    // THEN:
    XCTAssertEqual(parent.children[index1].name, "\(index2)")
    XCTAssertEqual(parent.children[index2].name, "\(index1)")
  }

  func testTransplantWithinSameParent() throws {
    // GIVEN:
    let children = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent = Node(name: "Parent", children: children)

    // WHEN:
    let index1 = 3
    let index2 = 7
    Node.moveNode(at: index1, of: parent, to: index2, of: parent)

    // THEN:
    XCTAssertEqual(parent.children[index1], children[index2])
    XCTAssertEqual(parent.children[index2], children[index1])
  }

  func testTransplantChild() throws {
    // GIVEN:
    let children1 = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent1 = Node(name: "Parent 1", children: children1)

    let children2 = (0 ... 20).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent2 = Node(name: "Parent 2", children: children2)

    // WHEN:
    let srcIndex = 5
    let dstIndex = 7
    try Node.moveNode(at: srcIndex, of: parent1, to: dstIndex, of: parent2)

    // THEN
    XCTAssertEqual(parent1.children.count, children1.count - 1)
    XCTAssertEqual(parent2.children.count, children2.count + 1)
    XCTAssertEqual(parent2.children[dstIndex], children1[srcIndex])
  }

  func testIsDescendantInChain() {
    // GIVEN:
    let child = Node(name: "Child", value: "")
    let parent = Node(name: "Parent", children: [child])
    let root = Node(name: "Root", children: [parent])

    // THEN:
    XCTAssertTrue(child.isDescendant(of: parent))
    XCTAssertTrue(parent.isDescendant(of: root))
    XCTAssertTrue(child.isDescendant(of: root))
    XCTAssertFalse(child.isDescendant(of: child))  // not descendant of self
    XCTAssertFalse(parent.isDescendant(of: child)) // nor descendant of direct child
    XCTAssertFalse(root.isDescendant(of: child))   // not descendant of distant descendant
  }

  func testIndexInParent() {
    // GIVEN:
    let child0 = Node(name: "Child 0")
    let child1 = Node(name: "Child 1")
    let child2 = Node(name: "Child 2")
    let parent = Node(name: "Parent", children: [child0, child1, child2])

    // THEN:
    XCTAssertEqual(child0.indexInParent, 0)
    XCTAssertEqual(child1.indexInParent, 1)
    XCTAssertEqual(child2.indexInParent, 2)
    XCTAssertNil(parent.indexInParent)
  }
  

  // MARK: - Grouping

  func testGroupChlidren() throws {
    // GIVEN:
    let children = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent = Node(name: "Parent", children: children)

    // WHEN:
    let indices = IndexSet([2, 3, 5])
    try parent.groupChildren(at: indices, name: "Subfolder")

    // THEN:
    XCTAssertEqual(parent.children[0].value, "0")
    XCTAssertEqual(parent.children[1].value, "1")
    XCTAssertEqual(parent.children[3].value, "4")
    XCTAssertEqual(parent.children[4].value, "6")
    XCTAssertEqual(parent.children[5].value, "7")
    XCTAssertEqual(parent.children[6].value, "8")
    XCTAssertEqual(parent.children[7].value, "9")
    XCTAssertEqual(parent.children[8].value, "10")
  }

  func testGroupEmptyChildrenFailsSilently() throws {
    // GIVEN:
    let children = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent = Node(name: "Parent", children: children)

    // WHEN:
    try parent.groupChildren(at: IndexSet(), name: "...")

    // THEN:
    XCTAssertEqual(parent.children, children)
  }

  func testSplitLeafThrows() throws {
    // GIVEN:
    let node = Node(name: "Node", value: "12345")

    // THEN:
    XCTAssertThrowsError(try node.splitGroup())
  }

  func testSplitOrphanThrows() throws {
    // GIVEN:
    let children = (0 ... 10).map { (index) -> Node in
      return Node(name: "\(index)", value: "\(index)")
    }
    let parent = Node(name: "Parent", children: children)

    // THEN:
    XCTAssertThrowsError(try parent.splitGroup())
  }

  func testSplitSubfolder() throws {
    // GIVEN:
    let parent = Node(name: "Parent", children: [
      Node(name: "0", value: "0"),
      Node(name: "1", value: "1"),
      Node(name: "2", value: "2"),
      Node(name: "Subfolder", children: [
        Node(name: "3", value: "3"),
        Node(name: "4", value: "4"),
        Node(name: "5", value: "5"),
      ]),
      Node(name: "6", value: "6"),
      Node(name: "7", value: "7"),
    ])

    // WHEN:
    try parent.children[3].splitGroup()

    // THEN
    for index in 0 ... 7 {
      let child = parent.children[index]
      XCTAssertEqual("\(index)", child.name)
    }
  }
}
