'use strict';

process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT']

const spawnSync = require('child_process').spawnSync;

/**  
     Defines a handler function called "index.handler" to Lambda.

     This function just transparently wraps the `swiftcommand` executable.

     It takes a JSON object `event` as input, serializes it to a
     string, invokes the `swiftcommand` executable, passing the string
     into stdin and reads the stdout, deserializes the stdout into
     JSON, and then calls back with the reponse JSON object.

     If the executable errors, the handler calls back with the error
     object intead.

     In all cases, the executable's stdout is logged to the console as
     a log message, and its stderr is logged as error messages.
     
*/
exports.handler = (event, context, callback) => {

    const options = {
        cwd: 'native/',
        env: {
            LD_LIBRARY_PATH: 'LinuxLibraries'
        },
        input:JSON.stringify(event)
    };


    var command = '';

    if (event.command) 
    {
        command = event.command;
    } else {
        command = './swiftcommand';
    }
  
    const childObject = spawnSync(command, [], options)

    var error = childObject.error;
    var stdout = childObject.stdout.toString('utf8');
    var stderr = childObject.stderr.toString('utf8');

    // Log process stdout and stderr
    console.log(stdout);
    console.error(stderr);
    
    if (error) {
        callback(error,null);
    }
    else {
        // executable's raw stdout is the Lambda output
        var response = JSON.parse(stdout);
        callback(null,response);
    }
};
