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

