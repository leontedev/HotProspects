//
//  Prospect.swift
//  HotProspects
//
//  Created by Mihai Leonte on 16/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI

class Prospect: Identifiable, Codable, Comparable {
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        return lhs.name == rhs.name
    }
    
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var dateAdded: Date = Date()
    // to prevent changing the property from elsewhere (this is tied to the UI)
    // however it can be read from everywhere
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    static let saveKey = "SavedData"

    init() {
//        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//                self.people = decoded
//                return
//            }
//        }
//
//        self.people = []
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(Self.saveKey)
        if let data = try? Data(contentsOf: url) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        self.people = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            //UserDefaults.standard.set(encoded, forKey: Self.saveKey)
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(Self.saveKey)
            do {
                try encoded.write(to: url)
            } catch {
                print(print(error.localizedDescription))
            }
        }
    }
    
    
    func toggle(_ prospect: Prospect) {
        // force SwiftUI to update the views
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    
}
