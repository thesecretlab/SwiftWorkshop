//
//  TodoItem.swift
//  TodoList
//
//  Created by Tim Nugent on 21/4/17.
//
//

import Foundation
import CloudFoundryConfig
import Configuration

struct TodoItem
{
    // required autoincrements if not set on creation
    let todoID : String
    
    let order : Int?
    
    // only required element that HAS to be provided on creation
    let title : String
    
    let completed : Bool?
}

public enum TodoError: Error
{
    case connectionRefused
    case idNotFound
}

typealias JSONDictionary = [String : Any]
protocol JSONAble
{
    var jsonDictionary : JSONDictionary { get }
}

extension TodoItem : JSONAble
{
    var jsonDictionary : JSONDictionary
    {
        let manager = ConfigurationManager()
        manager.load(.environmentVariables)
        let url = manager.url + "/api/todos/" + self.todoID
        
        var dictionary = [String:Any]()
        dictionary["id"] = self.todoID
        dictionary["order"] = self.order
        dictionary["title"] = self.title
        dictionary["completed"] = self.completed
        dictionary["url"] = url
        
        return dictionary
    }
}
extension Array where Element : JSONAble
{
    var jsonDictionary : [JSONDictionary]
    {
        return self.map{ $0.jsonDictionary }
    }
}

class TodoList
{
    private var list = [TodoItem]()
    
    private var idCounter = 0
    
    func getAll(completion: ([TodoItem]) -> Void)
    {
        // ok so this can return an error if the database can't be reached
        completion(list)
    }
    func getTodo(with id: String?, completion : (TodoItem?) -> Void)
    {
        guard let todoID = id else
        {
            // this can throw an error here if the docID is invalid
            return
        }
        // this can throw an error in here if the query is invalid
        // this can throw an error if the database can't be reached
        let todos = self.list.filter { $0.todoID == todoID }
        completion(todos.first)
    }
    // ok so all todos are set up by default to not be completed unless otherwise said
    func add(with title: String, order: Int?, completed:Bool?) -> TodoItem
    {
        // realistically I should be checking if there is already a todo with that id...
        let todoID = String(self.idCounter)
        let todo = TodoItem(todoID: todoID, order: order, title: title, completed: completed ?? false)
        self.list.append(todo)
        self.idCounter += 1
        
        return todo
    }
    func updateTodo(with id : String, title: String?, order: Int?, completed: Bool?, completion: (TodoItem?) -> Void)
    {
        // let index = self.list.index { $0.documentID == documentID }
        // the above line of code doesn't work in a guard statement for whatever reason
        guard let index = self.list.index(where: { (item) -> Bool in item.todoID == id }) else
        {
            // this can throw if the id doesn't match any in the DB
            // this can throw if the DB can't be reached
            completion(nil)
            return
        }
        // this can throw if the database can't be talked to
        let todo = TodoItem(todoID: id, order: order, title: title ?? self.list[index].title, completed: completed)
        self.list[index] = todo
        completion(todo)
    }
    // deletes a specific todo with id and userID
    func deleteTodo(with id: String, completion: (TodoItem?) -> Void)
    {
        guard let index = self.list.index(where: { (item) -> Bool in item.todoID == id }) else
        {
            completion(nil)
            return
        }
        let todo = self.list[index]
        self.list.remove(at: index)
        completion(todo)
    }
    func deleteAll()
    {
        self.list = [TodoItem]()
    }
}
