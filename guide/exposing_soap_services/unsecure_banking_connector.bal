import wso2/soap;
import ballerina/io;

endpoint soap:Client soapClient {
    clientConfig: {
        url: "http://localhost:9000/services"
    }
};

//endpoint http:Client testClient {
//    url:"http://localhost:9090/ordermgt"
//};

public function unsecureBankingConnector(string soapAction, xml soapBody) returns soap:SoapResponse|soap:SoapError {
    soap:SoapRequest soapRequest = {
        soapAction: soapAction,
        payload: soapBody
    };

    var soapResp = soapClient->sendReceive("/UnsecureBankingService", soapRequest);
    return soapResp;
}

//public function orderMgtConnector(http:Request req) returns http:Response {
//    io:println("comes to order management connector");
//    http:Response resp = check testClient -> post("/order", untaint req);
//    return resp;
//}