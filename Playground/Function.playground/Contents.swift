import UIKit
import Utils
import Foundation

@objcMembers
public final class Person: NSObject {
    public let first: String
    public let last: String
    public let yearOfBirth: Int
    public init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
    }
}

let people = [
    Person(first: "Emily", last: "Young", yearOfBirth: 2002),
    Person(first: "David", last: "Gray", yearOfBirth: 1991),
    Person(first: "Robert", last: "Barnes", yearOfBirth: 1985),
    Person(first: "Ava", last: "Barnes", yearOfBirth: 2000),
    Person(first: "Joanne", last: "Miller", yearOfBirth: 1994),
    Person(first: "Ava", last: "Barnes", yearOfBirth: 1998),
]

// Objective-C
let lastDescriptor = NSSortDescriptor(key: #keyPath(Person.last),
                                      ascending: true,
                                      selector: #selector(NSString.localizedStandardCompare(_:)))

let firstDescriptor = NSSortDescriptor(key: #keyPath(Person.first),
                                       ascending: true,
                                       selector: #selector(NSString.localizedStandardCompare(_:)))

let yearDescriptor = NSSortDescriptor(key: #keyPath(Person.yearOfBirth),
                                      ascending: true)

let descriptors = [lastDescriptor, firstDescriptor, yearDescriptor]
let sortedPeople1 = (people as NSArray).sortedArray(using: descriptors)


// Swift
let last: SortDescriptor<Person> = sortDescriptor(key: { $0.last }) {
    $0.localizedStandardCompare($1) == .orderedAscending
}
let first: SortDescriptor<Person> = sortDescriptor(key: { $0.first }) {
    $0.localizedStandardCompare($1) == .orderedAscending
}
let year: SortDescriptor<Person> = sortDescriptor(key: { $0.yearOfBirth })

let sortedPeople2 = people.sorted(by: last <||> first <||> year)

let last2: SortDescriptor<Person> = sortDescriptor(keyPath: \Person.last) {
    $0.localizedStandardCompare($1) == .orderedAscending
}
let first2: SortDescriptor<Person> = sortDescriptor(keyPath: \Person.first) {
    $0.localizedStandardCompare($1) == .orderedAscending
}
let year2: SortDescriptor<Person> = sortDescriptor(keyPath: \Person.yearOfBirth)

let sortedPeople3 = people.sorted(by: last <||> first <||> year)

final class Sample: NSObject {
    @objc dynamic var name: String = ""
}
class MyObj: NSObject {
    @objc dynamic var test: String = ""
}
let sample = Sample()
let other = MyObj()
let observation = sample.bind(\Sample.name, to: other, \.test)
sample.name = "NEW"
other.test // NEW
other.test = "HI"
sample.name // HI
