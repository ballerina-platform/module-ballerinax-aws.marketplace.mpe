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
import ballerina/os;

final string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");

final Client awsMarketplaceMpe = check initClient();

isolated function initClient() returns Client|error {
    boolean enableTests = accessKeyId !is "" && secretAccessKey !is "";
    if enableTests {
        return new({
            region: US_EAST_1,
            auth: {accessKeyId, secretAccessKey}
        });
    }
    return test:mock(Client);
}

@test:Config
isolated function testGetEntitlements() returns error? {
    EntitlementsResponse response = check awsMarketplaceMpe->getEntitlements(productCode = "P1234");
    test:assertTrue(response.entitlements.length() > 0, "Could not retrieve entitlement response for products");
}
