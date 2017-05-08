//
//  TodoController.swift
//  TodoList
//
//  Created by Tim Nugent on 21/4/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

class AllRemoteOriginMiddleware: RouterMiddleware
{
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Swift.Void) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        next()
    }
}
class TodoContoller
{
    let router = Router()
    
    var todos = TodoList()
    
    init()
    {
        let idPath = "api/todos/:id"
        
        router.all("/*", middleware: AllRemoteOriginMiddleware())
        router.all("/*", middleware: BodyParser())
        router.options("/*"){ request, response, next in
            response.headers["Access-Control-Allow-Headers"] = "accept, content-type"
            response.headers["Access-Control-Allow-Methods"] = "GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH"
            response.status(.OK)
            next()
        }
        
        // getting todos
        router.get("/", handler: getAll)
        router.get(idPath, handler: getIndividual)
        // creating todos
        router.post("/", handler: createTodo)
        // updating todos
        router.post(idPath, handler: updateByID)
        router.patch(idPath, handler: updateByID)
        // deleting todos
        router.delete(idPath, handler: deleteByID)
        router.delete("/", handler: deleteAll)
    }
    
    private func getAll(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        self.todos.getAll() { todos in
            do
            {
                let json = JSON(todos.jsonDictionary)
                try response.status(.OK).send(json: json).end()
            }
            catch
            {
                Log.error("Communication error")
            }
        }
    }
    private func getIndividual(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        guard let todoID = request.parameters["id"] else
        {
            response.status(.badRequest)
            Log.error("requested todo item does not have an id")
            return
        }
        self.todos.getTodo(with: todoID) { item in
            do
            {
                if let item = item
                {
                    let json = JSON(item.jsonDictionary)
                    try response.status(.OK).send(json: json).end()
                }
                else
                {
                    Log.warning("unable to find item with docID \(todoID)")
                    response.status(.badRequest)
                }
            }
            catch
            {
                Log.error("Comms error")
            }
        }
    }
    private func createTodo(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        guard let body = request.body else
        {
            Log.error("No body found in request")
            response.status(.badRequest)
            return
        }
        guard case let .json(json) = body else
        {
            Log.error("Invalid JSON in request")
            response.status(.badRequest)
            return
        }
        guard   let title = json["title"].string else
        {
            Log.error("missing necessary info to make a todo")
            response.status(.badRequest)
            return
        }
        let order = json["order"].int
        let completed = json["completed"].bool
        
        let todo = self.todos.add(with: title, order: order, completed: completed)
        
        let result = JSON(todo.jsonDictionary)
        do
        {
            try response.status(.OK).send(json: result).end()
        }
        catch
        {
            Log.error("Error sending response")
        }
    }
    private func updateByID(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        guard let todoID = request.parameters["id"] else
        {
            Log.error("no todo parameter found in request")
            response.status(.badRequest)
            return
        }
        guard let body = request.body else
        {
            Log.error("No body found in request")
            response.status(.badRequest)
            return
        }
        guard case let .json(json) = body else
        {
            Log.error("Invalid json in request")
            response.status(.badRequest)
            return
        }
        let title = json["title"].string
        let order = json["order"].intValue
        let completed = json["completed"].boolValue
        
        self.todos.updateTodo(with: todoID, title: title, order: order, completed: completed) { item in
            guard let item = item else
            {
                Log.error("error updating todo")
                response.status(.badRequest)
                return
            }
            do
            {
                let jsonResponse = JSON(item.jsonDictionary)
                try response.status(.OK).send(json: jsonResponse).end()
            }
            catch
            {
                Log.error("communication error")
            }
        }
    }
    private func deleteByID(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        guard let todoID = request.parameters["id"] else
        {
            Log.error("no todo parameter in request")
            response.status(.badRequest)
            return
        }
        self.todos.deleteTodo(with: todoID) { (todo) in
            do
            {
                guard todo != nil else
                {
                    Log.error("failed to delete todo: \(todoID)")
                    try response.status(.badRequest).end()
                    return
                }
                try response.status(.OK).end()
            }
            catch
            {
                Log.error("Communication error")
            }
        }
    }
    private func deleteAll(request: RouterRequest, response: RouterResponse, next: () -> Void)
    {
        self.todos.deleteAll()
        do
        {
            try response.status(.OK).end()
        }
        catch
        {
            Log.error("Communication error")
        }
    }
}
