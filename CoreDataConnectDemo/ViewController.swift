//
//  ViewController.swift
//  CoreDataConnectDemo
//
//  Created by Trista on 2021/2/17.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //宣告用來操作 Core Data 的常數
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //宣告一個 Entity 的名稱,要與xcdatamodeld檔案新增的Entity名稱一樣，以供後續使用
    let myEntityName = "Student"
    
    //取得儲存的預設資料
    let myUserDefaults = UserDefaults.standard
    
    var seq = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //使用CoreDataConnect類別來操作資料庫
        //實際操作 Core Data 函式的程式碼封裝起來，一般在使用時就不會使用到 Core Data 相關的類別或函式
        let coreDataConnect = CoreDataConnect(context: myContext)
        
        //如果已經存有值時,則累加至seq,實作 auto increment:每次新增資料都自動為其中一個 attribute 遞增的功能
        //使用 NSUserDefaults 的方法object(forKey:) 來取得資訊，因為不只可以儲存單純文字，所以這邊會將它先轉為int再作後續使用
        if let idSeq = myUserDefaults.object(forKey: "idSeq")
          as? Int {
            seq = idSeq + 1
        }
        
        
        //insert
        //func insert(myEntityName:String,attributeInfo:[String:String]) -> Bool
         let insertResult = coreDataConnect.insert(
            myEntityName, attributeInfo: [
                "id" : "\(seq)",
                "name" : "小強\(seq)",
                "height" : "\(176.5 + Double(seq))"
            ])
        
        if insertResult {
            print("新增資料成功")

            //儲存資訊是使用 NSUserDefaults 的方法 set(_ value: Any?, forKey defaultName: String)
            //兩個參數分別為要儲存的資訊以及 key 值，像是字典的鍵值對 key : value
            //尚未有這個key值資訊時就會新增，已經有了的話，則是會更新它。
            myUserDefaults.set(seq, forKey: "idSeq")
            
            //設置好新的值後，有時系統不會即時更新儲存內容，讓資訊確實儲存就是使用 NSUserDefaults 的方法synchronize()
            myUserDefaults.synchronize()
        }
        
        
        //select
        //func fetch(myEntityName:String, predicate:String?,sort:[[String:Bool]]?, limit:Int?) -> [MyType]?
        let selectResult = coreDataConnect.fetch(
            myEntityName,
          predicate: nil, sort: [["id":true]], limit: nil)
        
        //使用optional綁定(optional binding)來判斷可選型別的常數或變數是否有值,optional綁定設定存取的常數或變數名稱,可與可選型別常數或變數名稱相同
        if let results = selectResult {
            //順利取回的資料是一個型別為Entity類別名稱[Student]的陣列
            for result in results {
                print("\(result.id). \(result.name!)")
                //print("\(result.value(forKey: "id")!). \(result.value(forKey: "name")!)")
                print("身高： \(result.height)")
                //print("身高： \(result.value(forKey: "height")!)")
            }
        }
        
        
        //update
        //func update(myEntityName:String, predicate:String?,attributeInfo:[String:String]) -> Bool
        let updateId = seq - 1
        var predicate = "id = \(updateId)"
        
        let updateResult = coreDataConnect.update(
            myEntityName,
          predicate: predicate,
          attributeInfo: ["height":"\(seq * 10)"])
        
        if updateResult {
            print("更新資料成功")
        }
        
        
        //delete
        //func delete(myEntityName:String, predicate:String?)-> Bool
        let deleteID = seq - 2      
        predicate = "id = \(deleteID)"
        
        let deleteResult = coreDataConnect.delete(
            myEntityName, predicate: predicate)
        
        if deleteResult {
            print("刪除資料成功")
        }
        
    }


}

