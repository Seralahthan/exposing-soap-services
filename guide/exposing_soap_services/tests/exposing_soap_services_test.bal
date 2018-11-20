import ballerina/io;
import ballerina/test;
import wso2/soap;
import ballerina/http;
import ballerina/math;

 xmlns "http://services.samples" as ns;
 xmlns "http://services.samples/xsd" as axis;

endpoint http:Client clientEP {
    url:"http://localhost:9090/soapService"
};

@test:Config {}
function createAccountDetails() {
    io:println("Running the test for : Creating account details");
    http:Request req;
    //xml createReqHeader = xml `<?xml version="1.0"?>`;
    xml createReq = xml `<soapenv:Envelope xmlns:soapenc="http://www.w3.org/2001/12/soap-encoding"   xmlns:soapenv="http://www.w3.org/2001/12/soap-envelope">
                                <soapenv:Body>
                                    <m0:createAccountDetails xmlns:m0="http://services.samples">
                                        <m0:request>
                                            <m0:accountNo>2417255</m0:accountNo>
                                            <m0:accountHolderName>BallerinaUser</m0:accountHolderName>
                                            <m0:accountBalance>200000.00</m0:accountBalance>
                                        </m0:request>
                                    </m0:createAccountDetails>
                                </soapenv:Body>
                            </soapenv:Envelope>`;



    //xml createReq = createReqHeader + xml `\n`+ createReqBody;
    //io:println(createReq);
    //req.addHeader("Content-Type", "text/xml");
    req.setXmlPayload(createReq);
    //req.setPayload(createReq);

    var createResp = clientEP -> post("/accountDetails", req);


    string[] expCreateResp = ["BallerinaUser","2417255","200000.0"];

    //xml soapPayload;
    match createResp {
        http:Response response => {
            //io:println("http response");
            if(response.hasHeader("Content-Type")){
                if(response.getHeader("Content-Type")=="application/xml"){
                    var resp = response.getXmlPayload();
                    match (resp) {
                        xml soapPayload => {
                            //soapPayload = temp;

                            //io:println(soapPayload);

                            string[] soapCreateResp = [<string>soapPayload.selectDescendants(axis:accountHolderName)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountNo)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountBalance)[0].getTextValue()];

                            test:assertEquals(soapCreateResp, expCreateResp, msg = "Assertion Failed for creating account details");
                        }
                        error e => io:println(e);
                    }
                }
                if(response.getHeader("Content-Type")=="text/html"){
                    var serviceError = response.getTextPayload();
                    io:println(serviceError);
                    test:assertFail(msg = "Ballerina SOAP Service Error");
                }
            }
        }
        error err => {
            io:println(err);
            test:assertFail(msg = "Failed to retrieve data from the soap service");
        }
    }
}

@test:Config {
    dependsOn: ["createAccountDetails"]
}
function getAccountDetails() {
    io:println("Running the test for : Fetching account details");
    http:Request req;
    //xml getReqHeader = xml `<?xml version="1.0"?>`;
    xml getReq =   xml `<soapenv:Envelope xmlns:soapenc="http://www.w3.org/2001/12/soap-encoding"   xmlns:soapenv="http://www.w3.org/2001/12/soap-envelope">
                                <soapenv:Body>
                                    <m0:getAccountDetails xmlns:m0="http://services.samples">
                                        <m0:request>
                                            <m0:accountNo>2417255</m0:accountNo>
                                        </m0:request>
                                    </m0:getAccountDetails>
                                </soapenv:Body>
                            </soapenv:Envelope>`;


    req.setXmlPayload(getReq);

    var getResp = clientEP -> post("/accountDetails", req);

    string[] expGetResp = ["BallerinaUser","2417255","200000.0"];

    match getResp {
        http:Response response => {
            //io:println("http response");
            if(response.hasHeader("Content-Type")){
                if(response.getHeader("Content-Type")=="application/xml"){
                    var resp = response.getXmlPayload();
                    match (resp) {
                        xml soapPayload => {
                            //soapPayload = temp;

                            //io:println(soapPayload);

                            string[] soapGetResp = [<string>soapPayload.selectDescendants(axis:accountHolderName)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountNo)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountBalance)[0].getTextValue()];

                            test:assertEquals(soapGetResp, expGetResp, msg = "Assertion Failed for fetching account details");
                        }
                        error e => io:println(e);
                    }
                }
                if(response.getHeader("Content-Type")=="text/html"){
                    var serviceError = response.getTextPayload();
                    io:println(serviceError);
                    test:assertFail(msg = "Ballerina SOAP Service Error");
                }
            }
        }
        error err => {
            io:println(err);
            test:assertFail(msg = "Failed to retrieve data from the soap service");
        }
    }

}

