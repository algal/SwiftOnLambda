//
//  AlexaMessages.swift
//  Listener
//
//  Created by Alexis Gallagher on 2016-10-10.
//  Copyright © 2016 Bloom Filter. All rights reserved.
//

import Foundation

/**
 
 
 
 At present, this is a mechanical translation of the
 types implicit in the Amazon docs for the JSON API, as
 described here:
 
 https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference
 
 This does not, for example, cleverly represent implicit
 variant types as enums with associated values, etc..
 
 The JSON parsing is an enormous pile of uninteresting boilerplate.
 
 Maybe explore generating it with protocol buffers or something?
 
 */


/*
 ALEXA REQUEST DOCS:
 
 HTTP Header
 
 POST / HTTP/1.1
 Content-Type : application/json;charset=UTF-8
 Host : your.application.endpoint
 Content-Length :
 Accept : application/json
 Accept-Charset : utf-8
 Signature:
 SignatureCertChainUrl: https://s3.amazonaws.com/echo.api/echo-api-cert.pem
 Request Body Syntax
 
 
 {
 "version": "string",
 "session": {
 "new": true,
 "sessionId": "string",
 "application": {
 "applicationId": "string"
 },
 "attributes": {
 "string": {}
 },
 "user": {
 "userId": "string",
 "accessToken": "string"
 }
 },
 "context": {
 "System": {
 "application": {
 "applicationId": "string"
 },
 "user": {
 "userId": "string",
 "accessToken": "string"
 },
 "device": {
 "supportedInterfaces": {
 "AudioPlayer": {}
 }
 }
 },
 "AudioPlayer": {
 "token": "string",
 "offsetInMilliseconds": 0,
 "playerActivity": "string"
 }
 },
 "request": {}
 }
 */

/// a frequently needed alias
typealias JSONDictionary = [String:Any]

struct AlexaRequestEnvelope {
  var version:String
  var session:AlexaSession?
  var context:AlexaContext?
  var request:AlexaRequest
}

extension AlexaRequestEnvelope
{
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? JSONDictionary,
      let theVersion = v["version"] as? String,
      let theRequest = v["request"] as? AlexaRequest
      else { return nil }
    
    version = theVersion
    request = theRequest
    
    if let theSessionDict = v["session"] as? JSONDictionary,
      let theSession = AlexaSession(JSON:theSessionDict) {
      session = theSession
    }
    else {
      session = nil
    }

    if let theContextDict = v["context"] as? JSONDictionary,
       let theContext = AlexaContext(JSON:theContextDict) {
        context = theContext
    }
    else {
        context = nil
    }

    
  }
}

/**
 Must be LaunchRequest, Intentrequest, or SessionEndRequest
 */
typealias AlexaRequest = JSONDictionary

struct LaunchRequest
{
  var type:String
  var requestId:String
  var timestamp:String?
  var locale:String?
}

extension LaunchRequest {
  init?(JSON JSONValue:JSONDictionary) {
    guard
      let theType = JSONValue["type"] as? String,
      let theRequestId = JSONValue["requestId"] as? String,
      theType == "LaunchRequest"
      else { return nil }

    if let theTimestamp = JSONValue["timestamp"] as? String {
      timestamp = theTimestamp
    }
    else {
      timestamp = nil
    }
    
    if let theLocale = JSONValue["locale"] as? String {
      locale = theLocale
    } else {
      locale = nil
    }
    
    type = theType
    requestId = theRequestId
  }
}

/*
{
  "type": "SessionEndedRequest",
  "requestId": "string",
  "timestamp": "string",
  "reason": "string",
  "locale": "string",
  "error": {
    "type": "string",
    "message": "string"
  }
}
*/

struct SessionEndRequest
{
  var type:String
  var requestId:String
  var reason:String
  var timestamp:String?
  var locale:String?
  var error:JSONDictionary?
}

extension SessionEndRequest {
  init?(JSON JSONValue:JSONDictionary) {
    guard
      let theType = JSONValue["type"] as? String,
      let theRequestId = JSONValue["requestId"] as? String,
      let theReason = JSONValue["reason"] as? String,
      theType == "SessionEndRequest"
      else { return nil }

    if let theTimestamp = JSONValue["timestamp"] as? String {
      timestamp = theTimestamp
    }
    else {
      timestamp = nil
    }
    
    if let theLocale = JSONValue["locale"] as? String {
      locale = theLocale
    } else {
      locale = nil
    }

    if let theError = JSONValue["error"] as? JSONDictionary {
      error = theError
    } else {
      error = nil
    }
    
    type = theType
    requestId = theRequestId
    reason = theReason
  }
}


