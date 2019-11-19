import ballerina/config;
import ballerina/http;
import ballerina/log;
import wso2/twitter;

http:Client homer = new("https://thesimpsonsquoteapi.glitch.me", {
        circuitBreaker: {
            failureThreshold: 0.0,
            resetTimeInMillis: 3000,
            statusCodes: [500, 501, 502]
        },
        timeoutInMillis: 900
    });

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

        var quote = homer->get("/quote");
        json resp;
        if (quote is http:Response) {
            var payload = check quote.getTextPayload();
            payload = payload + " #ballerina";

            var st = check tw->tweet(payload);
            resp = {
                text: payload,
                id: st.id,
                agent: "ballerina"
            };
        } else {
            resp = "Circuit is open. Invoking default behavior.\n";
        }

        var result = caller->respond(<@untainted> resp);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}
