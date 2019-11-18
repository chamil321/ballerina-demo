import ballerina/http;

@http:ServiceConfig { basePath: "/" }
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request req) 
                                                    returns error? {
        var payload = check req.getTextPayload();
        checkpanic caller -> respond("Hello " + <@untainted> payload + "!\n");
    }
}