// TODO: implement AlexaIntent
typealias AlexaIntent = JSONDictionary
struct IntentRequest
{
  var type:String
  var requestId:String
  var timestamp:String?
  var locale:String?
  var intent:AlexaIntent
}

extension IntentRequest {
  init?(JSON JSONValue:JSONDictionary) {
    guard let theType = JSONValue["type"] as? String,
      let theRequestId = JSONValue["requestId"] as? String,
      let theIntent = JSONValue["intent"] as? JSONDictionary,
      theType == "IntentRequest"
      else { return nil }


      if let theTimestamp = JSONValue["timestamp"] as? String {
          timestamp = theTimestamp
      } else {
          timestamp = nil
      }
      if let theLocale = JSONValue["locale"] as? String {
          locale = theLocale
      } else {
          locale = nil
      }
      
      type = theType
      requestId = theRequestId
      intent = theIntent
  }
}


/*

// actual sample request:

// example 1:
{
  "session": {
    "new": true,
    "sessionId": "session1234",
    "attributes": {},
    "user": {
      "userId": null
    },
    "application": {
      "applicationId": "amzn1.ask.skill.221dba25-e4b4-40bc-952c-5b25ec81bd4d"
    }
  },
  "version": "1.0",
  "request": {
    "type": "LaunchRequest",
    "requestId": "request5678"
  }
}

// example 2:

 */
struct AlexaSession {
  var new:Bool
  var sessionId:String
  var application:AlexaApplication
  var attributes:AlexaSessionAttributes
  var user:AlexaUser
}

extension AlexaSession
{
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? JSONDictionary,
      let theNew = v["new"] as? Bool,
      let theSessionId = v["sessionId"] as? String,
      let theApplicationDict = v["application"] as? [String:String],
      let theApplication = AlexaApplication(JSON: theApplicationDict),
      let theAttributes = v["attributes"] as? [String:Any],
      let theUserDict = v["user"] as? JSONDictionary,
      let theUser = AlexaUser(JSON:theUserDict)
      else { return nil }
    new = theNew
    sessionId = theSessionId
    application = theApplication
    attributes = theAttributes
    user = theUser
  }
}

/*
 {
 "applicationId": "string"
 }
 */
struct AlexaApplication {
  var applicationId:String
}

extension AlexaApplication {
  init?(JSON JSONValue:JSONDictionary) {
    guard
      let d = JSONValue as? [String:String],
      let s = d["applicationId"]
      else { return nil }
    applicationId = s
  }
}

typealias AlexaSessionAttributes = [String:Any]

/*
 {
 "userId": "string",
 "accessToken": "string"
 }
 */
struct AlexaUser {
  var userId:String
  var accessToken:String
}

extension AlexaUser {
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? JSONDictionary,
      let theUserId = v["userId"] as? String,
      let theAccessToken = v["accessToken"] as? String
      else { return nil }
    userId = theUserId
    accessToken = theAccessToken
  }
}

/*
 {
 "System": {
 "application": {
 "applicationId": "string"
 },
 "user": {
 "userId": "string",
 "accessToken": "string"
 },
 "device": {
 "supportedInterfaces": {
 "AudioPlayer": {}
 }
 }
 },
 "AudioPlayer": {
 "token": "string",
 "offsetInMilliseconds": 0,
 "playerActivity": "string"
 }
 }
 */

struct AlexaContext {
  var System:AlexaSystem
  var AudioPlayer:AlexaAudioPlayer
}

extension AlexaContext {
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? JSONDictionary,
      let theSystemDict = v["System"] as? JSONDictionary,
      let theSystem = AlexaSystem(JSON:theSystemDict),
      let theAudioPlayerDict = v["AudioPlayer"] as? JSONDictionary,
      let theAudioPlayer = AlexaAudioPlayer(JSON:theAudioPlayerDict)
      else { return nil }
    
    System = theSystem
    AudioPlayer = theAudioPlayer
  }
}

/*
 {
 "application": {
 "applicationId": "string"
 },
 "user": {
 "userId": "string",
 "accessToken": "string"
 },
 "device": {
 "supportedInterfaces": {
 "AudioPlayer": {}
 }
 }
 }
 */
struct AlexaSystem {
  var application:AlexaApplication
  var user:AlexaUser
  var device:AlexaDevice
}

