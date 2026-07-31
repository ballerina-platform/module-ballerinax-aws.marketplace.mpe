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

const string MOCK_ACCESS_KEY_ID = "mock-access-key-id";
const string MOCK_SECRET_ACCESS_KEY = "mock-secret-access-key";
const string SIGV4_ALGORITHM = "AWS4-HMAC-SHA256";

// Stands in for the subscribed product code a live run reads from the environment.
const string MOCK_PRODUCT_CODE = "mock-product-code";
const string MOCK_DIMENSION = "users";
const string MOCK_SECONDARY_DIMENSION = "storage";
const string MOCK_CUSTOMER_IDENTIFIER = "mock-customer-0001";
const string MOCK_REQUEST_ID = "mock-request-id";

// 2030-01-01T00:00:00Z as the epoch seconds the AWS JSON protocol uses for timestamps.
const int MOCK_EXPIRATION_EPOCH = 1893456000;

// The `GetEntitlements` valid range for `MaxResults`, enforced by the service itself.
const int MPE_MIN_MAX_RESULTS = 1;
const int MPE_MAX_MAX_RESULTS = 25;

const string FILTER_CUSTOMER_IDENTIFIER = "CUSTOMER_IDENTIFIER";
const string FILTER_DIMENSION = "DIMENSION";

const int MOCK_ENTITLEMENT_COUNT = 12;

type MockEntitlement record {|
    string productCode;
    string dimension;
    string customerIdentifier;
|};

final readonly & MockEntitlement[] mockEntitlements = buildFixtures();

isolated function buildFixtures() returns readonly & MockEntitlement[] {
    MockEntitlement[] entitlements = [];
    foreach int i in 1 ... MOCK_ENTITLEMENT_COUNT {
        entitlements.push({
            productCode: MOCK_PRODUCT_CODE,
            dimension: i % 2 == 1 ? MOCK_DIMENSION : MOCK_SECONDARY_DIMENSION,
            customerIdentifier: string `mock-customer-${i.toString().padZero(4)}`
        });
    }
    return entitlements.cloneReadOnly();
}

final http:Listener mockListener = check new (MOCK_SERVER_PORT);

final http:Service mockService = service object {

    isolated resource function post .(http:Request request) returns http:Response|error {
        http:Response? authFailure = validateSigV4Credential(request);
        if authFailure is http:Response {
            return authFailure;
        }
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
        json|error filter = payload.Filter;
        return buildResponse(productCode, filter is json ? filter : (),
                maxResults is int ? maxResults : ());
    }
};

isolated function validateSigV4Credential(http:Request request) returns http:Response? {
    string|error authorization = request.getHeader("Authorization");
    if authorization is error {
        return awsErrorResponse(403, "MissingAuthenticationTokenException",
                "Request is missing Authentication Token");
    }
    if !authorization.startsWith(SIGV4_ALGORITHM + " ")
            || !authorization.includes(string `Credential=${MOCK_ACCESS_KEY_ID}/`) {
        return awsErrorResponse(403, "InvalidSignatureException",
                "The request signature we calculated does not match the signature you provided");
    }
    return ();
}

isolated function buildResponse(string productCode, json filter, int? maxResults) returns http:Response {
    json[] entitlements = [];
    foreach MockEntitlement entitlement in mockEntitlements {
        if matchesRequest(entitlement, productCode, filter) {
            entitlements.push({
                "ProductCode": entitlement.productCode,
                "Dimension": entitlement.dimension,
                "CustomerIdentifier": entitlement.customerIdentifier,
                "ExpirationDate": MOCK_EXPIRATION_EPOCH,
                "Value": {"IntegerValue": 25}
            });
        }
    }
    if maxResults is int && entitlements.length() > maxResults {
        entitlements = entitlements.slice(0, maxResults);
    }
    return awsJsonResponse({"Entitlements": entitlements});
}

isolated function matchesRequest(MockEntitlement entitlement, string productCode, json filter) returns boolean {
    if entitlement.productCode != productCode {
        return false;
    }
    string[]? customerIdentifiers = filterValues(filter, FILTER_CUSTOMER_IDENTIFIER);
    if customerIdentifiers is string[] && customerIdentifiers.indexOf(entitlement.customerIdentifier) is () {
        return false;
    }
    string[]? dimensions = filterValues(filter, FILTER_DIMENSION);
    if dimensions is string[] && dimensions.indexOf(entitlement.dimension) is () {
        return false;
    }
    return true;
}

isolated function filterValues(json filter, string key) returns string[]? {
    if filter !is map<json> {
        return ();
    }
    json? values = filter[key];
    if values !is json[] {
        return ();
    }
    return from json value in values
        where value is string
        select value.toString();
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
