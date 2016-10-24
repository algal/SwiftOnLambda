import Foundation

// print("Hello, world, from Swift! Echoing stdin. CTRL-D to stop")

/*
 This function just cleanly echoes its input. 
 */

fileprivate 
func echo(string:String) -> String {
    return string
}

/*

 `Greeter.service` implements a simple Alexa Custom Skill that says
 "Hello from Swift"

 */
let g = Greeter()
func greetResponse(string:String) -> String {
    return g.service(string:string)
}

/*

USER: if you want to define your own Lambda function in swift, just
define a function `f:(String)->String` and pass it in as the argument
to `readTransformPrint`.

Be sure your function `f` expects a String containing JSON and returns
a String containing JSON.

*/

// echo: reads a string and returns it exactly
readTransformPrint(transform:echo)

// ALEXA: reads an Alexa Request envelope and returns a response
//readTransformPrint(transform:greetResponse)
