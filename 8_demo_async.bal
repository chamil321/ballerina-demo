import ballerina/config;
import ballerina/http;
import ballerina/log;
import wso2/twitter;

twitter:Client tw = new ({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig: {}
});

http:Client homer = new ("https://thesimpsonsquoteapi.glitch.me");

@http:ServiceConfig {
    basePath: "/"
}
service hello on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/"
    }
    resource function hi(http:Caller caller, http:Request request) {
        _ = start doTweet();
        http:Response res = new;
        res.setPayload("Async call\n");
        var result = caller->respond(res);
        if (result is error) {
            log:printError("Error sending response", result);
        }
    }
}

function doTweet() returns @tainted error? {
    var hResp = check homer->get("/quotes");
    var jsonPay = check hResp.getJsonPayload();

    if !(jsonPay is json[]) {
        return error("InvalidPayload", message = "expected a JSON[], found " + jsonPay.toJsonString());
    } else {
        string payload = jsonPay[0].quote.toString().concat(" #b7a");
        twitter:Status st = check tw->tweet(payload);
        log:printInfo("Tweeted: " + <@untainted>st.text);
    }
}
