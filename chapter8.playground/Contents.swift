//: Playground - noun: a place where people can play

import UIKit


enum Encoding {
    case ASCII
    case NEXTSTEP
    case JapaneseEUC
    case UTF8
}

//let myEncoding = Encoding.ASCII + Encoding.UTF8 <- not accepted like in Objective C

extension Encoding {
    var nsStringEncoding: String.Encoding {
    
    switch self {
        case .ASCII:
            return String.Encoding.ascii
        case .NEXTSTEP:
            return String.Encoding.nextstep
        case .JapaneseEUC:
            return String.Encoding.japaneseEUC
        case .UTF8:
            return String.Encoding.utf8
        }
    }
}

extension `Encoding` {
    init ?(enc: String.Encoding) {
        switch enc {
            case String.Encoding.ascii: self = .ASCII
            case String.Encoding.nextstep: self = .NEXTSTEP
            case String.Encoding.japaneseEUC: self = .JapaneseEUC
            case String.Encoding.utf8: self = .UTF8
            default: return nil
        }
    }
}

func localizedEncodingName(encoding: Encoding) -> String {
    return .localizedName(of: encoding.nsStringEncoding)
}

enum LookUpError: Error {
    case CapitalNotFound
    case PopulationNotFound
}

enum PopulationResult {
    case Success(Int)
    case Error(LookUpError)
}


enum Result<T> {
    case Success(T)
    case Error(Error)
}
let exampleSuccess: Result = .Success(1000)
let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam", "Belgium": "Brussels"
]
let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]

func populationOfCapital(country: String) -> Result<Int> {
    guard let capital = capitals[country] else {
        return .Error(LookUpError.CapitalNotFound)
    }
    guard let population = cities[capital] else {
        return .Error(LookUpError.PopulationNotFound)
    }
    return .Success(population)
}

populationOfCapital(country: "Germany")
switch populationOfCapital(country: "France") {
    case let .Success(population):
        print("France's capital has \(population) thousand inhabitants")
    case let .Error(error):
        print("Error: \(error)")
}

let presidents = [
    "Paris": "Hidalgo",
    "Madrid": "Carmena",
    "Amsterdam": "van der Laan",
    "Berlin": "Müller"
    ]


func mayorOfCapital(country: String ) -> String? {
    return capitals[country].flatMap{ presidents[$0]}
}



//Using Swift's library
func populationOfCapital1(country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookUpError.CapitalNotFound
    }
    
    guard let population = cities[capital] else {
        throw LookUpError.PopulationNotFound
    }
    return population
}

do {
    let population = try populationOfCapital1(country: "France")
    print("France's population is \(population)")
}
catch {
    print("Lookup error: \(error)")
}



func ??<T>(result: Result<T>, handleError: (Error)-> T) -> T {
    switch result {
        case let .Success(value):
            return value
        case let .Error(error):
            return handleError(error)
    }
}
func errorHandler() -> ((Error)-> Int) {
    return {
         err in
            switch err as! LookUpError {
                case .CapitalNotFound:
                    return -1
                default:
                    return -2
            }
        }
}



let result = populationOfCapital(country: "Mexico") ?? {
    error in
    switch error as! LookUpError {
        case let .CapitalNotFound(error):
            print("Capital Not Found")
            return -1
        default:
            print("Population not Found")
            return -1
    }
}
let handler = errorHandler()
let result2 = populationOfCapital(country: "Mexico") ?? errorHandler()
