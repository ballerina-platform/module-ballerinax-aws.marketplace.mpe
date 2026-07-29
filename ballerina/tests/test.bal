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

import ballerina/os;
import ballerina/test;
import ballerinax/aws;
import ballerinax/aws.auth;

configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";

configurable string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");
configurable string liveProductCode = os:getEnv("BALLERINA_AWS_MPE_TEST_PRODUCT_CODE");

final readonly & aws:Region awsRegion = aws:US_EAST_1;

final readonly & auth:StaticAuthConfig liveAuth = {
    accessKeyId,
    secretAccessKey
};

final readonly & auth:StaticAuthConfig mockAuth = {
    accessKeyId: MOCK_ACCESS_KEY_ID,
    secretAccessKey: MOCK_SECRET_ACCESS_KEY
};

final readonly & auth:StaticAuthConfig unexpectedAuth = {
    accessKeyId: "AKIAIOSFODNN7EXAMPLE",
    secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
};

final readonly & ConnectionConfig connectionConfig = isLiveServer
    ? {region: awsRegion, auth: liveAuth}
    : {region: awsRegion, auth: mockAuth, endpoint: {customEndpoint: mockServerUrl}};

final string testProductCode = isLiveServer ? liveProductCode : MOCK_PRODUCT_CODE;

final Client mpeClient = check new (connectionConfig);

@test:BeforeSuite
function startMockService() returns error? {
    if isLiveServer {
        return;
    }
    check mockListener.attach(mockService, "/");
    check mockListener.'start();
}

@test:AfterSuite
function stopMockService() returns error? {
    if isLiveServer {
        return;
    }
    check mpeClient->close();
    check mockListener.gracefulStop();
}

@test:Config {
    groups: ["init"]
}
isolated function testInitWithRegionEnum() returns error? {
    Client mpe = check new (connectionConfig);
    check mpe->close();
}

@test:Config {
    groups: ["init"]
}
isolated function testInitWithRegionString() returns error? {
    ConnectionConfig config = isLiveServer
        ? {region: "us-east-1", auth: liveAuth}
        : {region: "us-east-1", auth: mockAuth, endpoint: {customEndpoint: mockServerUrl}};
    Client mpe = check new (config);
    check mpe->close();
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlements() returns error? {
    EntitlementsResponse response = check mpeClient->getEntitlements(productCode = testProductCode);
    foreach Entitlement entitlement in response.entitlements {
        test:assertEquals(entitlement.productCode, testProductCode);
    }
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithFilter() returns error? {
    EntitlementsResponse response = check mpeClient->getEntitlements(
        productCode = testProductCode,
        filter = {dimension: [MOCK_DIMENSION]},
        maxResults = 10
    );
    test:assertTrue(response.entitlements.length() <= 10);
    foreach Entitlement entitlement in response.entitlements {
        test:assertEquals(entitlement.dimension, MOCK_DIMENSION);
    }
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithNonMatchingFilter() returns error? {
    EntitlementsResponse response = check mpeClient->getEntitlements(
        productCode = testProductCode,
        filter = {dimension: ["no-such-dimension"]}
    );
    test:assertEquals(response.entitlements.length(), 0);
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsTruncatesToMaxResults() returns error? {
    EntitlementsResponse response = check mpeClient->getEntitlements(
        productCode = testProductCode,
        maxResults = 10
    );
    test:assertTrue(response.entitlements.length() <= 10);
    if !isLiveServer {
        test:assertEquals(response.entitlements.length(), 10);
    }
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithUnknownProductCode() returns error? {
    EntitlementsResponse response = check mpeClient->getEntitlements(productCode = "unknown-product-code");
    test:assertEquals(response.entitlements.length(), 0);
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithUnexpectedCredentials() returns error? {
    ConnectionConfig config = isLiveServer
        ? {region: awsRegion, auth: unexpectedAuth}
        : {region: awsRegion, auth: unexpectedAuth, endpoint: {customEndpoint: mockServerUrl}};
    Client mpe = check new (config);
    EntitlementsResponse|Error response = mpe->getEntitlements(productCode = testProductCode);
    check mpe->close();
    if response !is Error {
        test:assertFail("expected a request signed with unexpected credentials to be rejected");
    }
    test:assertEquals(response.detail().httpStatusCode, 403);
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithMaxResultsOutOfRange() returns error? {
    EntitlementsResponse|Error response = mpeClient->getEntitlements(
        productCode = testProductCode,
        maxResults = 100
    );
    if response !is Error {
        test:assertFail("expected an out-of-range 'maxResults' to be rejected by the service");
    }
    aws:ErrorDetails details = response.detail();
    test:assertEquals(details.httpStatusCode, 400);
    test:assertEquals(details.errorCode, "InvalidParameterException");
    test:assertTrue(details.requestId is string, "the service error must carry a request id");
}
