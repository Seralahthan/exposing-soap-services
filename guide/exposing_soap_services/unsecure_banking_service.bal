import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/docker;

//@docker:Config {
//    registry:"ballerina.guides.io",
//    name:"unsecure_banking_service",
//    tag:"v1.0"
//}

//@docker:Expose{}
//endpoint http:Listener soapHandlerEndpoint {
//    port:9090
//};

endpoint http:Listener soapHandlerEndpoint {
    port: 9090
};

@http:ServiceConfig {
    basePath: "/soapService"
}

service<http:Service> soapHandler bind soapHandlerEndpoint {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/accountDetails"

    }

    processSoapRequest(endpoint caller, http:Request req) {
        xmlns "http://services.samples" as m0;
        xmlns "http://www.w3.org/2001/12/soap-encoding" as soapenc;
        xmlns "http://www.w3.org/2001/12/soap-envelope" as soapenv;
        xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" as wsse;
        xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" as wsu;

        http:Response response;

        log:printInfo("Processing the SOAP request from the client");
        var res = req.getXmlPayload();
        io:println("Processing Soap");
        xml soapPayload;
        match (res) {
            xml val => soapPayload = val;
            error e => {
                io:println(e);
            }
        }

        if(!soapPayload.isEmpty()){
            if(soapPayload.isSingleton()){
                //Processing soap payload as xml
                io:println("Processing soap payload as xml\n");
                //io:println("Soap payload: " + <string>soapPayload);

                xml temp = soapPayload.*;
                xml childElements = temp.strip();

                boolean isValidSoapAction = false;
                (xml, string)[] arr;
                if(childElements.isSingleton()){
                    xml soapBody = childElements.slice(0,1);
                    io:println("Soap Body :" + <string>soapBody);
                    var resp = processSoapBody(soapBody);
                    match resp {
                        (xml,string)[] t1 => {
                            isValidSoapAction = true;
                            arr = t1;
                        }
                        error err => {
                            response.setPayload(untaint err.message);
                        }
                    }

                } else {
                    response.setPayload("Unsecure soap service : Soap headers are not allowed");
                }

                if(isValidSoapAction){
                    xml extractedBody;
                    string filteredAction;
                    xml payload;
                    int i = 0;
                    io:println("Array length : "+ lengthof(arr));
                    foreach item in arr {
                        (extractedBody, filteredAction) = item;
                        string soapAction = "urn:"+ filteredAction;
                        io:println("Before calling back-end");
                        var resp = unsecureBankingConnector(soapAction,extractedBody);
                        io:println("After calling back-end");
                        match resp {
                            soap:SoapResponse soapResponse => {
                                io:println(soapResponse);
                                xml temp2 = <xml>soapResponse.payload;
                                payload = payload + temp2;
                            }
                            soap:SoapError soapError => {
                                io:println(soapError);
                                response.setPayload("Axis2 service error while processing the soap request\n");
                            }
                        }
                        i = i + 1;
                    }
                    response.setPayload(untaint payload);


                }

            }else{
                response.setPayload("Error:soap message has more than one envelope\n");
            }

        } else {
            response.setPayload("Error:soap message is empty\n");
        }

        _ = caller -> respond(response);

    }
}

public function processSoapBody(xml soapBody) returns (xml,string)[]|error {
     xml temp = soapBody.*;
     xml accountDetails = temp.strip();
     json j1 = accountDetails.toJSON({});
     string[] arr = j1.getKeys();
     int i = 0;
     (xml,string)[] result;
     if(lengthof(arr) > 0){
         foreach item in arr {
             string[] temp1 = item.split(":");
             xml req = accountDetails.slice(i, i+1);
             result[i] = (req, temp1[1]);
             i = i+1;
         }
     }else{
        error err = { message: "No soap action found the soap message body" };
        return err;
     }
     return result;
}