extension AlexaSystem {
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? JSONDictionary,
      let theApplicationD = v["application"] as? JSONDictionary,
      let theApplication = AlexaApplication(JSON:theApplicationD),
      let theUserD = v["user"] as? JSONDictionary,
      let theUser = AlexaUser(JSON:theUserD),
      let theDeviceD = v["device"] as? JSONDictionary,
      let theDevice = AlexaDevice(JSON:theDeviceD)
      else { return nil }
    application = theApplication
    user = theUser
    device = theDevice
  }
}

/*
 {
 "supportedInterfaces": {
 "AudioPlayer": {}
 }
 }
 */
struct AlexaDevice {
  var supportedInterfaces:[String:AnyObject]
}

extension AlexaDevice {
  init?(JSON JSONValue:Any) {
    guard
      let v = JSONValue as? [String:AnyObject]
      else { return nil }
    supportedInterfaces = v
  }
}

/*
 "AudioPlayer": {
 "token": "string",
 "offsetInMilliseconds": 0,
 "playerActivity": "string"
 }
 */
struct AlexaAudioPlayer {
  var token:String
  var offsetInMilliseconds:Double
  var playerActivity:String
}

extension AlexaAudioPlayer {
  init?(JSON JSONValue:Any) {
    guard
      let d = JSONValue as? JSONDictionary,
      let theToken = d["token"] as? String,
      let theOffsetInMillseconds = d["offsetInMilliseconds"] as? Double,
      let thePlayerActivity = d["playerActivity"] as? String
      else { return nil }
    token = theToken
    offsetInMilliseconds = theOffsetInMillseconds
    playerActivity = thePlayerActivity
  }
}

// MARK: - response

/*
 
 {
 "version": "string",
 "sessionAttributes": {
 "string": object
 },
 "response": {
 "outputSpeech": {
 "type": "string",
 "text": "string",
 "ssml": "string"
 },
 "card": {
 "type": "string",
 "title": "string",
 "content": "string",
 "text": "string",
 "image": {
 "smallImageUrl": "string",
 "largeImageUrl": "string"
 }
 },
 "reprompt": {
 "outputSpeech": {
 "type": "string",
 "text": "string",
 "ssml": "string"
 }
 },
 "directives": [
 {
 "type": "string",
 "playBehavior": "string",
 "audioItem": {
 "stream": {
 "token": "string",
 "url": "string",
 "offsetInMilliseconds": 0
 }
 }
 }
 ],
 "shouldEndSession": boolean
 }
 }
 
 */

struct AlexaResponseEnvelope {
  var version:String
  var sessionAttributes:AlexaSessionAttributes?
  var response:AlexaResponse
}

extension AlexaResponseEnvelope {
  var asJSON:JSONDictionary {
    let emptyDictionary:[String:String] = [:]
    var d:JSONDictionary = [:]
    d["version"] = self.version
    d["sessionAttributes"] = self.sessionAttributes ?? emptyDictionary
    d["response"]  = self.response.asJSON
    return d
  }
  
  /// hack to workaround JSONSerialization bug with Bools: https://bugs.swift.org/browse/SR-3013
  var asJSONString:String
  {
    var kvStrings:[String] = []

    kvStrings.append( "\"version\" : \"\(self.version)\"" )

    if
      let speechJSON = self.sessionAttributes,
      let speechData = try? JSONSerialization.data(withJSONObject: speechJSON, options: []),
      let speechString = String(data:speechData,encoding:.utf8) {
      
      let key = "sessionAttributes"
      kvStrings.append( " \"\(key)\" : \(speechString) " )
    }
    else {
      let key = "sessionAttributes"
      kvStrings.append( "\"\(key)\" : {}" )
    }
    
    let responseKey = "response"
    let responseValueString = self.response.asJSONString
    kvStrings.append( "\"\(responseKey)\" : \(responseValueString)" )
    
    let s = "{\n" + kvStrings.joined(separator: ",\n") + "\n}"
    
    return s
  }
}

struct AlexaResponse
{
  var outputSpeech:AlexaOutputSpeech?
  var card:AlexaCard?
  var reprompt:AlexaReprompt?
  var directives:[AlexaDirective]?
  var shouldEndSession:Bool?
}
extension AlexaResponse
{
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["outputSpeech"] = self.outputSpeech?.asJSON
    d["card"] = self.card?.asJSON
    d["reprompt"] = self.reprompt?.asJSON
    
