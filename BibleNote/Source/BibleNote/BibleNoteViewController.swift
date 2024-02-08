//
//  ViewController.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit
import FSCalendar
import RealmSwift

class BibleNoteViewController: UIViewController {
    
    let localRealm = try! Realm()
    
    var noteList: [NoteDB] = []
    var filteredList: [NoteDB] = []

    //StoryboardID : BibleNoteVC
    
    @IBOutlet weak var bibleNoteCalendarView: FSCalendar!
    @IBOutlet weak var bibleNoteDateLabel: UILabel!
    @IBOutlet weak var bibleNoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todayData()
        
        configureNavigationController()
        configureTableView()
        configureCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func configureNavigationController() {
        title = "말씀노트"
    }
    
    func configureCalendarView() {
        bibleNoteCalendarView.delegate = self
        bibleNoteCalendarView.dataSource = self
        
        bibleNoteCalendarView.locale = Locale(identifier: "ko-KR")
        
        bibleNoteCalendarView.appearance.selectionColor = .systemMint
        bibleNoteCalendarView.appearance.todayColor = .systemGray
        bibleNoteCalendarView.appearance.headerTitleColor = .systemBrown
    }
    
    func configureTableView() {
        bibleNoteTableView.dataSource = self
        bibleNoteTableView.delegate = self
        
        bibleNoteTableView.reloadData()
    }
    
    func todayData() {
        let todayDate = DateFormatter.customDateFormatter.dateToString(date: Date())
        let date = DateFormatter.customDateFormatter.strToDate(str: todayDate)
        bibleNoteDateLabel.text = DateFormatter.customDateFormatter.dateToString(date: Date())
        filteredList = noteList.filter { note in
            note.date == date
        }
    }
    
    func getNote() -> [NoteDB] {
        noteList = []
        return localRealm.objects(NoteDB.self).map { $0 }.sorted(by: { $0.date < $1.date })
    }
    
    func deleteToDoDB(note: NoteDB) {
        try! localRealm.write {
            localRealm.delete(note)
        }
    }
    
    @IBAction func addNoteButton(_ sender: UIBarButtonItem) {
        guard let addVC = self.storyboard?.instantiateViewController(identifier: "AddBibleNoteVC") as? AddBibleNoteViewController else { return }
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
}

extension BibleNoteViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for note in noteList {
            let noteDate = note.date
            
            if noteDate == date {
                let count = noteList.filter { note in
                    note.date == date
                }.count
                
                if count >= 3 {
                     return 3
                } else {
                    return count
                }
            }
        }
        
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        bibleNoteDateLabel.text = DateFormatter.customDateFormatter.dateToString(date: date)
        
        filteredList = noteList.filter { note in
            note.date == date
        }
        bibleNoteTableView.reloadData()
        
        if filteredList.count == 0 {
            
        }
    }
}

extension BibleNoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = bibleNoteTableView.dequeueReusableCell(withIdentifier: BibleNoteTableViewCell.identifier, for: indexPath) as? BibleNoteTableViewCell else { return UITableViewCell() }
        let note = filteredList[indexPath.row]
        cell.BibleNoteTitleLabel.text = note.title
        cell.BibleNoteVerseLabel.text = note.mainVerse
        
        return cell
    }
}

extension BibleNoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let editNoteVC = self.storyboard?.instantiateViewController(withIdentifier: "AddBibleNoteVC") as? AddBibleNoteViewController else { return }
        
        let note: NoteDB = filteredList[indexPath.row]
        
        editNoteVC.viewType = .edit
        editNoteVC.editNote = note
        
        self.navigationController?.pushViewController(editNoteVC, animated: true)
    }
}
