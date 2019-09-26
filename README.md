## Advanced Swift 

### 第2章 内建集合类型

#### 数组

##### 切片

```swift
let fibs = [0, 1, 1, 2, 3, 5]
let slice = fibs[1...]
slice // [1, 1, 2, 3, 5]
type(of: slice) // ArraySlice<Int>
```

**要点**

1.  切片类型只是数组的一种表示方式，它背后的数据仍然是原来的数组，只不过是用切片的方式来进行表示，slice共享fibs数组。
2.  访问slice里的数据不能从0开始，而是从slice.startIndex开始，到slice.endIndex结束。访问0可能导致崩溃。
3.  改变fibs时，slice不受影响。我估计改变fibs或者slice，**写时复制**。

```swift
var fibs = [0, 1, 1, 2, 3, 5]
var slice = fibs[1...] // [1, 1, 2, 3, 5]
fibs[2] = [11]
fibs.remove(at: 3) // [1, 1, 2, 3, 5] 
slice[slice.startIndex] = 10 // [10, 1, 2, 3, 5] 
slice[0] // 越界崩溃
```

#### 字典

##### Hashable

```swift
protocol Hashable: Equatable {
  func hash(into hasher: inout Hasher)
}
```

**自动实现(同样适用于Equatable)**

1.  对于struct，所有的存储属性conform to Hashable
2.  对于enum，所有的associated value conform to Hashable
3.  对于enum，如果没有associated value，不需要声明就自动conform to Hashable
4.  class需要手动实现
5.  两个同样的实例 (== 定义相同)，必须拥有同样的哈希值。不过反过来，两个相同哈希值的实例不一定需要相等

```swift
class Point: Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
```

#### Set

1.  和 *Dictionary* 一样，Set 也是通过哈希表实现的，并拥有类似的性能特性和要求。测试集合中是 否包含某个元素是一个常数时间的操作，和字典中的键一样，集合中的元素也必须满足 *Hashable*
2.  *Set* 遵守 *ExpressibleByArrayLiteral* 协议
3.  使用Set的场景：a、高效地测试某个元素是否存在于序列中；b、保证序列中不出现重复元素；c、集合操作，交集、并集
4.  *SetAlgebra*协议
5.  *IndexSet*和*CharacterSet*
6.  既保证有序又保证唯一性

```swift
extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
}
```

##### IndexSet

*IndexSet* 表示了一个由正整数组成的集合。当然，你可以用 *Set<Int>* 来做这件事，但是 *IndexSet* 更加高效，因为它内部使用了**一组范围列表**进行实现。

```swift
var indices = IndexSet()
indices.insert(integersIn: 1..<5)
indices.insert(integersIn: 11..<15)
let evenIndices = indices.filter { $0 % 2 == 0 } // [2, 4, 12, 14]
```

##### CharacterSet

*CharacterSet* 是一个高效的存储 Unicode 码点 (code point) 的集合。

#### Range

半开范围 *Range*: ..<，只有半开范围能表示空间隔，例如5..<5

闭合访问 *ClosedRange*: …，只有闭合范围能包括最大值

元素confirm to *comparable*协议

ClosedRange和Range不能相互转换

##### 可数范围

*CountableRange*和*CountableClosedRange*

```swift
typealias CountableRange<Bound> = Range<Bound> where Bound : Strideable, Bound.Stride : SignedInteger

typealias CountableClosedRange<Bound> = ClosedRange<Bound> where Bound : Strideable, Bound.Stride : SignedInteger
```

元素confirm to *Strideable*协议，步长是SignedInteger类型

```swift
extension Range : Sequence where Bound : Strideable, Bound.Stride : SignedInteger {}

extension Range : Collection, BidirectionalCollection, RandomAccessCollection where Bound : Strideable, Bound.Stride : SignedInteger {}

extension ClosedRange : Sequence where Bound : Strideable, Bound.Stride : SignedInteger {}

extension ClosedRange : Collection, BidirectionalCollection, RandomAccessCollection where Bound : Strideable, Bound.Stride : SignedInteger {}
```

因为*Strideable*协议，使得*CountableRange*和*CountableClosedRange*支持*Sequence*、*Collection*、*BidirectionalCollection*以及*RandomAccessCollection*协议

因为*Sequence*x协议，所有可以迭代

```swift
for i in 0..<10 {}
```

因为*RandomAccessCollection*协议，所有通过索引访问元素

```swift
let range = 1..<10
range[range.startIndex] // 1
```

range.startIndex的类型是Int，但是range.startIndex不是从0开始

如果你想要对连续的浮点数值进行迭代的话，你可以通过使用 **stride(from:to:by)** 和 **stride(from:through:by)** 方法来创建序列用以迭代

```swift
func stride<T>(from start: T, to end: T, by stride: T.Stride) -> StrideTo<T> where T : Strideable
extension StrideTo : Sequence {}

for radians in stride(from: 0.0, to: .pi * 2, by: .pi / 2) {
    let degrees = Int(radians * 180 / .pi)
    print("Degrees: \(degrees), radians: \(radians)")
}
```

##### 部分范围

```swift
let fromA: PartialRangeFrom<Character> = Character("a")...
let throughZ: PartialRangeThrough<Character> = ...Character("z") 
let upto10: PartialRangeUpTo<Int> = ..<10
let fromFive: CountablePartialRangeFrom<Int> = 5...
```

只有*CountablePartialRangeFrom*这一种可数类型

```swift
typealias CountablePartialRangeFrom<Bound> = PartialRangeFrom<Bound> where Bound : Strideable, Bound.Stride : SignedInteger
```

##### RangeExpression

上述8中类型都confirm to *RangeExpression*

```swift
public protocol RangeExpression {
associatedtype Bound: Comparable
func contains(_ element: Bound) -> Bool // 某个元素是否被包括在该范围中
func relative<C>(to collection: C) -> Range<Bound> where C : Collection, Self.Bound == C.Index // 给定一个集合类型，它能够计算出表达式所指定的完整的Range，例如array[2..<4]
static func ~= (pattern: Self, value: Self.Bound) -> Bool // switch case中模式匹配
```

