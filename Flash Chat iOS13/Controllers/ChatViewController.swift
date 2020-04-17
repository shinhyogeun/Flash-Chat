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
    var message : [Message] = []
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
        db.collection(K.FStore.collectionName).addSnapshotListener { (querySnapshot, error) in
            if self.message.count == 0 {
                if let e = error{
                    print("There are some problem retrieving from Firestore. \(e)")
                } else {
                    if let snapShotDocument = querySnapshot?.documents{
                        for doc in snapShotDocument {
                            let data = doc.data()
                            if let sender = data[K.FStore.senderField] as? String,
                                let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: sender, body: messageBody)
                                self.message.append(newMessage)
                                DispatchQueue.main.async {self.tableView.reloadData()}
                            }
                        }
                    }
                }
            }else{
                querySnapshot?.documentChanges.forEach({ (diff) in
                    if let sender = diff.document.data()[K.FStore.senderField] as? String,
                        let messageBody = diff.document.data()[K.FStore.bodyField] as? String{
                        let newMessage = Message(sender: sender, body: messageBody)
                        self.message.append(newMessage)
                        DispatchQueue.main.async {self.tableView.reloadData()}
                    }
                })
            }
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
        //MARK: - 내가 만든 부분
        //        ref = db.collection("tls1gy2rms3@naver.com").addDocument(data: [
        //            "body" : messageTextfield.text ?? ""
        //        ]) { err in
        //            if let err = err {
        //                print("Error adding document: \(err)")
        //            } else {
        //                print("Document added with ID: \(self.ref!.documentID)")
        //            }
        //        }
        //
        //        db.collection("tls1gy2rms3@naver.com").getDocuments() { (querySnapshot, err) in
        //            if let err = err {
        //                print("Error getting documents: \(err)")
        //            } else {
        //                for document in querySnapshot!.documents {
        //                    if self.ref!.documentID == document.documentID{
        //                        var sender = "tls1gy2rms3@naver.com"
        //                        var contents = document.data()["body"]!
        //                        var madedMessage = Message(sender: sender, body: contents as! String)
        //                        self.message.append(madedMessage)
        //                        self.tableView.reloadData()
        //                    }
        //                }
        //            }
        //        }
        //        messageTextfield.text = ""
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

