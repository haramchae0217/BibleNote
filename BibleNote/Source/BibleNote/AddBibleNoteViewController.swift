//
//  AddBibleNoteViewController.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit
import RealmSwift

class AddBibleNoteViewController: UIViewController {
    
    enum noteViewType {
        case add
        case edit
    }
    
    // //StoryboardID : AddBibleNoteVC
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bibleVerseTextField: UITextField!
    @IBOutlet weak var memoDatePicker: UIDatePicker!
    @IBOutlet weak var bibleMemoTextView: UITextView!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    let localRealm = try! Realm()
    
    var textCount: Int = 0
    var editNote: NoteDB?
    var viewType: noteViewType = .add
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationController()
        configureRightBarButton()
        configureTextView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.removeKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configureNavigationController() {
        if viewType == .edit {
            title = "말씀노트 수정"
        } else {
            title = "말씀노트 추가"
        }
    }
    
    func configureTextView() {
        bibleMemoTextView.delegate = self
        bibleMemoTextView.layer.cornerRadius = 10
        bibleMemoTextView.layer.borderWidth = 1
        bibleMemoTextView.layer.borderColor = UIColor.black.cgColor
    }
    
    func configureRightBarButton() {
        let rightBarButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(addMemoButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func addNote(note: NoteDB) {
        try! localRealm.write {
            localRealm.add(note)
        }
    }
    
    func editNote(oldNote: NoteDB, newNote: NoteDB) {
        try! localRealm.write {
            localRealm.create(
                NoteDB.self,
                value: [
                    "_id": oldNote._id,
                    "title": oldNote.title,
                    "mainVerse": oldNote.mainVerse,
                    "note": oldNote.note,
                    "date": oldNote.date
                ],
                update: .modified)
        }
    }

    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillShow(_ noti: NSNotification) {
        // 키보드의 높이를 초기화 시켜준다.
        self.view.frame.origin.y = 0
        // 키보드의 높이만큼 화면을 올려준다.
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y -= keyboardHeight
        }
    }
    
    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillHide(_ noti: NSNotification) {
        // 키보드의 높이만큼 화면을 내려준다.
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y += keyboardHeight
        }
    }
 
    @objc func addMemoButton() {
        let title = titleTextField.text!
        let bibleVerse = bibleVerseTextField.text!
        var date = memoDatePicker.date
        let memo = bibleMemoTextView.text!
    
        date = DateFormatter.customDateFormatter.strToDate(str: DateFormatter.customDateFormatter.dateToString(date: date))
        
        if textCount > 500 {
            UIAlertController.warningAlert(title: "🚫", message: "500자 이내로 작성해주세요.", viewController: self)
            return
        }
        
        if title.isEmpty || bibleVerse.isEmpty || memo.isEmpty {
            UIAlertController.warningAlert(title: "🚫", message: "빈칸을 입력해주세요.", viewController: self)
            return
        }
        
        let note = NoteDB(title: title, mainVerse: bibleVerse, note: memo, date: date)
        
        if viewType == .add {
            addNote(note: note)
        } else {
            if let oldNote = editNote {
                editNote(oldNote: oldNote, newNote: note)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddBibleNoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "내용을 입력하세요." {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 입력하세요."
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text!
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changeText = currentText.replacingCharacters(in: stringRange, with: text)
        
        wordCountLabel.text = "\(changeText.count)/500"
        if changeText.count > 500 {
            textView.textColor = .systemRed
            wordCountLabel.textColor = .systemRed
        } else {
            textView.textColor = .label
            wordCountLabel.textColor = .label
        }
        textCount = changeText.count
        return changeText.count <= 100000
    }
}
