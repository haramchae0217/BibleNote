//
//  ViewController.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit
import FSCalendar

class BibleNoteViewController: UIViewController {
    
    var filteredList: [Note] = []

    //StoryboardID : BibleNoteVC
    @IBOutlet weak var bibleNoteCalendarView: FSCalendar!
    @IBOutlet weak var bibleNoteDateLabel: UILabel!
    @IBOutlet weak var bibleNoteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeData()
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
        filteredList = MyDB.noteList.filter { note in
            note.date == date
        }
    }
    
    func makeData() {
        let list: [Note] = [
            Note(title: "행복의 조건", mainVerse: "신명기 10:1-22", note: "하나님은 모세를 부르셔서 돌판에 십계명을 다시 새겨주시고, 모세는 백성에게 하나님이 진정 요구하시는 것이 무엇인지 가르칩니다.", date: strToDate(str: "2024/01/22")),
            Note(title: "하나님이 다스리시는 땅", mainVerse: "신명기 11:1-17", note: "이스라엘 백성은 과거에 경험한 하나님의 인도와 심판을 기억해야 합니다. 새 땅에서의 미래 역시 하나님에 대한 순종 여부에 따라 복과 저주로 결정됩니다.", date: strToDate(str: "2024/01/23")),
            Note(title: "복과 저주의 갈림길", mainVerse: "신명기 11:18-32", note: "가나안 땅에 들어가면, 이스라엘 백성은 복과 저주를 결정짓는 기준인 '하나님 말씀'을 가까이하고 순종할 뿐 아니라 자녀에게 가르쳐야 합니다.", date: strToDate(str: "2024/01/24"))
        
        ]
        
        list.forEach{ note in
            MyDB.noteList.append(note)
        }
    }
    
    func strToDate(str: String) -> Date {
        return DateFormatter.customDateFormatter.strToDate(str: str)
    }

}

extension BibleNoteViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for note in MyDB.noteList {
            let noteDate = note.date
            
            if noteDate == date {
                let count = MyDB.noteList.filter { note in
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
        
        filteredList = MyDB.noteList.filter { note in
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
        
        return cell
    }
}

extension BibleNoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
