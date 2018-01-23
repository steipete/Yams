//
//  ConstructorTests.swift
//  Yams
//
//  Created by Norio Nomura on 12/23/16.
//  Copyright (c) 2016 Yams. All rights reserved.
//

import Foundation
import XCTest
import Yams

class ConstructorTests: XCTestCase { // swiftlint:disable:this type_body_length
    // Samples come from PyYAML.

    func testBinary() throws {
        let example = """
            canonical: !!binary \"\\
             R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5\\
             OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+\\
             +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC\\
             AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=\"
            generic: !!binary |
             R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5
             OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+
             +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC
             AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
            description:
             The binary value above is a tiny arrow encoded as a gif image.

            """
        let objects = try Yams.load(yaml: example)
        let data = Data(base64Encoded: """
             R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5\
             OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/+\
             +f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLC\
             AgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
            """, options: .ignoreUnknownCharacters)!
        let expected: [String: Any] = [
            "canonical": data,
            "generic": data,
            "description": "The binary value above is a tiny arrow encoded as a gif image."
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(Data.construct(from: [Node("1"), Node("2")]))
    }

    func testBool() throws {
        let example = """
            canonical: yes
            answer: NO
            logical: True
            option: on
            but:
                y: is a string
                n: is a string

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "canonical": true,
            "answer": false,
            "logical": true,
            "option": true,
            "but": [
                "y": "is a string",
                "n": "is a string"
            ]
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(Bool.construct(from: [Node("1"), Node("2")]))
    }

    func testFloat() throws {
        let example = """
            canonical: 6.8523015e+5
            exponential: 685.230_15e+03
            fixed: 685_230.15
            sexagesimal: 190:20:30.15
            negative infinity: -.inf
            not a number: .NaN

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "canonical": 685230.15,
            "exponential": 685230.15,
            "fixed": 685230.15,
            "sexagesimal": 685230.15,
            "negative infinity": -Double.infinity,
            "not a number": Double.nan
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(Float.construct(from: [Node("1"), Node("2")]))
    }

    func testInt() throws {
        let example = """
            canonical: 685230
            decimal: +685_230
            octal: 02472256
            hexadecimal: 0x_0A_74_AE
            binary: 0b1010_0111_0100_1010_1110
            sexagesimal: 190:20:30
            negativeCanonical: -685230
            negativeDecimal: -685_230
            negativeOctal: -02472256
            negativeHexadecimal: -0x_0A_74_AE
            negativeBinary: -0b1010_0111_0100_1010_1110
            negativeSexagesimal: -190:20:30
            canonicalMin: -9223372036854775808
            canonicalMax: 9223372036854775807

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "canonical": 685230,
            "decimal": 685230,
            "octal": 685230,
            "hexadecimal": 685230,
            "binary": 685230,
            "sexagesimal": 685230,
            "negativeCanonical": -685230,
            "negativeDecimal": -685230,
            "negativeOctal": -685230,
            "negativeHexadecimal": -685230,
            "negativeBinary": -685230,
            "negativeSexagesimal": -685230,
            "canonicalMin": -9223372036854775808,
            "canonicalMax": 9223372036854775807
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(Int.construct(from: [Node("1"), Node("2")]))
    }

    func testMap() throws {
        let example = """
            # Unordered set of key: value pairs.
            Block style: !!map
              Clark : Evans
              Brian : Ingerson
              Oren  : Ben-Kiki
            Flow style: !!map { Clark: Evans, Brian: Ingerson, Oren: Ben-Kiki }

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "Block style": [
                "Clark": "Evans",
                "Brian": "Ingerson",
                "Oren": "Ben-Kiki"
            ],
            "Flow style": ["Clark": "Evans", "Brian": "Ingerson", "Oren": "Ben-Kiki"]
        ]
        YamsAssertEqual(objects, expected)
    }

