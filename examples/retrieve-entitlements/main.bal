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

import ballerina/io;
import ballerinax/aws;
import ballerinax/aws.marketplace.mpe;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string productCode = ?;

public function main() returns error? {
    mpe:Client mpe = check new ({
        region: aws:US_EAST_1,
        auth: {
            accessKeyId,
            secretAccessKey
        }
    });

    // Retrieve all entitlements for the given product.
    mpe:EntitlementsResponse response = check mpe->getEntitlements(productCode = productCode);
    io:println(string `Found ${response.entitlements.length()} entitlement(s):`);
    foreach mpe:Entitlement entitlement in response.entitlements {
        io:println(string `- customer: ${entitlement.customerIdentifier ?: "N/A"}, ` +
            string `dimension: ${entitlement.dimension ?: "N/A"}, value: ${entitlement.value.toString()}`);
    }

    check mpe->close();
}
