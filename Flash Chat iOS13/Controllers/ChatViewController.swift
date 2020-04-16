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
        self.tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        //메시지창을 만드는 방법을 꼭 복습하자!!(쌈이랑 고기로 생각해보기!)
        loadMessage()
    }
    
    func loadMessage(){
        message = []
        db.collection(K.FStore.collectionName).getDocuments { (querySnapshot, error) in
            if let e = error{
                print("There are some problem retrieving from Firestore. \(e)")
            } else {
                querySnapshot
            }
            <#code#>
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField : messageSender,
                K.FStore.bodyField : messageBody
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data in FireStore \(e)")
                } else{
                    print("Successfully saved data")
                }
            }
        }
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
                    if self.ref!.documentID == document.documentID{
                        var sender = "tls1gy2rms3@naver.com"
                        var contents = document.data()["body"]!
                        var madedMessage = Message(sender: sender, body: contents as! String)
                        self.message.append(madedMessage)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        messageTextfield.text = ""
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

