import ballerina/config;
import ballerina/http;
import ballerina/log;
import wso2/twitter;

http:Client homer = new("https://thesimpsonsquoteapi.glitch.me");

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig: {}  
});

@http:ServiceConfig { basePath: "/" }
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) 
                                                    returns error? {

        var hResp = check homer->get("/quote");
        var status = check hResp.getTextPayload();
        status = status + " #ballerina";

        twitter:Status st = check tw->tweet(status);
        json myJson = {
            text: status,
            id: st.id,
            agent: "ballerina"
        };

        var result = caller->respond(<@untainted> myJson);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}
