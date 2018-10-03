import ballerina/http;
import ballerina/io;
import ballerina/log;


endpoint http:Listener soapHandlerEndpoint {
    port: 9090
};

@http:ServiceConfig {
    basePath: "/soapService"
}

service<http:Service> soapHandler bind soapHandlerEndpoint {
    @http:ResourceConfig {
        path:"/accountDetails"
    }

    processSoapRequest(endpoint caller, http:Request req) {
        xmlns "http://services.samples" as m0;
        xmlns "http://www.w3.org/2001/12/soap-encoding" as soapenc;
        xmlns "http://www.w3.org/2001/12/soap-envelope" as soapenv;
        xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" as wsse;
        xmlns "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" as wsu;

        http:Response response = new;
        response.setHeader("Content-Type","text/xml");

        log:printInfo("Processing the SOAP request from the client");
        var res = req.getXmlPayload();
        xml soapPayload;
        match (res) {
            xml val => soapPayload = val;
            error e => {
                io:println(e);
            }
        }
        //io:println(soapPayload);
        //xml checkEnvelope = soapPayload.selectDescendants("soapenv:Envelope");
        //io:println("CheckEnvelope :" + <string> checkEnvelope);
        //Handle when the soap payload is empty, throw an error.
        if(!soapPayload.isEmpty()){
            //boolean isEmpty = soapPayload.isEmpty();
            //io:println("isEmpty :" + isEmpty);
            // boolean isSingleton = soapPayload.isSingleton();
            if(soapPayload.isSingleton()){
                //Processing soap payload as xml
                io:println("\n Processing soap payload as xml\n");
                //io:println("Soap payload: " + <string>soapPayload);

                xml temp = soapPayload.*;
                xml childElements = temp.strip();
                //io:println("child elements isSingleton :" + childElements.isSingleton());
                //io:println("child element :" + <string>childElements);
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
                            response.setPayload(err.message);
                        }
                    }
                    // io:println("Extracted Soap Body : " + <string>extractedBody);
                    // io:println("Soap action : "+ soapAction);
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
                        var resp = unsecureBankingConnector(soapAction,extractedBody);
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

        caller -> respond(response) but { error e => log:printError("Error in processing ", err = e)};

    }
}

public function processSoapBody(xml soapBody) returns (xml,string)[]|error {
     xml temp = soapBody.*;
     xml accountDetails = temp.strip();
     io:println("\n");
     io:println("This is the accountDeatils : " + <string>accountDetails);
     io:println("\n");
     json j1 = accountDetails.toJSON({});
    //  io:println("This is the converted json : " + j1.toString());
     string[] arr = j1.getKeys();
    //  io:println("This is array0 : " + arr[0]);
    //  io:println("This is array1 : " + arr[1]);
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

