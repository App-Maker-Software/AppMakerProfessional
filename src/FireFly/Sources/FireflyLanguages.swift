//
//  FireflyLanguages.swift
//

import Foundation
import Firefly

func installExtraLanguages() {
    let luaLanguage: [String: Any] = [
        "display_name": "Lua",
        "identifier": [
            "regex": "(\\.[A-Za-z_]+\\w*)|((NS|UI)[A-Z][a-zA-Z]+)|((pcall|print|assert|collectgarbage|error|getfenv|getmetatable|ipairs|next|pairs|pcall|rawequal|rawget|rawset|select|setfenv|setmetatable|tonumber|tostring|type|unpack)(?=\\())|((ads|audio|composer|crypto|display|easing|facebook|gameNetwork|graphics|io|json|lfs|licensing|math|media|native|network|os|package|require|physics|socket|sqlite3|store|productList|event|storeTransaction|string|system|table|timer|transition|widget)(?=\\.))",
            "group": 0,
            "relevance": 1,
            "options": [],
            "multiline": false
        ],
        "mult_string": [
            "regex": "\"\"\"(.*?)\"\"\"",
            "group": 0,
            "relevance": 4,
            "options": [NSRegularExpression.Options.dotMatchesLineSeparators],
            "multiline": true
        ],
        "keyword": [
            "regex": "\\b(and|break|do|else|elseif|end|false|for|function|if|in|local|nil|not|or|repeat|return|then|true|until|while)\\b",
            "group": 0,
            "relevance": 1,
            "options": [],
            "multiline": false
        ],
        "numbers": [
            "regex": "(?<=(\\s|\\[|,|:))(\\d|\\.|_)+",
            "group": 0,
            "relevance": 0,
            "options": [],
            "multiline": false
        ],
        "string": [
            "regex": #"(?<!\\)".*?(?<!\\)""#,
            "group": 0,
            "relevance": 3,
            "options": [],
            "multiline": false
        ],
        "comment": [
            "regex": "(?<!:)--.*?(\n|$)", // The regex used for highlighting
            "group": 0, // The regex group that should be highlighted
            "relevance": 5, // The relevance over other tokens
            "options": [], // Regular expression options
            "multiline": false // If the token is multiline
        ],
        "multi_comment": [
            "regex": "--\\[\\[.*?--\\]\\]", // The regex used for highlighting
            "group": 0, // The regex group that should be highlighted
            "relevance": 5, // The relevance over other tokens
            "options": [NSRegularExpression.Options.dotMatchesLineSeparators],  // Regular expression options
            "multiline": true // If the token is multiline
        ],
    ]
    
    Firefly.fireflyLanguages["lua"] = luaLanguage
}
