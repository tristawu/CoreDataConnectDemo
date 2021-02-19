//
//  CoreDataConnect.swift
//  CoreDataConnectDemo
//
//  Created by Trista on 2021/2/17.
//

import Foundation
import CoreData


//選擇iOS > Source > Swift File這個模版的檔案，建立一個類別，Core Data功能獨立寫成一個類別，把實際操作 Core Data 的程式碼封裝起來，一般在使用時就不會使用到 Core Data 相關的類別或函式
class CoreDataConnect {
    //宣告用來操作 Core Data 的常數
    let myContext :NSManagedObjectContext!
    
    //使用typealias的特性設置一個型別別名，後續的資料操作，使用這個別名MyType即可，不用使用 Entity類別名稱Student
    typealias MyType = Student

    
    init(context:NSManagedObjectContext) {
        self.myContext = context
    }
    
    
    //insert
    func insert(_ myEntityName:String,
                attributeInfo:[String:String]) -> Bool {

        //使用NSEntityDescription類別的insertNewObject()方法新增資料
        //傳入兩個參數分別為Entity名稱及用來宣吿操作 Core Data 的常數
        //回傳一個 Entity類別的實體並指派給常數insetData
        let insetData = NSEntityDescription.insertNewObject(forEntityName: myEntityName, into: myContext) as! MyType

        //傳入的參數attributeInfo：要新增的 attribute 及其值是統一以字串傳入，這個方法內需要根據 attribute 的類型student.entity.attributesByName[key]?.attributeType來轉換型別為 Int, Double, Bool 或是原本的字串，再以方法 setValue(_,forKey:)設置值並儲存
        for (key,value) in attributeInfo {
            let t = insetData.entity.attributesByName[key]?.attributeType

            if t == .integer16AttributeType
            || t == .integer32AttributeType
            || t == .integer64AttributeType {
                insetData.setValue(Int(value),
                  forKey: key)
            }
            else if t == .doubleAttributeType
            || t == .floatAttributeType {
                insetData.setValue(Double(value),
                  forKey: key)
            }
            else if t == .booleanAttributeType {
                insetData.setValue(
                (value == "true" ? true : false),
                forKey: key)
            }
            else {
                insetData.setValue(value, forKey: key)
            }
        }

        /*使用do-catch語句來定義錯誤的捕獲(catch)及處理，每一個catch表示可以捕獲到一個錯誤拋出的處理方式
         do {
             try 拋出函式
             其他執行的程式
         } catch 錯誤1 {
             處理錯誤1
         } catch 錯誤2 {
             處理錯誤2
         }
        */
        do {
            //使用宣吿操作 Core Data 的常數的save()方法來儲存資料
            try myContext.save()

            return true
            
        } catch {
            fatalError("\(error)")
        }

    }//end insert
    
    
    //select
    //返回的是一個型別為Entity類別名稱[Student]的陣列
    func fetch(_ myEntityName:String, predicate:String?,
    sort:[[String:Bool]]?, limit:Int?) -> [MyType]?
    //func fetch(_ myEntityName:String,predicate:String?,sort:[[String:Bool]]?,limit:Int?) -> [NSManagedObject]?
    {
        
        //使用類別NSFetchRequest設置要取得的 Entity，建立一個取得資料的請求(request)
        let request = NSFetchRequest<NSFetchRequestResult>(
          entityName: myEntityName)
        
        //使用optional綁定(optional binding)來判斷可選型別的常數或變數是否有值,optional綁定設定存取的常數或變數名稱,可與可選型別常數或變數名稱相同
        if let myPredicate = predicate {
            
            //使用屬性predicate，設定取得資料的條件
            request.predicate =
              NSPredicate(format: myPredicate)
        }

        
        //使用optional綁定(optional binding)來判斷可選型別的常數或變數是否有值,optional綁定設定存取的常數或變數名稱,可與可選型別常數或變數名稱相同
        if let mySort = sort {
            var sortArr :[NSSortDescriptor] = []
            for sortCond in mySort {
                
                //兩個參數依序為要依照哪一個 attribute 排序以及是否由小排到大
                for (k, v) in sortCond {
                    sortArr.append(
                      NSSortDescriptor(
                        key: k, ascending: v))
                }
            }

            //使用屬性sortDescriptors額外設定取得資料排序的方式，是一個型別為[NSSortDescriptor]的陣列，可以填入多個排序方式
            request.sortDescriptors = sortArr
        }

        
        //使用optional綁定(optional binding)來判斷可選型別的常數或變數是否有值,optional綁定設定存取的常數或變數名稱,可與可選型別常數或變數名稱相同
        if let limitNumber = limit {
            
            //使用屬性fetchLimit設定限制查詢筆數
            request.fetchLimit = limitNumber
        }

        /*使用do-catch語句來定義錯誤的捕獲(catch)及處理，每一個catch表示可以捕獲到一個錯誤拋出的處理方式
         do {
             try 拋出函式
             其他執行的程式
         } catch 錯誤1 {
             處理錯誤1
         } catch 錯誤2 {
             處理錯誤2
         }
        */
        do {
            //使用宣吿操作 Core Data 的常數的fetch()方法來取得資料
            //傳入參數是使用類別NSFetchRequest設置要取得的 Entity，建立一個取得資料的請求(request)
            //順利取回的資料是一個型別為Entity類別名稱[Student]的陣列
            
            let results =
                try myContext.fetch(request)
              as! [MyType]

            return results
            
        } catch {
            fatalError("\(error)")
        }

    } //end select
    
    
    //update
    func update(_ myEntityName:String, predicate:String?,
    attributeInfo:[String:String]) -> Bool {
        
        //先以讀取資料方法，取得要更新的資料
        if let results = self.fetch(
            myEntityName,
          predicate: predicate, sort: nil, limit: nil) {
            
            //順利取回的資料是一個型別為Entity類別名稱[Student]的陣列
            for result in results {
                //順利取得資料後，將要更新的屬性設置完畢
                //傳入的參數attributeInfo：要更新的 attribute 及其值是統一以字串傳入，這個方法內需要根據 attribute 的類型 Entity類別名稱.entity.attributesByName[key]?.attributeType來轉換型別為 Int, Double, Bool 或是原本的字串，再以方法 setValue(_,forKey:)設置值並儲存
                for (key,value) in attributeInfo {
                    let t =
      result.entity.attributesByName[key]?.attributeType

                    if t == .integer16AttributeType
                    || t == .integer32AttributeType
                    || t == .integer64AttributeType {
                        result.setValue(
                          Int(value), forKey: key)
                    }
                    else if t == .doubleAttributeType
                    || t == .floatAttributeType {
                        result.setValue(
                          Double(value), forKey: key)
                    }
                    else if t == .booleanAttributeType {
                        result.setValue(
                        (value == "true" ? true : false),
                        forKey: key)
                    }
                    else {
                        result.setValue(
                          value, forKey: key)
                    }
                }
            }

            /*使用do-catch語句來定義錯誤的捕獲(catch)及處理，每一個catch表示可以捕獲到一個錯誤拋出的處理方式
                do {
                    try 拋出函式
                    其他執行的程式
                } catch 錯誤1 {
                    處理錯誤1
                } catch 錯誤2 {
                    處理錯誤2
                }
            */
            do {
                //使用宣吿操作 Core Data 的常數的save()方法來儲存更新的資料
                try self.myContext.save()

                return true
            } catch {
                fatalError("\(error)")
            }
            
        }

        return false
        
    }//end update

    
    //delete
    func delete(_ myEntityName:String, predicate:String?)
    -> Bool {
        //先以讀取資料方法，取得要刪除的資料
        if let results = self.fetch(myEntityName,
        predicate: predicate, sort: nil, limit: nil) {
            
            //順利取回的資料是一個型別為Entity類別名稱[Student]的陣列
            for result in results {
                //使用宣吿操作 Core Data 的常數的delete()方法來刪除資料
                self.myContext.delete(result)
            }

            do {
                //使用宣吿操作 Core Data 的常數的save()方法來儲存刪除後的資料
                try self.myContext.save()

                return true
            } catch {
                fatalError("\(error)")
            }
        }

        return false
        
    }//end delete
    
    
}
