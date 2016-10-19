import Foundation

// print("Hello, world, from Swift! Echoing stdin. CTRL-D to stop")

/*
 This function just cleanly echoes its input. Here is where you would 
 put in your own logic, which did String->JSONRequest->JSONResponse->String
 */

fileprivate 
func echo(string:String) -> String {
    return string
}

// read stdin to a String, transform it, return the result
readTransformPrint(transform:echo)
