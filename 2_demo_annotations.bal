import ballerina/http;
import ballerina/log;

@http:ServiceConfig { basePath: "/" }
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request req) 
                                                    returns error? {
        var payload = check req.getTextPayload();
        var result = caller -> respond("Hello " + <@untainted> payload + "!\n");
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}