    func testMerge() throws { // swiftlint:disable:this function_body_length
        let example = """
            ---
            - &CENTER { x: 1, 'y': 2 }
            - &LEFT { x: 0, 'y': 2 }
            - &BIG { r: 10 }
            - &SMALL { r: 1 }

            # All the following maps are equal:

            - # Explicit keys
              x: 1
              'y': 2
              r: 10
              label: center/big

            - # Merge one map
              << : *CENTER
              r: 10
              label: center/big

            - # Merge multiple maps
              << : [ *CENTER, *BIG ]
              label: center/big

            - # Override
              << : [ *BIG, *LEFT, *SMALL ]
              x: 1
              label: center/big

            """
        let objects = try Yams.load(yaml: example)
        let expected: [[String: Any]] = [
            [ "x": 1, "y": 2 ],
            [ "x": 0, "y": 2 ],
            [ "r": 10 ],
            [ "r": 1 ],
            [ "x": 1, "y": 2, "r": 10, "label": "center/big" ],
            [ "x": 1, "y": 2, "r": 10, "label": "center/big" ],
            [ "x": 1, "y": 2, "r": 10, "label": "center/big" ],
            [ "x": 1, "y": 2, "r": 10, "label": "center/big" ]
        ]
        YamsAssertEqual(objects, expected)
    }

    func testNull() throws {
        let example = """
            # A document may be null.
            ---
            ---
            # This mapping has four keys,
            # one has a value.
            empty:
            canonical: ~
            english: null
            ~: null key
            ---
            # This sequence has five
            # entries, two have values.
            sparse:
              - ~
              - 2nd entry
              -
              - 4th entry
              - Null

            """
        let objects = Array(try Yams.load_all(yaml: example))
        let expected: [Any] = [
            NSNull(),
            [
                "empty": NSNull(),
                "canonical": NSNull(),
                "english": NSNull(),
                "~": "null key" // null key is not supported yet.
            ], [
                "sparse": [
                    NSNull(),
                    "2nd entry",
                    NSNull(),
                    "4th entry",
                    NSNull()
                ]
            ]
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(NSNull.construct(from: [Node("1"), Node("2")]))
    }

    func testOmap() throws {
        let example = """
            # Explicitly typed ordered map (dictionary).
            Bestiary: !!omap
              - aardvark: African pig-like ant eater. Ugly.
              - anteater: South-American ant eater. Two species.
              - anaconda: South-American constrictor snake. Scaly.
              # Etc.
            # Flow style
            Numbers: !!omap [ one: 1, two: 2, three : 3 ]

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "Bestiary": [
                ("aardvark", "African pig-like ant eater. Ugly."),
                ("anteater", "South-American ant eater. Two species."),
                ("anaconda", "South-American constrictor snake. Scaly.")
            ] as [(Any, Any)],
            "Numbers": [("one", 1), ("two", 2), ("three", 3)] as [(Any, Any)]
        ]
        YamsAssertEqual(objects, expected)
    }

    func testPairs() throws {
        let example = """
            # Explicitly typed pairs.
            Block tasks: !!pairs
              - meeting: with team.
              - meeting: with boss.
              - break: lunch.
              - meeting: with client.
            Flow tasks: !!pairs [ meeting: with team, meeting: with boss ]

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "Block tasks": [
                ("meeting", "with team."),
                ("meeting", "with boss."),
                ("break", "lunch."),
                ("meeting", "with client.")
                ] as [(Any, Any)],
            "Flow tasks": [("meeting", "with team"), ("meeting", "with boss")] as [(Any, Any)]
        ]
        YamsAssertEqual(objects, expected)
    }

