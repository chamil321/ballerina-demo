import ballerina/config;
import ballerina/http;
import wso2/twitter;

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig: {}
});

@http:ServiceConfig {
    basePath: "/"
}
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) 
                                                        returns error? {
        string payload = check request.getTextPayload();
        twitter:Status st = check tw->tweet(payload);
        checkpanic caller->respond("Tweeted: " + <@untainted> st.text);
    }
}
