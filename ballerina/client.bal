// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com).
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

import ballerina/constraint;
import ballerina/jballerina.java;

# AWS Marketplace entitlement client.
public isolated client class Client {

    # Initialize the Ballerina AWS MPE client.
    # ```ballerina
    # mpe:Client mpe = check new(region = mpe:US_EAST_1, auth = {
    #   accessKeyId: "<aws-access-key>",
    #   secretAccessKey: "<aws-secret-key>"
    # });
    # ```
    #
    # + configs - The AWS MPE client configurations
    # + return - The `mpe:Client` or an `mpe:Error` if the initialization failed
    public isolated function init(*ConnectionConfig configs) returns Error? {
        return self.externInit(configs);
    }

    isolated function externInit(ConnectionConfig configs) returns Error? =
    @java:Method {
        name: "init",
        'class: "io.ballerina.lib.aws.mpe.NativeClientAdaptor"
    } external;

    # Retrieves the entitlement values for a given product.
    # ```ballerina
    # mpe:EntitlementsResponse response = check mpe->getEntitlements(productCode = "<aws-product-code>");
    # ```
    #
    # + request - The `mpe:GetEntitlements` request with relevant details
    # + return - An `mpe:EntitlementsResponse` containing the entitlement details, 
    # or an `mpe:Error` if the request validation or the operation failed.
    remote function getEntitlements(*EntitlementsRequest request) returns EntitlementsResponse|Error {
        EntitlementsRequest|constraint:Error validated = constraint:validate(request);
        if validated is constraint:Error {
            return error Error(string `Request validation failed: ${validated.message()}`);
        }
        return self.externGetEntitlements(validated);
    }

    isolated function externGetEntitlements(EntitlementsRequest request) returns EntitlementsResponse|Error =
    @java:Method {
        name: "getEntitlements",
        'class: "io.ballerina.lib.aws.mpe.NativeClientAdaptor"
    } external;

    # Closes the AWS MPE client resources.
    # ```ballerina
    # check mpe->close();
    # ```
    # 
    # + return - A `mpe:Error` if there is an error while closing the client resources or else nil.
    remote function close() returns Error? =
    @java:Method {
        'class: "io.ballerina.lib.aws.mpe.NativeClientAdaptor"
    } external;
}