    if let directives = self.directives
    {
      d["directives"] = directives.map({
        (directive:AlexaDirective) -> JSONDictionary in
        return directive.asJSON
      })
    }
    else {
      d["directives"] = nil
    }
    
    if let shouldEndSession = self.shouldEndSession {
      d["shouldEndSession"] = shouldEndSession
    } else {
      d["shouldEndSession"] = nil
    }
    
    return d
  }

  /// hack to workaround JSONSerialization bug with Bools: https://bugs.swift.org/browse/SR-3013
   var asJSONString:String
   {
    var kvStrings:[String] = []

    if
      let speechJSON = self.outputSpeech?.asJSON,
      let speechData = try? JSONSerialization.data(withJSONObject: speechJSON, options: []),
      let speechString = String(data:speechData,encoding:.utf8) {
      
      let key = "outputSpeech"
      
      kvStrings.append( "\"\(key)\" : \(speechString)" )
    }
      
    if
      let speechJSON = self.card?.asJSON,
      let speechData = try? JSONSerialization.data(withJSONObject: speechJSON, options: []),
      let speechString = String(data:speechData,encoding:.utf8) {
      
      let key = "card"
      
      kvStrings.append( "\"\(key)\" : \(speechString)" )
    }

    if
      let speechJSON = self.reprompt?.asJSON,
      let speechData = try? JSONSerialization.data(withJSONObject: speechJSON, options: []),
      let speechString = String(data:speechData,encoding:.utf8) {
      
      let key = "reprompt"
      kvStrings.append( "\"\(key)\" = \(speechString)" )
    }

    if
      let directivesJSON = self.directives?.map({
        (directive:AlexaDirective) -> JSONDictionary in
        return directive.asJSON
      }),
      let directivesData = try? JSONSerialization.data(withJSONObject: directivesJSON, options: []),
      let directivesString = String(data:directivesData,encoding:.utf8)
    {
      let key = "directives"
      kvStrings.append( "\"\(key)\" : \(directivesString)" )
    }
    

    if let shouldEndSession = self.shouldEndSession {
        let v:String = shouldEndSession ? "true" : "false"
        let kvShouldEndSession = "\"shouldEndSession\" : \(v)"
      kvStrings.append( kvShouldEndSession )
    }
    
    let s = "{\n" + kvStrings.joined(separator: ",\n") + "\n}"

    return s
   }
}


struct AlexaReprompt {
  var outputSpeech:AlexaOutputSpeech?
}
extension AlexaReprompt
{
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["outputSpeech"] = outputSpeech
    return d
  }
}

// poor mans variant type
struct AlexaOutputSpeech {
  // valid values: "PlainText" "SSML"
  var type:String
  var text:String?
  var ssml:String?
  
  init(text t:String) {
    type = "PlainText"
    text = t
    ssml = nil
  }
}

extension AlexaOutputSpeech {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["type"] = type
    d["text"] = text
    d["ssml"] = ssml
    return d
  }
}

struct AlexaCard {
  /// valid values: Simple, Standard, LinkAccount
  var type:String
  var title:String?
  var content:String?
  var text:String?
  var image:AlexaImage?
}

extension AlexaCard {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["type"] = self.type
    d["title"] = self.title
    d["content"] = self.content
    d["text"] = self.text
    d["image"] = self.image?.asJSON
    return d
  }
}

struct AlexaImage {
  var smallImageURL:URL
  var largeImageURL:URL
}
extension AlexaImage {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["smallImageURL"] = smallImageURL.absoluteString
    d["largeImageURL"] = largeImageURL.absoluteString
    return d
  }
}

struct AlexaDirective {
  var type:String
  var playBehavior:String
  var audioItem:AlexaAudioItem
}
extension AlexaDirective {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["type"] = type
    d["playBehavior"] = playBehavior
    d["audioItem"] = audioItem.asJSON
    return d
  }
}


struct AlexaAudioItem {
  var stream:AlexaAudioStream
}
extension AlexaAudioItem {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["stream"] = stream.asJSON
    return d
  }
}

struct AlexaAudioStream {
  var token:String
  var url:URL
  var offsetInMilliseconds:Double
}

extension AlexaAudioStream {
  var asJSON:JSONDictionary {
    var d:JSONDictionary = [:]
    d["token"] = token
    d["url"] = url.absoluteString
    d["offsetInMilliseconds"] = offsetInMilliseconds
    return d
  }
}


