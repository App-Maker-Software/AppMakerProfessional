//
//  LuaSwiftParsing.swift
//  AppMakerProfessional-iOS
//
//  Created by Joseph Hinkle on 6/6/22.
//

#if MAIN_APP
import LuaSwiftBindings


internal extension Table {
    func get<T>(key: String) -> T? {
        self[key] as? T
    }
    func get(key: String) -> Int? {
        if let int = (self[key] as? Number)?.toInteger() {
            return Int(int)
        }
        return nil
    }
}

protocol ConvertibleToLuaCodeString {
    var asLuaCodeString: String { get }
}

extension Optional: ConvertibleToLuaCodeString where Wrapped: ConvertibleToLuaCodeString {
    var asLuaCodeString: String {
        if let self = self {
            return self.asLuaCodeString
        }
        return "nil"
    }
}

extension Int: ConvertibleToLuaCodeString {
    var asLuaCodeString: String {
        return "\(self)"
    }
}

extension String: ConvertibleToLuaCodeString {
    var asLuaCodeString: String {
        return "\"\(self)\""
    }
}





#endif
