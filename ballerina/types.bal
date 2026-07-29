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
import ballerina/time;
import ballerinax/aws;
import ballerinax/aws.auth;

# Represents the connection configuration for the AWS Marketplace Entitlement service client.
public type ConnectionConfig record {|
    # Authentication configuration: any standard credential source supported by
    # AWS — static credentials, an AWS profile, STS assume-role,
    # web identity (OIDC), IAM Identity Center (SSO), an external credential
    # process, or the default credential provider chain
    auth:AuthConfig auth;
    # AWS region: an `aws:Region` enum member or a plain region
    # string (e.g., `"us-east-1"`) for regions not yet in the enum
    aws:Region|string region;
    # Optional endpoint options: FIPS/dualstack variants, or a custom
    # endpoint override (e.g. LocalStack, VPC interface endpoints)
    aws:EndpointConfig endpoint?;
|};

# Represents the parameters used for the `GetEntitlements` operation.
public type EntitlementsRequest record {|
    # Product code is used to uniquely identify a product in AWS Marketplace
    @constraint:String {
        minLength: 1,
        maxLength: 255
    }
    string productCode;
    # A parameter which is used to filter out entitlements for a specific customer or a specific dimension
    EntitlementFilter filter?;
    # The maximum number of results to return in a single call
    int maxResults?;
    # The token for pagination to retrieve the next set of results
    @constraint:String {
        pattern: re `\S+`
    }
    string nextToken?;
|};

# Represents the filters used for `GetEntitlements` operation.
public type EntitlementFilter record {|
    # Customer identifier based filter
    @constraint:Array {
        minLength: 1
    }
    string[] customerIdentifier?;
    # Product dimension based filter
    @constraint:Array {
        minLength: 1
    }
    string[] dimension?;
|};

# Represents the results retrieved from `GetEntitlements` operation.
public type EntitlementsResponse record {|
    # The set of entitlements found through the GetEntitlements operation. 
    # If the result contains an empty set of entitlements, NextToken might still be present and should be used.
    Entitlement[] entitlements;
    # The token for pagination to retrieve the next set of results
    string nextToken?;
|};

# Represents the capacity in a product owned by the customer.
public type Entitlement record {|
    # The product code for which the given entitlement applies
    string productCode?;
    # The dimension for which the given entitlement applies
    string dimension?;
    # The customer identifier is a handle to each unique customer in an application
    string customerIdentifier?;
    # The expiration date represents the minimum date through which this entitlement is expected to remain valid
    time:Utc expirationDate?;
    # The amount of capacity that the customer is entitled to for the product
    boolean|float|int|string value?;
|};