**无边界**

array[…]

[Swift 标准库中的一个特殊实现]([https://tonisuter.com/blog/2017/08/unbounded-ranges-swift-4/](https://tonisuter.com/blog/2017/08/unbounded-ranges-swift-4/))

```swift
public typealias UnboundedRange = (UnboundedRange_)->()

public enum UnboundedRange_ {
  public static postfix func ... (_: UnboundedRange_) -> () {
    fatalError("uncallable")
  }
}

extension Collection {
  @_inlineable
  public subscript(x: UnboundedRange) -> SubSequence {
    return self[startIndex...]
  }
}
```

### 第3章 集合类型协议

#### Sequence

满足*Sequence*协议非常简单，只需要提供一个返回iterator迭代器的`makeIterator`方法

```swift
protocol Sequence {
	associatedtype Element where Self.Element == Self.Iterator.Element
	associatedtype Iterator: IteratorProtocol 
	func makeIterator() -> Iterator
	// ...
}

protocol IteratorProtocol { 
	associatedtype Element 
	mutating func next() -> Element?
}
```

##### Example

见代码

##### AnyIterator

 迭代器一般具有值语义，除了*AnyIterator*

*AnyIterator*是一个对别的迭代器进行封装的迭代器，用来将原来的迭代器的具体类型”抹掉“，不具有值语义。

值语义

```swift
var iterator1 = FibsIterator()
print(iterator1.next()) // 0
print(iterator1.next()) // 1
print(iterator1.next()) // 1
var iterator2 = iterator1 
print(iterator1.next()) // 2
print(iterator2.next()) // 2
print(iterator1.next()) // 3
print(iterator2.next()) // 3
```

非值语义

```swift
var iterator1 = FibsIterator()
var anyIterator = AnyIterator(iterator1)
print(anyIterator.next()) // 0
print(anyIterator.next()) // 1
print(anyIterator.next()) // 1
var iterator2 = anyIterator
print(anyIterator.next()) // 2
print(iterator2.next())   // 3
print(anyIterator.next()) // 5
print(iterator2.next())   // 8
```

*AnyIterator*还有一个初始化方法，那就是直接接受一个next函数作为参数

```swift
func fibsIterator() -> AnyIterator<Int> { 
	var state = (0, 1)
	return AnyIterator {
		let upcomingNumber = state.0 
		state = (state.1, state.0 + state.1) 
		return upcomingNumber
	} 
}
```

搭配使用*AnySequence*，创建序列就非常容易了。

AnySequence提供一个初始化方法，接受返回值为迭代器的函数作为参数。

```swift
let fibsSequence = AnySequence(fibsIterator)
```

##### sequence函数

-   `sequence(first:next:)`，将使用第一个参数的值作为序列的首个元素，并使用 next 参数传入的闭包生成序列的后续元 素，最后返回生成的序列
-   `sequence(state:next)`，因为它可以在两次 next 闭 包被调用之间保存任意的可变状态，所以它更强大一些

```swift
let fibsSequence = sequence(state: (0, 1)) { (state: inout (Int, Int)) -> Int? in 
	let upcomingNumber = state.0
	state = (state.1, state.0 + state.1)
	return upcomingNumber 
}
```

##### 序列与迭代器之间的关系

可以单纯地将迭代器声明为满足 *Sequence* 来将它转换为一个序列，因为 *Sequence* 提供了一个默认的 `makeIterator` 实现，对于那些满足协议的迭代器类型，这个方法将返回 self 本身。所以我们只需要实现`next`方法，就同时支持*Iterator*和*Sequence*协议。

标准库中的大部分迭代器还是满足了 Sequence 协议的

##### 链表

见代码

#### 集合类型

Collection协议有5个关联类型

```swift
protocol Collection: Sequence {
  associatedtype Element

  associatedtype Index : Comparable where Self.Index == Self.Indices.Element, Self.Indices.Element == Self.Indices.Index, Self.Indices.Index == Self.SubSequence.Index, Self.SubSequence.Index == Self.Indices.Indices.Element, Self.Indices.Indices.Element == Self.Indices.Indices.Index, Self.Indices.Indices.Index == Self.SubSequence.Indices.Element, Self.SubSequence.Indices.Element == Self.SubSequence.Indices.Index, Self.SubSequence.Indices.Index == Self.SubSequence.Indices.Indices.Element, Self.SubSequence.Indices.Indices.Element == Self.SubSequence.Indices.Indices.Index

  associatedtype Iterator = IndexingIterator<Self>

  associatedtype SubSequence : Collection = Slice<Self> where Self.Element == Self.SubSequence.Element, Self.SubSequence == Self.SubSequence.SubSequence

  associatedtype Indices : Collection = DefaultIndices<Self> where Self.Indices == Self.Indices.SubSequence
}
```

Collection的最小实现

```swift
protocol Collection: Sequence { 
  /// ⼀一个表示集合中位置的类型
  associatedtype Index: Comparable
  /// ⼀一个⾮非空集合中⾸首个元素的位置
  var startIndex: Index { get }
  /// 集合中超过末位的位置---也就是⽐比最后⼀一个有效下标值⼤大 1 的位置 
  var endIndex: Index { get }
  /// 返回在给定索引之后的那个索引值 
  func index(after i: Index) -> Index
  /// 访问特定位置的元素
  subscript(position: Index) -> Element { get } 
}
```

##### Indices

它代表对于集合的所有有效下标的索引所组成的集合，并以升序进行排列。

Indices 的默认类型是 DefaultIndices<Self>。和 Slice 一样，它是对于原来的集合类型的简单封装，并包含起始和结束索引。它需要保持对原集合的引用，这样才能够对索引进行步进。当用戶在迭代索引的同时改变集合的内容的时候，可能会造成意想不到的性能问题：如果集合是以写时复制 (就像标准库中的所有集合类型所做的一样) 来实现的话，这个对于集合的额外引用 将触发不必要的复制。

如果在为自定义集合提供另外的 Indices 类型作为替换的话，你不需要让它保持对原集合的引用，这样做可以带来性能上的提升。这对于那些计算索引时不依赖于集合本身的集合类型都是有效的，比如数组或者我们 的队列就是这样的例子。

#### 索引

见代码

#### 切片

如果你在通过集合类型的 indices 进行迭代时，修改了集合的内容，那么 indices 所持有的任何对原来集合类型的强引用都会破坏写时复制的性能优化，因为这会造成不必要的复制操作。如果集合的尺寸很大的话，这会对性能造成很大的影响。

要避免这件事情发生，你可以将 for 循环替换为 while 循环，然后手动在每次迭代的时候增加索引值，这样你就不会用到 indices 属性。当你这么做的时候，要记住一定要从collection.startIndex 开始进行循环，而不要把 0 作为开始。

#### 专门的集合类型

-   BidirectionalCollection => 一个既支持前向又支持后向遍历的集合。
-   RandomAccessCollection => 一个支持高效随机存取索引遍历的集合。
-   MutableCollection => 一个支持下标赋值的集合。
-   RangeReplaceableCollection => 一个支持将任意子范围的元素用别的集合中的元素进行替换的集合。

##### BidirectionalCollection

```swift
protocol BidirectionalCollection {
  /// 获取前一个索引
  func index(before i: Self.Index) -> Self.Index
}

extension BidirectionalCollection {
  /// 最后一个元素
  var last: Self.Element? { 
    return isEmpty ? nil : self[index(before: endIndex)]
  }
  /// 返回集合中元素的逆序表示⽅方式似乎数组
  /// - 复杂度: O(1)
  public func reversed() -> ReversedCollection<Self> {
    return ReversedCollection(_base: self) 
  }
}
```

ReverseCollection 不会真的去将元素做逆序操作，而是会持有原来的集合，并且使用逆向的索引。

```swift
extension FIFOQueue: BidirectionalCollection {
    func index(before i: Int) -> Int {
        precondition(i > startIndex)
        return i - 1
    }
}
```

#####  RandomAccessCollection

*RandomAccessCollection*提供了最高效的元素存取方式，它能够在常数时间内跳转到任意索引。满足该协议的类型必须能够 (a) 以任意距离移动一个索引，以及 (b) 测量任意两个索引之间的距离，两者都需要是 **O(1)** 时间常数的操作。

#####  MutableCollection

单个元素的下标访问方法 subscript 现在必须提供一个 setter

```swift
extension FIFOQueue: MutableCollection {
  public subscript(position: Int) -> Element { 
    get {
        precondition((0..<endIndex).contains(position), "Index out of bounds") 
        if position < left.endIndex {
          return left[left.count - position - 1] 
        } else {
          return right[position - left.count] 
        }
    } 
    set {
        precondition((0..<endIndex).contains(position), "Index out of bounds") 
        if position < left.endIndex {
          left[left.count - position - 1] = newValue 
        } else {
          return right[position - left.count] = newValue
        } 
     }
   }
}
```

注意编译器不让我们向一个已经存在的 Collection 中通过扩展添加下标 setter 方法

#####  RangeReplaceableCollection

```swift
protocol RangeReplaceableCollection {
  /// 一个空的初始化方法，在泛型函数中这很有用，因为它允许一个函数创建相同类型的新的空集合
  init()
  /// 它接受一个要替换的范围以及一个用来进行替换的集合
  mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C) where C : Collection, Self.Element == C.Element
}
```

confirm to *RangeReplaceableCollection*，自动获得以下功能

-   append(_:)和append(contentsOf:) => 将endIndex..<endIndex(也就是说末尾的空范 围) 替换为单个或多个新的元素。
-   remove(at:)和removeSubrange(_:) => 将i...i或者subrange替换为空集合。
-   insert(at:)和insert(contentsOf:at:) => 将i..<i(或者说在数组中某个位置的空范围)替换为单个或多个新的元素。
-   removeAll => 将startIndex..<endIndex替换为空集合。

```swift
extension FIFOQueue: RangeReplaceableCollection {
    mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where C.Element == Element {
        right = left.reversed() + right
        left.removeAll()
        right.replaceSubrange(subrange, with: newElements)
    }
}
```

### 第4章 可选值

##### 一些有意思的语法

```swift
// x?是.Some(x)的缩写
var array = ["one","two","three"] 
switch array.index(of: "four") { 
	case let idx?: array.remove(at: idx) 
	case nil: break
}

for case let i? in maybeInts { ... }
for case nil in maybeInts { ... }
```

```swift
let j = 5 
if case 0..<10 = j { ... }
```

if case/for case/switch case使用 **~=** 运算符重载 

```swift
struct Pattern {
	let s: String
	init(_ s: String) { self.s = s }
}
func ~=(pattern: Pattern, value: String) -> Bool { 
	return value.range(of: pattern.s) != nil
}
let s = "Taylor Swift"
if case Pattern("Swift") = s { ... }
```

```swift
struct Person { 
	var name: String 
	var age: Int
}
var optionalLisa: Person? = Person(name: "Lisa Simpson", age: 8)
optionalLisa?.age += 1 // 注意！
```

请注意 a = 10 和 a? = 10 的细微不同。前一种写法无条件地将一个新值赋给变量，而后一种写法只在 a 的值在赋值发生前不是 nil 的时候才生效。

##### a ?? b ?? c 和 (a ?? b) ?? c 的区别

对于一层可选值他们是一样的，但是对于双层嵌套可选值就不一样了

```swift
let s1: String?? = nil // nil
(s1 ?? "inner") ?? "outer" // inner
let s2: String?? = .some(nil) // Optional(nil) 
(s2 ?? "inner") ?? "outer" // outer
```

### 第五章 结构体和类

通过在结构体扩展中自定义初始化方法，我们就可以同时保留原来的初始化方法

`didSet`对定义在全局的结构体变量也使用

```swift
struct Point {
    var x = 0
    var y = 0
}
var point = Point(x: 10, y: 10) {
    didSet {
        print("didSet")
    }
}
// 赋值的时候，didSet会被触发
point = Point(x: 20, y: 20) 
// 当我们只是改变深入结构体中的某个属性的时候，didSet也会被触发
point.x = 20
```

对结构体进行改变，在语义上来说，与重新 为它进行赋值是相同的。即使在一个更大的结构体上只有某一个属性被改变了，也等同于整个结构体被用一个新的值进行了替代。在一个嵌套的结构体的最深层的某个改变，将会一路向上反映到最外层的实例上，并且一路上触发所有它遇到的 `willSet` 和 `didSet`。

虽然语义上来说，我们将整个结构体替换为了新的结构体，但是一般来说这不会损失性能，编译器可以原地进行变更。由于这个结构体没有其他所有者，实际上我们没有必要进行复制。不过如果有多个持有者的话，重新赋值意味着发生复制。

因为*Int*其实也是结构体，所以修改Int变量，`didSet`也会被触发。

因为标准库中的集合类型是结构体，很自然地它们也遵循同样地工作方式。在数组中添加元素将会触发数组的 `didSet`，通过数组的下标对数组中的某个元素进行变更也同样会触发，更改数组中某个元素的某个属性值也同样会触发。

**VS class**

```swift
class Point {
    var x = 0
    var y = 0
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
var point = Point(x: 10, y: 10) {
    didSet {
        print("didSet")
    }
}
// didSet会触发
point = Point(x: 20, y: 20)
// didSet不会触发，point不会发生改变，只是point指向的对象发生了改变
point.x = 20
```

#### mutating的本质是inout

**mutating **关键字将隐式的*self*参数变为可变的

**+=** 运算符需要左边的参数是inout

```swift
extension Point {
  static func +=(lhs: inout Point, rhs: Point) {
	lhs = lhs + rhs
  }
}
```

##### 使用值类型避免并行Bug

```swift
class BinaryScanner { 
  var position: Int
  let data: Data 
  init(data: Data) {
    self.position = 0
    self.data = data 
  }
}

extension BinaryScanner { 
  func scanByte() -> UInt8? {
    guard position < data.endIndex else { return nil }
    position += 1
    return data[position-1]
  } 
}

func scanRemainingBytes(scanner: BinaryScanner) {
  while let byte = scanner.scanByte() {
    print(byte) 
  }
}


for _ in 0..<Int.max {
  let newScanner = BinaryScanner(data: Data("hi".utf8))
  DispatchQueue.global().async {
    // 引用相同的newScanner，下标访问可能会越界
    scanRemainingBytes(scanner: newScanner) 
  }
  // 引用相同的newScanner，下标访问可能会越界
  scanRemainingBytes(scanner: newScanner) 
}
```

如果 BinaryScanner 是一个结构体，而非类的话，每次 scanRemainingBytes 的调用都将获取 它自己的 newScanner 的独立的复制。这样一来，这些调用将能够在数组上保持安全的迭代， 而不必担心结构体被另一个方法或者线程所改变。

#### 写时复制

它的工作方式是，每当值被改变，它首先检查它对存储缓冲区的引用是否是唯一的，或者说，检查值本身是不是这块缓冲区的唯一拥有者。如果是，那么缓冲区可以进行原地变更，也不会有复制被进行。不过，如果缓冲区有一个以上的持有者，那么值就需要先进行复制，然后对复制的值进行变化，而保持其他的持有者不受影响。

作为一个结构体的作者，你并不能免费获得写时复制的行为，你需要自己进行实现。当你自己的类型内部含有一个或多个可变引用，同时你想要保持值语义时，你应该为其实现写时复制。为了维护值语义，通常都需要在每次变更时，都进行昂贵的复制操作，但是写时复制技术避免了在非必要的情况下的复制操作。

```swift
// Objective-C的类，isKnownUniquelyReferenced直接返回false，所以需要包装一下
final class Box<A> {
	var unbox: A
	init(_ value: A) { 
		self.unbox = value 
	}
}

struct MyData {
  private var _data: Box<NSMutableData> 
  var _dataForWriting: NSMutableData {
    mutating get {
	  if !isKnownUniquelyReferenced(&_data) {
		_data = Box(_data.unbox.mutableCopy() as! NSMutableData) 
		print("Making a copy")
	  }
	  return _data.unbox
    }
  } 
  
  init() {
	_data = Box(NSMutableData()) 
  }
  
  init(_ data: NSData) {
	_data = Box(data.mutableCopy() as! NSMutableData)
  } 
}

extension MyData {
  mutating func append(_ byte: UInt8) {
    var mutableByte = byte
    _dataForWriting.append(&mutableByte, length: 1) 
  }
}
```

#### 写时复制陷阱

```swift
final class Empty { } 
struct COWStruct {
  var ref = Empty()
  mutating func change() -> String {
    if isKnownUniquelyReferenced(&ref) {
      return "No copy" 
    } else {
        return "Copy" 
    }
  }
}

/* 
当我们将结构体放到数组中时，我们可以直接改变数组元素，且不需要进行复制。这是因为在使用数组下标访问元素时，我们是直接访问内存的位置
Array 通过使用地址器 (addressors) 的方式实现下标。地址器允许对内存进行直接访问。数组的下标并不是返回元素，而是返回一个元素的地址器。这样一来，元素的内存可以被原地改变，而不需要再进行不必要的复制。
*/
var array = [COWStruct()]
array[0].change() // No copy

/* 
现在字典也采用了和Array一样的处理方式
*/
var dict = ["key": COWStruct()] 
dict["key"]?.change() // No Copy

/*
当你在使用集合或者自己的结构体时，表现就不一样了。比如，我们可以创建一个储存某个值的简单地容器类型，通过直接访问存储的属性，或者间接地使用下标，都可以访问到这个值。
当我们直接访问它的时候，我们可以获取写时复制的优化，但是当我们用下标间接访问的时候，复制会发生:
*/
struct ContainerStruct<A> { 
var storage: A 
subscript(s: String) -> A {
  get { return storage }
  set { storage = newValue } }
}
var d = ContainerStruct(storage: COWStruct()) 
d.storage.change() // No copy 
d["test"].change() // Copy
```

#### 闭包

函数也是引用类型

#### 内存

值类型不会产生循环引用

```swift
struct Person {
  let name: String
  var parents: [Person]
}
var john = Person(name: "John", parents: [])
john.parents = [john]
john // John, parents:[John,parents:[]]
```

#### unowned VS weak

非强引用对象拥有和强引用对象同样或者更⻓的生命周期的话， unowned 引用通常会更方便一些

### 第5章 编码和解码



### 第6章 函数

函数可以被赋值给变量
```swift
func printInt(i: Int) {
	print("you passed", i)
}

let funVar = printInt // 或者 let funVar = printInt(i:)
// 调用时不能包含参数标签
funVar(3)
```
函数可以捕获存在于它们作用范围之外的变量
```swift
func counterFunc() -> (Int) -> String { 
  var counter = 0
  func innerFunc(i: Int) -> String {
    counter += i // counter is captured
    return "running total: \(counter)" 
  }
  return innerFunc 
}
```

**counter 将存在于堆上而非栈上。**

一般来说，因为 counter 是一个 counterFunc 的局部变量，它在 return 语句执行之后应该离开作用域并被摧毁。但是因为 innerFunc 捕获了它，所以 Swift 运行时将为一直保证它存在，直到捕获它函数被销毁为止。

一个函数和它所捕获的变量环境组合起来被称为**闭包**。

{ } 来声明函数的被称为**闭包表达式**。

#### 函数灵活性

Function.swift

`lexicographicallyPrecedes` 方法接受两个序列，并对它们执行一个电话簿方式的比较。

#### inout参数和可变方法

inout 参数将一个值传递给函数，函数可以改变这个值，然后将原来的值替换掉，并从函数中传出。				
inout 参数不能逃逸

```swift
func escapeIncrement(value: inout Int) -> () -> () { 
  func inc() {
    value += 1 
  }
  // error: 嵌套函数不能捕获 inout 参数
  return inc 
}
```

因为 inout 的值要在函数返回之前复制回去，那么要是我们可以在函数返回之后再去改变它，应该要怎么做呢？是说值应该在改变以后再复制吗？要是调用源已经不存在了怎么办？编译器必须对此进行验证，因为这对保证安全十分关键。

& 除了在将变量传递给 inout 以外， 还可以用来将变量转换为一个不安全的指针。

```swift
func incref(pointer: UnsafeMutablePointer<Int>) -> () -> Int {
  return {
    pointer.pointee += 1
    return pointer.pointee 
  }
}

var value = 5
let fun = incref(pointer: &value)
fun()
```

#### 观察属性

属性观察者不是一个提供给类型用戶的工具，它是专⻔为类型的设计者而设计的；这和 Foundation 中的键值观察有本质的不同，键值观察通常是对象的消费者来观察对象内部变化的手段，而与类的设计者是否希望如此无关。

KVO 使用 Objective-C 的运行时特性， 它动态地在类的 setter 中添加观察者；Swift 的属性观察是一个纯粹的编译时特性。

#### 延时属性

延迟属性会被自动声明为 var，因为它的初始值 在初始化方法完成时是不会被设置的。

访问一个延迟属性是 mutating 操作，因为这个属性的初始值会在第一次访问时被设置。

当结构体包含一个延迟属性时，这个结构体的所有者如果想要访问该延迟属性的话，也需要将结构体声明为可变量，因为访问这个属性的同时，也会潜在地对这个属性的容器进行改变。

#### 下标

见Dictionary.swift subscript方法

#### 键路径

键路径表达式以一个反斜杠开头，比如 \String.count

##### 双向数据绑定

见BidirectionBind.swift

##### 类型

-   AnyKeyPath和(Any)->Any?类型的函数相似

-   PartialKeyPath<Source>和(Source)->Any?函数相似

-   KeyPath<Source,Target>和(Source)->Target函数相似

-   WritableKeyPath<Source,Target>和(Source)->Target与 (inout Source, Target) -> () 这一对函数相似

-   ReferenceWritableKeyPath<Source,Target>和(Source)->Target与(Source, Target) -> () 这一对函数相似。第二个函数可以用 Target 来更新 Source 的值， 且要求 Source 是一个引用类型。

对 WritableKeyPath 和 ReferenceWritableKeyPath 进行区分是必要的，前一个类型的 setter 要求它的参数是 inout 的，后一个要求 Source 是一个引用类型。

#### 闭包

一个被保存在某个地方等待稍后 (比如函数返回以后) 再调用的闭包就叫做**逃逸闭包**。

默认非逃逸的规则只对函数参数，以及那些直接参数位置 (immediate parameter position) 的函数类型有效。也就是说，如果一个存储属性的类型是函数的话，那么它将会是逃逸的。出乎意料的是，对于那些使用闭包作为参数的函数，如果闭包被封装到像是多元组或者可选值等类型的话，这个闭包参数也是逃逸的。因为在这种情况下闭包不是直接参数，它将**自动变为逃逸闭包**。这样的结果是，你不能写出一个函数，使它接受的函数参数同时满足可选值和非逃逸。很多情况下，你可以通过为闭包提供一个默认值来避免可选值。如果这 样做行不通的话，可以通过重载函数，提供一个包含可选值 (逃逸) 的函数，以及一个不可选， 不逃逸的函数来绕过这个限制。

```swift
func transform(_ input: Int, with f: ((Int) -> Int)?) -> Int {
  print("使用可选值重载")
  guard let f = f else { return input }
  return f(input) 
}

func transform(_ input: Int, with f: (Int) -> Int) -> Int { 
  print("使⽤⾮可选值重载")
  return f(input) 
}
```

#### withoutActuallyEscaping

你确实知道一个闭包不会逃逸，但是编译器无法证明这点，所以它会强制你添加 @escaping 标注。Swift 为这种情况提供了一个特例函数，那就是 `withoutActuallyEscaping`。它可以让你把一个非逃逸闭包传递给一个期待逃 逸闭包作为参数的函数。

```swift
extension Array {
  func all(matching predicate: (Element) -> Bool) -> Bool {
    return withoutActuallyEscaping(predicate) { escapablePredicate in 
      self.lazy.filter { !escapablePredicate($0) }.isEmpty
    } 
  }
}
```

注意，使用 `withoutActuallyEscaping` 后，你就进入了 Swift 中不安全的领域。让闭包的复制从`withoutActuallyEscaping` 调用的结果中逃逸的话，会造成不确定的行为。

### 第8章 字符

#### Unicode

**编码单元(code unit)** 组成 **Unicode标量(Unicode scalar)**；Unicode标量(Unicode scalar)组成**字符(Character)**。

Unicode中的**编码点(code point)**介于0~0x10FFFF的一个值。

Unicode标量(Unicode scalar)等价于Unicode编码点(code point)，除了0xD800–0xDFFF之间的“代理” (surrogate) 编码点。Unicode标量(Unicode scalar)在Swift中以"**\u{xxxx}**"来表示。Unicode 标量(Unicode scalar)在 Swift 中对应的类型是 **Unicode.Scalar**，它是一个对 UInt32 的封装类型。

Unicode编码点(code point)可以编码成许多不同宽度的编码单元(code unit)，最普通的是使用UTF-8或者UTF-16

用户在屏幕上看到的单个字符可能有多个编码点组成的，在Unicode中，这种从用户视角看到的字符，叫做**扩展字符族(extended grapheme cluster)**，在Swift中，字符族有Character类型来表示。

Swift内部使用了**UTF-16**作为非ASCII字符串的编码方式。

é(U+00E9)与é(U+0065)+(U+0301)在Swift是表示相同的字符，Unicode规范将此称作**标准等价**。

一些颜文字有不可见的**零宽度连接符(zero-width joiner, ZWJ)(U+200D)**所连接组合。比如

👨‍👩‍👧‍👦=👨+ZWJ+👩+ZWJ+👧+ZWJ+👦组成

```swift
// 查看String的Unicode标量组成
string.unicodeScalars.map {
  "U+\(String($0.value, radix: 16, uppercase: true))"
}
```

**StringTransform**: Constants representing an ICU string transform.

#### 字符串和结合

String是双向索引(BidirectionalCollection)而非随机访问(RandomAccessCollection)

String还满足(RangeReplaceableCollection)

#### 子字符串

和所有集合类型一样，String 有一个特定的 SubSequence 类型，它就是 Substring。 Substring 和 ArraySlice 很相似：它是一个以不同起始和结束索引的对原字符串的切片。子字符串和原字符串共享文本存储，这带来的巨大的好处，它让对字符串切片成为了非常高效的操作。

Substring 和 String 的接口几乎完全一样。这是通过一个叫做 **StringProtocol** 的通用协议来达到的，String 和 Substring 都遵守这个协议。因为几乎所有的字符串 API 都被定义在 StringProtocol 上，对于 Substring，你完全可以假装将它看作就是一个 String，并完成各项操作。

和所有的切片一样，子字符串也只能用于短期的存储，这可以避免在操作过程中发生昂贵的复制。当这个操作结束，你想将结果保存起来，或是传递给下一个子系统，你应该通过初始化方法从 Substring 创建一个新的String。

不鼓励⻓期存储子字符串的根本原因在于，子字符串会一直持有整个原始字符串。

不建议将API从接受String实例转换为StringProtocol

#### 编码单元视图

String提供3种视图：unicodeScalars, utf16和utf8

如果你需要一个以 null 结尾的表示的话，可以使用 String 的 **withCString** 方法或者 **utf8CString** 属性。后一种会返回一个字节的数组

#### 字符范围

Character并没有实现Strideable协议，因此不是可数的范围

#### CharacterSet

CharacterSet实际上应该被叫做UnicodeScalarSet，因为它确实就是一个表示一系列Unicode标量的数据结构体。

#### 字面量

字符串字面量隶属于 **ExpressibleByStringLiteral**、 **ExpressibleByExtendedGraphemeClusterLiteral** 和 **ExpressibleByUnicodeScalarLiteral** 这三个层次结构的协议，所以实现起来比数组字面量稍费劲一些。这三个协议都定义了支持各自字面量类型的 init 方法，你必须对这三个都进行实现。不过除非你真的需要区分是从一个 Unicode 标量还是从一个字位簇来创建实例这样细粒度的逻辑，否则只需要实现字符串版本就行了。

#### CustomStringConvertible和CustomDebugStringConvertible

| CustomStringConvertible | CustomDebugStringConvertible |
| ----------------------- | ---------------------------- |
| var description: String | var debugDescription: String |
| String(describing:)     | String(reflecting:)          |
| print函数                 | debugPrint函数                 |

#### 文本输出流

print(_:to:) 和 dump(_:to:)。to 参数就是输出的目标，它可以是任何实现了 **TextOutputStream** 协议的类型

```swift
protocol TextOutputStream {
  mutating func write(_ string: String)
}
```

输出流可以是实现了**TextOutputStreamable**协议的任意类型

```swift
protocol TextOutputStreamable {
  func write<Target>(to target: inout Target) where Target : TextOutputStream
}
```

### 第9章 错误处理

```swift
enum ParseError: Error {
  case wrongEncoding
  case warning(line: Int, message: String)
}

do{
  let result = try parse(text: "{ \"message\": \"We come in peace\" }") 
  print(result)
} catch ParseError.wrongEncoding { 
  print("Wrong encoding")
} catch let ParseError.warning(line, message) { 
  print("Warning at line \(line): \(message)")
} catch { 
  // 其他
}
```

-   CustomNSError => provides a domain, error code, and user-info dictionary
-   LocalizedError => provides localized messages describing the error and why it occurred
-   RecoverableError => presents several potential recovery options to the user

### 第10章 泛型

非通用方法优先通用方法

当使用操作符重载时，编译器会表现出一些奇怪的行为。即使泛型版本应该是更好的选择的时候，类型检查器也还是会去选择那些非泛型的重载，而不去选择泛型重载。

```swift
precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
func **(lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

func **(lhs: Float, rhs: Float) -> Float {
    return powf(lhs, rhs)
}

func **<I: BinaryInteger>(lhs: I, rhs: I) -> I {
    let result = Double(Int64(lhs)) ** Double(Int64(rhs))
    return I(result)
}

let intResult =2 ** 3 // 报错
let intResult: Int = 2 ** 3 // 8
```

编译器忽略了整数的泛型重载，因此它无法确定是去调用 Double 的重载还是 Float 的重载，因为两者对于整数字面量输入来说，具有相同的优先级 (Swift 编译器会将整数字面量在需要时自动向上转换为 Double 或者 Float)，所 以编译器报错说存在歧义。要让编译器选择正确的重载，我们需要至少将一个参数显式地声明为整数类型，或者明确提供返回值的类型。

这种编译器行为只对运算符生效。BinaryInteger 泛型重载的函数可以正确工作。

#### 使用泛型约束进行重载

##### 二分法

```swift
extension RandomAccessCollection where Index == Int, IndexDistance == Int { 
	public func binarySearch(for value: Element, areInIncreasingOrder: (Element, Element) -> Bool) -> Index? {
	var left = 0 // bug-1
	var right = count - 1 
	while left <= right {
		let mid = (left + right) / 2 // bug-2
		let candidate = self[mid]
		if areInIncreasingOrder(candidate,value) {
			left = mid + 1
		} else if areInIncreasingOrder(value,candidate) {
			right = mid - 1 }
		else {
			// 由于 isOrderedBefore 的要求，如果两个元素互⽆无顺序关系，那么它们⼀一定相等
			return mid 
		}
	}
	// 未找到
	return nil
  }
}
```

这里存在两个Bug，

1.  RandomAccessCollection，以整数为索引的集合其索引值其实并一定从0开始，比如arr[3.<5]，startIndex是3。
2.  在数组非常大的情况下，表达式(left+right)/2，可能会造成溢出

正确的方法见 Generic.swift

##### shuffle

```swift
extension BinaryInteger {
  static func arc4random_uniform(_ upper_bound: Self) -> Self {
    precondition(upper_bound > 0 && UInt32(upper_bound) < UInt32.max, "arc4random_uniform only callable up to \(UInt32.max)")
    return Self(Darwin.arc4random_uniform(UInt32(upper_bound))) 
  }
}

extension MutableCollection where Self: RandomAccessCollection { 
  mutating func shuffle() {
    var i = startIndex
    let beforeEndIndex = index(before: endIndex) 
    while i < beforeEndIndex { // 1
      let dist = distance(from: i, to: endIndex)
      let randomDistance = IndexDistance.arc4random_uniform(dist) 
      let j = index(i, offsetBy: randomDistance)
      self.swapAt(i, j)
      formIndex(after: &i)
    } 
  }
}

extension Sequence {
  func shuffled() -> [Element] { // 2
    var clone = Array(self) 
    clone.shuffle()
    return clone
  } 
}
```

注意点

1.  我们从 for 循 环切换为了 while 循环，这是因为如果使用 for i in indices.dropLast() 来迭代索引的话，可能 会有性能问题：如果 indices 属性持有了对集合的引用，那么在遍历 indices 的同时更改集合内容，将会让我们失去写时复制的优化，因为集合需要进行不必要的复制操作。

2.  非变更shuffled方法，没有扩展 MutableCollection。这其实也是一个标准库中经常能够⻅到的模式 — 比如，当你对一个 ContiguousArray 进行排序操作时，你得到的是一个 Array 返回，而不是 ContiguousArray。

    在这里，原因是我们的不可变版本是依赖于复制集合并对它进行原地操作这一系列步骤的。进一步说，它依赖的是集合的值语义。但是并不是所有集合类型都具有值语义。要是 NSMutableArray 也满 MutableCollection 的话，那么 shuffl􏰁ed 和 shuffl􏰁e 的效果将是一样的。这是因为如果 NSMutableArray 是引用，那么 var clone = self 仅只是复制了一份引用，这样一来，接下来的 clone.shuffl􏰁e 调用将会作用在 self 上，显然这可能并不是用戶所期望的行为。所以，我们可以将这个集合中的元素完全复制到一个数组里，对它进行随机排列， 然后返回。

可以稍微让步，你可以定义一个 shuffl􏰁e 版本，只要它操作的集合也支持 RangeReplaceableCollection，就让它返回和它所随机的内容同样类型的集合

```swift
extension MutableCollection where Self: RandomAccessCollection, Self: RangeReplaceableCollection
{
  func shuffled() -> Self {
    var clone = Self() 
    clone.append(contentsOf: self) 
    clone.shuffle()
    return clone
  } 
}
```

这个实现依赖了 RangeReplaceableCollection 的两个特性：1、可以创建一个新的空集合(init)，2、可以将任意序列 添加到空集合的后面(append)。

#### 使用泛型进行代码设计

```swift
struct Resource<A> { 
  let path: String
  let parse: (Any) -> A?
}

extension Resource {
  func loadSynchronously(callback: (A?) -> ()) {
    let resourceURL = webserviceURL.appendingPathComponent(path) 
    let data = try? Data(contentsOf: resourceURL)
    let json = data.flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: []) 
    }
    callback(json.flatMap(parse))
  }
  
  func loadAsynchronously(callback: @escaping (A?) -> ()) {
    let resourceURL = webserviceURL.appendingPathComponent(path) 
    let session = URLSession.shared
    session.dataTask(with: resourceURL) { data, response, error in
    let json = data.flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: [])
	}
	callback(json.flatMap(self.parse)) }.resume()
  }
}

let usersResource: Resource<[User]> = Resource(path: "/users", parse: jsonArray(User.init))
let postsResource: Resource<[BlogPost]> = Resource(path: "/posts", parse: jsonArray(BlogPost.init))
```

### 第11章 协议

协议允许我们进行动态派生，在运行时程序会根据消息接受者的类型去选择正确的方式实现。

普通的协议可以被当作类型约束使用，也可以当作独立的类型使用。带有关联类型或者Self约束的协议不能当作独立的类型使用。

在面向对象编程中，子类是在多个类之间共享代码的有效方式，Swift面向协议的编程，通过协议和协议扩展来实现代码共享。

协议要求的方式是动态派发的，而仅定义在扩展中的方式是静态派发的。

#### 类型抹消

##### 方法1

1.  创建一个名为 AnyProtocolName 的结构体或者类。
2.  对于每个关联类型，我们添加一个泛型参数。
3.  对于协议的每个方法，我们将其实现存储在 AnyProtocolName 中的一个属性中。
4.  我们添加一个将想要抹消的具体类型泛型化的初始化方法，它的任务是在闭包中捕获我们传入的对象，并将闭包赋值给上面步骤中的属性。

```swift
// 实现任意迭代器
class AnyIterator<A>: IteratorProtocol { 
  var nextImpl: () -> A?
  init<I: IteratorProtocol>(_ iterator: I) where I.Element == A { 
    var iteratorCopy = iterator
    self.nextImpl = { iteratorCopy.next() }
  }

  func next() -> A? { 
    return nextImpl()
  } 
}

let iter: AnyIterator<Int> = AnyIterator<Int>(ConstantIterator())
```

##### 方法2

使用类继承的方式，来把具体的迭代器类型隐藏在子类中，同事面向客户端的类仅仅只是对元素类型的泛型化类型。标准库也是采用这个策略。

```swift
// 实现任意迭代器
class IteratorBox<Element>: IteratorProtocol { 
  func next() -> Element? {
    fatalError("This method is abstract.") 
  }
}

class IteratorBoxHelper<I: IteratorProtocol>: IteratorBox<I.Element> { 
  var iterator: I
  init(_ iterator: I) {
    self.iterator = iterator 
  }
  
  override func next() -> I.Element? { 
    return iterator.next()
  }
}

let iter: IteratorBox<Int> = IteratorBoxHelper(ConstantIterator())
```

#### 带有Self的协议

== 运算符被定义为了类型的静态函数。换句话说，它不是成员函数，对该函数的调用将被静态派发。

#### 协议内幕

当我们通过协议类型创建一个变量的时候，这个变量会被包装到一个叫做**存在容器**的盒子中

```swift
func f<C: CustomStringConvertible>(_ x: C) -> Int { 
  return MemoryLayout.size(ofValue: x)
}

func g(_ x: CustomStringConvertible) -> Int {
  return MemoryLayout.size(ofValue: x) 
}
f(5) // 8 
g(5) // 40
```

因为 f 接受的是泛型参数，整数 5 会被直接传递给这个函数，而不需要经过任何包装。所以它的大小是 8 字节，也就是 64 位系统中 Int 的尺寸。

对于 g，整数会被封装到一个存在容器中。对于普通的协议 (也就是没有被约束为只能由 class 实现的协议)，会使用**不透明存在容器** (opaque existential container)。不透明存在容器中含有一个存储值的缓冲区 (大小为三个指针，也就是 24 字节)；一些元数据 (一个指针，8 字节)；以及若干个目击表 (0 个或者多个指针，每个 8 字节)。如果值无法放在缓冲区里，那么它将被存储到堆上，缓冲区里将变为存储引用，它将指向值在堆上的地址。元数据里包含关于类型的信息 (比如是否能够按条件进行类型转换等)。

目击表是让动态派发成为可能的关键。它为一个特定的类型将协议的实现进行编码：对于协议中的每个方法，表中会包含一个指向特定类型中的实现的入口。有时候这被称为 vtable。

如果方法不是协议定义的一部分 (或者说，它不是协议所要求实现的内容，而是扩展方法)，所以它也不在目击表中。因此，编译器除了静态地调用协议的默认实现以外，别无选择。

不透明存在容器的尺寸取决于目击表个数的多少，每个协议会对应一个目击表。举例来说， Any 是空协议的类型别名，所以它完全没有目击表

```swift
typealias Any = protocol<> 
MemoryLayout<Any>.size // 32
```

如果我们合并多个协议，每多加一个协议，就会多 8 字节的数据块。所以合并四个协议将增加 32 字节

```swift
protocol Prot { }
protocol Prot2 { }
protocol Prot3 { }
protocol Prot4 { }
typealias P = Prot & Prot2 & Prot3 & Prot4
MemoryLayout<P>.size // 64
```

对于只适用于类的协议 (也就是带有 SomeProtocol: class 或者 @objc 声明的协议)，会有一个叫做**类存在容器**的特殊存在容器，这个容器的尺寸只有两个字⻓ (以及每个额外的目击表增加一个字⻓)，一个用来存储元数据，另一个 (而不像普通存在容器中的三个) 用来存储指向这个类的一个引用

```swift
protocol ClassOnly: AnyObject {} 
MemoryLayout<ClassOnly>.size // 16
```

从 Objective-C 导入 Swift 的那些协议不需要额外的元数据。所以那些类型是 Objective-C 协议的变量不需要封装在存在容器中；它们在类型中只包含一个指向它们的类的指针

```swift
MemoryLayout<NSObjectProtocol>.size // 8 
```

### 第12章 互用性











