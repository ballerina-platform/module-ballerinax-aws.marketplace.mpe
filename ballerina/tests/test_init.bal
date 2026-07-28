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

final string authType = os:getEnv("BALLERINA_AWS_TEST_AUTH_TYPE");
final string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");
final string profileName = os:getEnv("BALLERINA_AWS_TEST_PROFILE_NAME");
final string credentialsFilePath = os:getEnv("BALLERINA_AWS_TEST_CREDENTIALS_FILE");

// The AWS Marketplace product code of a subscribed product used by the live tests.
final string testProductCode = os:getEnv("BALLERINA_AWS_MPE_TEST_PRODUCT_CODE");

final readonly & aws:Region awsRegion = aws:US_EAST_1;

final readonly & auth:StaticAuthConfig staticAuth = {
    accessKeyId,
    secretAccessKey
};

final readonly & auth:ProfileAuthConfig profileAuth = {
    profileName,
    credentialsFilePath
};

// `true` when live credentials are configured; live tests are skipped otherwise.
final boolean liveTestsEnabled = authType == "default" || authType == "profile"
    || (accessKeyId != "" && secretAccessKey != "");

final Client mpeClient = check initClient();

isolated function initClient() returns Client|error {
    if authType == "default" {
        return new ({
            region: awsRegion,
            auth: auth:DEFAULT_CREDENTIALS
        });
    } else if authType == "profile" {
        return new ({
            region: awsRegion,
            auth: profileAuth
        });
    } else if accessKeyId != "" && secretAccessKey != "" {
        return new ({
            region: awsRegion,
            auth: staticAuth
        });
    }
    return test:mock(Client);
}
