//
//  UserHistory.swift
//  wheather
//
//  Created by Pavel Playerz0redd on 1.10.24.
//

import Foundation

public enum SettingKeys: String {
    case previousCity
}


func store(_ city: String, key: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(city, forKey: key)
}

func getCity(forKey key: String) -> String? {
    let userDefaults = UserDefaults.standard
    return userDefaults.string(forKey: key)
}

struct UserHistory {

}

