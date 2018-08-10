//
//  ViewController.swift
//  SQLiteCRUDInSwift
//
//  Created by PASHA on 10/08/18.
//  Copyright © 2018 Pasha. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    @IBOutlet weak var myTB: UITableView!
    var database:Connection!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var nameTF: UITextField!
    
    
    // ADD SQLITE.XCODEPROJ FROM THIRD PARTY SWIFTSQLITE AND IMPORT FRAMEWORKS OF IOS
     // STEP --2
    // Create a table with params
    let userTable = Table("user")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTB.isHidden = true
        
        // STEP --1
        
        // create fileurl with database
        
    do {
         let fileUrl =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("user").appendingPathExtension("sqlite3")
        let database = try Connection(fileUrl.path)
        self.database = database
    }

    catch  {
        print(error.localizedDescription)
    }
       
        createTable()// Do any additional setup after loading the view, typically from a nib.
    }

    
     // STEP --3
    func createTable() {
      
        let createTable = self.userTable.create { (table) in
            
            table.column(self.id, primaryKey:true)
            table.column(self.name)
            table.column(self.email, unique:true)
        }
        do {
             try self.database.run(createTable)
            print("created table")
           }
            catch  {
            print(error.localizedDescription)
            }
        
    }
    
    // STEP --4
    @IBAction func insertTap(_ sender: Any) {
        
        guard let name = self.nameTF.text , let email = self.emailTF.text  else {
            return
        }
            
        let  users = self.userTable.insert(self.name <- name , self.email <- email)
        
        do {
          try self.database.run(users)
             print("insert Data Successfully")
            fetchAll()
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
     // STEP --5
    @IBAction func updateTap(_ sender: Any) {
        
        guard let name = self.nameTF.text , let email = self.emailTF.text  else {
            return
        }
        
        let users = self.userTable.filter(self.id == Int(name)!)
        
        let user = users.update(self.email <- email)
        do {
            try self.database.run(user)
            fetchAll()
        } catch  {
            print(error.localizedDescription)
        }
        print(" Data updated ")
    }
    
     // STEP --6
    @IBAction func deleteTap(_ sender: Any) {
        
        guard let name = self.nameTF.text  else {
            return
        }
        
        let users = self.userTable.filter(self.id == Int(name)!)
        
        let user = users.delete()
        do {
            try self.database.run(user)
            fetchAll()
        } catch  {
            print(error.localizedDescription)
        }
        print(" Data Deleted ")
    }
    @IBAction func listTap(_ sender: Any) {
        
        fetchAll()
        
    }
    
     // STEP --7
    func fetchAll(){
        self.users.removeAll()
        do {
            let users =  try self.database.prepare(self.userTable)
            
            for user in users {
                
                print("user id : \(user[self.id]) name :\(user[self.name]) email : \(user[self.email])")
                self.users.append(User(name: user[self.name], email: user[self.email]))
            }
            DispatchQueue.main.async {
                self.myTB.isHidden = false
                self.myTB.reloadData()
            }
            
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = users[indexPath.row].name
        cell?.detailTextLabel?.text = users[indexPath.row].email
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

