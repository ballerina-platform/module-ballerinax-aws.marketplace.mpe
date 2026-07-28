// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
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

import ballerina/test;

@test:Config {
    groups: ["init"]
}
isolated function testInitUsingStaticAuth() returns error? {
    if accessKeyId == "" || secretAccessKey == "" {
        return;
    }
    ConnectionConfig connectionConfig = {
        region: awsRegion,
        auth: staticAuth
    };
    Client mpe = check new (connectionConfig);
    check mpe->close();
}

@test:Config {
    enable: false,
    groups: ["init"]
}
isolated function testInitUsingProfileAuth() returns error? {
    ConnectionConfig connectionConfig = {
        region: awsRegion,
        auth: profileAuth
    };
    Client mpe = check new (connectionConfig);
    check mpe->close();
}

@test:Config {
    groups: ["init"]
}
isolated function testInitUsingRegionString() returns error? {
    if accessKeyId == "" || secretAccessKey == "" {
        return;
    }
    ConnectionConfig connectionConfig = {
        region: "us-east-1",
        auth: staticAuth
    };
    Client mpe = check new (connectionConfig);
    check mpe->close();
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlements() returns error? {
    if !liveTestsEnabled || testProductCode == "" {
        return;
    }
    EntitlementsResponse response = check mpeClient->getEntitlements(productCode = testProductCode);
    // Every returned entitlement must belong to the requested product.
    foreach Entitlement entitlement in response.entitlements {
        test:assertEquals(entitlement.productCode, testProductCode);
    }
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithFilter() returns error? {
    if !liveTestsEnabled || testProductCode == "" {
        return;
    }
    EntitlementsResponse response = check mpeClient->getEntitlements(
        productCode = testProductCode,
        filter = {dimension: ["default"]},
        maxResults = 10
    );
    // The filtered results must not exceed the requested page size.
    test:assertTrue(response.entitlements.length() <= 10);
}

@test:Config {
    groups: ["getEntitlements"]
}
function testGetEntitlementsWithInvalidProductCode() returns error? {
    if !liveTestsEnabled {
        return;
    }
    EntitlementsResponse|Error response = mpeClient->getEntitlements(productCode = "invalid-product-code");
    test:assertTrue(response is Error);
}
