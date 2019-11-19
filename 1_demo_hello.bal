import ballerina/http;
import ballerina/log;

service hello on new http:Listener(9090) {

    resource function hi(http:Caller caller, http:Request request) {
        var result = caller -> respond("Hello World!\n");
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}
