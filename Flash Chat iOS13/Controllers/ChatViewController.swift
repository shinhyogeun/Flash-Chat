//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    var ref : DocumentReference? = nil
    
    var message : [Message] = [
        Message(sender: "tls1gy2rms@naver.com", body: "우리가 위대해지는 순간"),
        Message(sender: "tlsgyrms1231@naver.com", body: "그건 내가 결정한다."),
        Message(sender: "tls1gy2rms@naver.com", body: "모두 사랑한다.")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        //메시지창을 만드는 방법을 꼭 복습하자!!(쌈이랑 고기로 생각해보기!)
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        ref = db.collection("tls1gy2rms3@naver.com").addDocument(data: [
            "body" : messageTextfield.text ?? ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }

        db.collection("tls1gy2rms3@naver.com").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
//                    if document == querySnapshot!.documents[querySnapshot!.documents.count-1]{
                     print("\(document.documentID) => \(document.data())")
//                    }
                }
            }
        }
    }
    
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
        //메시지창을 만드는 방법을 꼭 복습하자!!(쌈이랑 고기로 생각해보기!)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as!MessageCell
        cell.label.text =  message[indexPath.row].body
        return cell
    }
    
}