    func testSet() throws {
        let example = """
            # Explicitly typed set.
            baseball players: !!set
              ? Mark McGwire
              ? Sammy Sosa
              ? Ken Griffey
            # Flow style
            baseball teams: !!set { Boston Red Sox, Detroit Tigers, New York Yankees }

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "baseball players": ["Mark McGwire", "Sammy Sosa", "Ken Griffey"] as Set<AnyHashable>,
            "baseball teams": ["Boston Red Sox", "Detroit Tigers", "New York Yankees"] as Set<AnyHashable>
        ]
        YamsAssertEqual(objects, expected)
    }

    func testSeq() throws {
        let example = """
            # Ordered sequence of nodes
            Block style: !!seq
            - Mercury   # Rotates - no light/dark sides.
            - Venus     # Deadliest. Aptly named.
            - Earth     # Mostly dirt.
            - Mars      # Seems empty.
            - Jupiter   # The king.
            - Saturn    # Pretty.
            - Uranus    # Where the sun hardly shines.
            - Neptune   # Boring. No rings.
            - Pluto     # You call this a planet?
            Flow style: !!seq [ Mercury, Venus, Earth, Mars,      # Rocks
                                Jupiter, Saturn, Uranus, Neptune, # Gas
                                Pluto ]                           # Overrated

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "Block style": [
                "Mercury",
                "Venus",
                "Earth",
                "Mars",
                "Jupiter",
                "Saturn",
                "Uranus",
                "Neptune",
                "Pluto"
            ],
            "Flow style": [ "Mercury", "Venus", "Earth", "Mars",
                            "Jupiter", "Saturn", "Uranus", "Neptune",
                            "Pluto" ]
        ]
        YamsAssertEqual(objects, expected)
    }

    func testTimestamp() throws {
        let example = """
            canonical:        2001-12-15T02:59:43.1Z
            valid iso8601:    2001-12-14t21:59:43.10-05:00
            space separated:  2001-12-14 21:59:43.10 -5
            no time zone (Z): 2001-12-15 2:59:43.10
            date (00:00:00Z): 2002-12-14

            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "canonical": timestamp( 0, 2001, 12, 15, 02, 59, 43, 0.1),
            "valid iso8601": timestamp(-5, 2001, 12, 14, 21, 59, 43, 0.1),
            "space separated": timestamp(-5, 2001, 12, 14, 21, 59, 43, 0.1),
            "no time zone (Z)": timestamp( 0, 2001, 12, 15, 02, 59, 43, 0.1),
            "date (00:00:00Z)": timestamp( 0, 2002, 12, 14)
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(Date.construct(from: [Node("1"), Node("2")]))
    }

    func testTimestampWithNanosecond() throws {
        #if os(Linux)
            // FIXME: swift-corelibs-foundation can't format date with nanosecond.
            // https://bugs.swift.org/browse/SR-3158
        #else
            let example = "nanosecond: 2001-12-15T02:59:43.123456789Z\n"
            let objects = try Yams.load(yaml: example)
            let expected: [String: Any] = [
                "nanosecond": timestamp( 0, 2001, 12, 15, 02, 59, 43, 0.123456789)
            ]
            YamsAssertEqual(objects, expected)
        #endif
    }

    func testValue() throws {
        let example = """
            ---     # Old schema
            link with:
              - library1.dll
              - library2.dll
            ---     # New schema
            link with:
              - = : library1.dll
                version: 1.2
              - = : library2.dll
                version: 2.3

            """
        let objects = Array(try Yams.load_all(yaml: example))
        let expected: [Any] = [
            [
                "link with": [ "library1.dll", "library2.dll" ]
            ], [
                "link with": [
                    [ "=": "library1.dll", "version": 1.2 ],
                    [ "=": "library2.dll", "version": 2.3 ]
                ]
            ]
        ]

        YamsAssertEqual(objects, expected)
    }

    func testString() throws {
        let example = """
            one: two
            three: four
            """
        let objects = try Yams.load(yaml: example)
        let expected: [String: Any] = [
            "one": "two",
            "three": "four"
        ]
        YamsAssertEqual(objects, expected)

        XCTAssertNil(String.construct(from: [Node("1"), Node("2")]))
    }

    func testDecimal() throws {
        XCTAssertEqual(Decimal.construct(from: Node("1.2")), Decimal(string: "1.2")!)
        XCTAssertNil(Decimal.construct(from: [Node("1"), Node("2")]))
    }

    func testURL() throws {
        XCTAssertEqual(URL.construct(from: Node("http://www.google.com")), URL(string: "http://www.google.com")!)
        XCTAssertEqual(URL.construct(from: Node("~/file.txt")), URL(string: "~/file.txt")!)
        XCTAssertNil(URL.construct(from: [Node("1"), Node("2")]))
    }
}

extension ConstructorTests {
    static var allTests: [(String, (ConstructorTests) -> () throws -> Void)] {
        return [
            ("testBinary", testBinary),
            ("testBool", testBool),
            ("testFloat", testFloat),
            ("testInt", testInt),
            ("testMap", testMap),
            ("testMerge", testMerge),
            ("testNull", testNull),
            ("testOmap", testOmap),
            ("testPairs", testPairs),
            ("testSet", testSet),
            ("testSeq", testSeq),
            ("testTimestamp", testTimestamp),
            ("testTimestampWithNanosecond", testTimestampWithNanosecond),
            ("testValue", testValue),
            ("testString", testString),
            ("testDecimal", testDecimal),
            ("testURL", testURL)
        ]
    }
} // swiftlint:disable:this file_length