@test:Config {
    dependsOn: ["getAccountDetails"]
}
function updateAccountDetails() {
    io:println("Running the test for : Updating account details");
    http:Request req;
    //xml updateReqHeader = xml `<?xml version="1.0"?>`;
    xml updateReq = xml `<soapenv:Envelope xmlns:soapenc="http://www.w3.org/2001/12/soap-encoding"   xmlns:soapenv="http://www.w3.org/2001/12/soap-envelope">
                                <soapenv:Body>
                                    <m0:updateAccountDetails xmlns:m0="http://services.samples">
                                        <m0:request>
                                            <m0:accountNo>2417255</m0:accountNo>
                                            <m0:accountBalance>375000.00</m0:accountBalance>
                                        </m0:request>
                                    </m0:updateAccountDetails>
                                </soapenv:Body>
                            </soapenv:Envelope>`;

    req.setXmlPayload(updateReq);

    var updateResp = clientEP -> post("/accountDetails", req);

    string[] expUpdateResp = ["BallerinaUser","2417255","375000.0"];

    match updateResp {
        http:Response response => {
            //io:println("http response");
            if(response.hasHeader("Content-Type")){
                if(response.getHeader("Content-Type")=="application/xml"){
                    var resp = response.getXmlPayload();
                    match (resp) {
                        xml soapPayload => {
                            //soapPayload = temp;

                            //io:println(soapPayload);

                            string[] soapUpdateResp = [<string>soapPayload.selectDescendants(axis:accountHolderName)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountNo)[0].getTextValue(),
                            <string>soapPayload.selectDescendants(axis:accountBalance)[0].getTextValue()];

                            test:assertEquals(soapUpdateResp, expUpdateResp, msg = "Assertion Failed for updating account details");
                        }
                        error e => io:println(e);
                    }
                }
                if(response.getHeader("Content-Type")=="text/html"){
                    var serviceError = response.getTextPayload();
                    io:println(serviceError);
                    test:assertFail(msg = "Ballerina SOAP Service Error");
                }
            }
        }
        error err => {
            io:println(err);
            test:assertFail(msg = "Failed to retrieve data from the soap service");
        }
    }

}

@test:Config {
    dependsOn: ["updateAccountDetails"]
}
function deleteAccountDetails() {
    io:println("Running the test for : Removing account details");
    http:Request req;
    //xml deleteReqHeader = xml `<?xml version="1.0"?>`;
    xml deleteReq = xml `<soapenv:Envelope xmlns:soapenc="http://www.w3.org/2001/12/soap-encoding"   xmlns:soapenv="http://www.w3.org/2001/12/soap-envelope">
                                <soapenv:Body>
                                    <m0:deleteAccountDetails xmlns:m0="http://services.samples">
                                        <m0:request>
                                            <m0:accountNo>2417255</m0:accountNo>
                                        </m0:request>
                                    </m0:deleteAccountDetails>
                                </soapenv:Body>
                            </soapenv:Envelope>`;

    req.setXmlPayload(deleteReq);

    var deleteResp = clientEP -> post("/accountDetails", req);

    string[] expDeleteResp = ["Account : 2417255 Deleted Successfully"];

    match deleteResp {
        http:Response response => {
            //io:println("http response");
            if(response.hasHeader("Content-Type")){
                if(response.getHeader("Content-Type")=="application/xml"){
                    var resp = response.getXmlPayload();
                    match (resp) {
                        xml soapPayload => {
                            //soapPayload = temp;

                            //io:println(soapPayload);

                            string[] soapDeleteResp = [<string>soapPayload.selectDescendants(axis:message)[0].getTextValue()];

                            test:assertEquals(soapDeleteResp, expDeleteResp, msg = "Assertion Failed for removing account details");
                        }
                        error e => io:println(e);
                    }
                }
                if(response.getHeader("Content-Type")=="text/html"){
                    var serviceError = response.getTextPayload();
                    io:println(serviceError);
                    test:assertFail(msg = "Ballerina SOAP Service Error");
                }
            }
        }
        error err => {
            io:println(err);
            test:assertFail(msg = "Failed to retrieve data from the soap service");
        }
    }
}

