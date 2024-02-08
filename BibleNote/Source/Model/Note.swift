//
//  Note.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit
import RealmSwift

class NoteDB: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var mainVerse: String
    @Persisted var note: String
    @Persisted var date: Date
    
    convenience init(title: String, mainVerse: String, note: String, date: Date) {
        self.init()
        self.title = title
        self.mainVerse = mainVerse
        self.note = note
        self.date = date
    }
}
