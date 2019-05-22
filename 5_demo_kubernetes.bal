import ballerina/config;
import ballerina/http;
import wso2/twitter;
import ballerinax/kubernetes;

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig:{}
});

@kubernetes:Service {
    serviceType: "NodePort",
    name: "ballerina-demo"
}
listener http:Listener cmdListener = new(9090);


@kubernetes:Deployment {
    image: "demo/ballerina-demo",
    name: "ballerina-demo"
}
@kubernetes:ConfigMap{ conf: "twitter.toml" }
@http:ServiceConfig { basePath: "/" }
service hello on cmdListener {

    @http:ResourceConfig {
        path: "/", 
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {
        string payload = checkpanic request.getTextPayload();
        twitter:Status st = checkpanic tw->tweet(payload);
        checkpanic caller->respond("Tweeted: " + untaint st.text);
    }
}
