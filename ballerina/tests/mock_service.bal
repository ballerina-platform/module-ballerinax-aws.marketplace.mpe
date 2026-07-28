// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

const int MOCK_SERVER_PORT = 9531;
final string mockServerUrl = string `http://localhost:${MOCK_SERVER_PORT}`;

const string AWS_JSON_CONTENT_TYPE = "application/x-amz-json-1.1";
const string GET_ENTITLEMENTS_TARGET = "AWSMPEntitlementService.GetEntitlements";

// Stands in for the subscribed product code a live run reads from the environment.
const string MOCK_PRODUCT_CODE = "mock-product-code";
const string MOCK_DIMENSION = "users";
const string MOCK_CUSTOMER_IDENTIFIER = "mock-customer-0001";
const string MOCK_REQUEST_ID = "mock-request-id";

// 2030-01-01T00:00:00Z as the epoch seconds the AWS JSON protocol uses for timestamps.
const int MOCK_EXPIRATION_EPOCH = 1893456000;

// The `GetEntitlements` valid range for `MaxResults`, enforced by the service itself.
const int MPE_MIN_MAX_RESULTS = 1;
const int MPE_MAX_MAX_RESULTS = 25;

final http:Listener mockListener = check new (MOCK_SERVER_PORT);

final http:Service mockService = service object {

    isolated resource function post .(http:Request request) returns http:Response|error {
        string target = check request.getHeader("X-Amz-Target");
        if target != GET_ENTITLEMENTS_TARGET {
            return awsErrorResponse(400, "UnknownOperationException", string `unsupported target: ${target}`);
        }
        byte[] rawPayload = check request.getBinaryPayload();
        json payload = check (check string:fromBytes(rawPayload)).fromJsonString();
        json|error maxResults = payload.MaxResults;
        if maxResults is int && (maxResults < MPE_MIN_MAX_RESULTS || maxResults > MPE_MAX_MAX_RESULTS) {
            return awsErrorResponse(400, "InvalidParameterException",
                    string `1 validation error detected: Value '${maxResults}' at 'maxResults' failed to satisfy ` +
                    string `constraint: Member must be between ${MPE_MIN_MAX_RESULTS} and ${MPE_MAX_MAX_RESULTS}`);
        }

        string productCode = check (check payload.ProductCode).ensureType();
        return buildResponse(productCode);
    }
};

isolated function buildResponse(string productCode) returns http:Response {
    if productCode == MOCK_PRODUCT_CODE {
        return awsJsonResponse({
            "Entitlements": [
                {
                    "ProductCode": MOCK_PRODUCT_CODE,
                    "Dimension": MOCK_DIMENSION,
                    "CustomerIdentifier": MOCK_CUSTOMER_IDENTIFIER,
                    "ExpirationDate": MOCK_EXPIRATION_EPOCH,
                    "Value": {"IntegerValue": 25}
                }
            ]
        });
    }
    return awsJsonResponse({"Entitlements": []});
}

isolated function awsJsonResponse(json payload) returns http:Response {
    http:Response response = new;
    response.statusCode = http:STATUS_OK;
    response.setHeader("x-amzn-RequestId", MOCK_REQUEST_ID);
    response.setJsonPayload(payload, AWS_JSON_CONTENT_TYPE);
    return response;
}

isolated function awsErrorResponse(int statusCode, string errorType, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setHeader("x-amzn-RequestId", MOCK_REQUEST_ID);
    response.setHeader("x-amzn-ErrorType", errorType);
    response.setJsonPayload({"__type": errorType, "message": message}, AWS_JSON_CONTENT_TYPE);
    return response;
}
