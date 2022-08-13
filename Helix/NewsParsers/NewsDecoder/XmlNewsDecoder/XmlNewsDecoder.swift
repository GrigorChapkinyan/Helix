//
//  XmlNewsDecoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

class XmlNewsDecoder: XMLParser, XMLParserDelegate, INewsDecoder {
    // MARK: Private Properties
    
    private let iterObjectContainerElement = "item"
    private let objectsListContainerElement = "channel"
    private let imageElement = "image"
    private let urlElement = "url"
    private var iterObjectParsingIsInProcess = false
    private var imageElementParsingIsInProgess = false
    private var imageUrlElementParsingIsInProgess = false
    private var iterElementName: String?
    private var iterObjectDictionary: [AnyHashable:Any]!
    private var semaphore: DispatchSemaphore?
    private var finalObjectsListDictionaryArray = [[AnyHashable:Any]]()
    private var imageUrlEndpoint: String?
    
    // MARK: - Initializers
    
    override required init(data: Data) {
        super.init(data: data)
        delegate = self
    }
    
    // MARK: - INewsParser
    
    func decode() -> [News]? {
        // If current thread is the main thread,
        // we immediately return nil,
        // for avoiding the thread blocking
        guard Thread.isMainThread == false else {
            return nil
        }
        
        // Creating the semaphore with default value
        semaphore = DispatchSemaphore(value: 0)
        // Starting the parsing
        parse()
        // Waiting for the signal
        semaphore?.wait()
        semaphore = nil
        
        if let parserError = parserError {
            print("Xml parsing was stopped due to error: \(parserError)")
            return nil
        }
        
        let parsedObjects = getObjectsFromFinalResultDictArray()
        return parsedObjects
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("")
        // Checking if an iter object parsing has started
        if (elementName == iterObjectContainerElement) {
            iterObjectParsingIsInProcess = true
            iterObjectDictionary = [AnyHashable:Any]()
            return
        }
        
        // Checking if an image element parsing has started
        if (elementName == imageElement) {
            imageElementParsingIsInProgess = true
            return
        }
        
        // Checking if an image url element parsing has started
        if ((elementName == urlElement) && imageElementParsingIsInProgess) {
            imageUrlElementParsingIsInProgess = true
            return
        }
        
        // Checking if the current element name is object property key
        if (iterObjectParsingIsInProcess) {
            iterElementName = elementName
            return
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Checking if an iter object parsing has finished
        if (elementName == iterObjectContainerElement) {
            // Adding imageUrl value to dictionary
            iterObjectDictionary[imageElement] = imageUrlEndpoint
            // Adding current dictionary to list result dictionaries
            finalObjectsListDictionaryArray.append(iterObjectDictionary)
            // Setting to default values
            iterObjectParsingIsInProcess = false
            iterElementName = nil
            iterObjectDictionary = nil
            return
        }
        
        // Checking if an image element parsing has finished
        if (elementName == imageElement) {
            imageElementParsingIsInProgess = false
            return
        }
        
        // Checking if an image url element parsing has finished
        if ((elementName == urlElement) && imageElementParsingIsInProgess) {
            imageUrlElementParsingIsInProgess = false
            return
        }
        
        // This indicates that parsing was finished
        if (objectsListContainerElement == elementName) {
            semaphore?.signal()
            return
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // If the current string is new line,
        // we must return
        guard (string.trimmingCharacters(in: .whitespaces) != "\n") else {
            return
        }
        
        // Checking if an iter object parsing started
        if iterObjectParsingIsInProcess,
           let iterElementName = iterElementName {
            // Adding the value of current element
            iterObjectDictionary[iterElementName] = string
        }
        // Checking if image url element parsing has started
        else if imageElementParsingIsInProgess && imageUrlElementParsingIsInProgess {
            imageUrlEndpoint = string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        semaphore?.signal()
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        semaphore?.signal()
    }
    
    // MARK: - Private API
    
    private func getObjectsFromFinalResultDictArray() -> [News] {
        var retVal = [News]()
        
        for dictIter in finalObjectsListDictionaryArray {
            if let objectIter = News(dictionary: dictIter) {
                retVal.append(objectIter)
            }
        }
        
        return retVal
    }
}
