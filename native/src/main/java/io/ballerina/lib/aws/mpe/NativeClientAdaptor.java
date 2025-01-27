/*
 * Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com)
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.aws.mpe;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.services.marketplaceentitlement.MarketplaceEntitlementClient;
import software.amazon.awssdk.services.marketplaceentitlement.model.GetEntitlementsRequest;
import software.amazon.awssdk.services.marketplaceentitlement.model.GetEntitlementsResponse;

import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Representation of {@link software.amazon.awssdk.services.marketplaceentitlement.MarketplaceEntitlementClient} with
 * utility methods to invoke as inter-op functions.
 */
public final class NativeClientAdaptor {
    private static final String NATIVE_CLIENT = "nativeClient";
    private static final ExecutorService EXECUTOR_SERVICE = Executors.newCachedThreadPool(new AwsMpeThreadFactory());

    private NativeClientAdaptor() {
    }

    /**
     * Creates an AWS MPE native client with the provided configurations.
     *
     * @param bAwsMpeClient The Ballerina AWS MPE client object.
     * @param configurations AWS MPE client connection configurations.
     * @return A Ballerina `mpe:Error` if failed to initialize the native client with the provided configurations.
     */
    public static Object init(BObject bAwsMpeClient, BMap<BString, Object> configurations) {
        try {
            ConnectionConfig connectionConfig = new ConnectionConfig(configurations);
            AwsCredentials credentials = getCredentials(connectionConfig);
            AwsCredentialsProvider credentialsProvider = StaticCredentialsProvider.create(credentials);
            MarketplaceEntitlementClient nativeClient = MarketplaceEntitlementClient.builder()
                    .credentialsProvider(credentialsProvider)
                    .region(connectionConfig.region()).build();
            bAwsMpeClient.addNativeData(NATIVE_CLIENT, nativeClient);
        } catch (Exception e) {
            String errorMsg = String.format("Error occurred while initializing the marketplace entitlement client: %s",
                    e.getMessage());
            return CommonUtils.createError(errorMsg, e);
        }
        return null;
    }

    private static AwsCredentials getCredentials(ConnectionConfig connectionConfig) {
        if (Objects.nonNull(connectionConfig.sessionToken())) {
            return AwsSessionCredentials.create(connectionConfig.accessKeyId(), connectionConfig.secretAccessKey(),
                    connectionConfig.sessionToken());
        } else {
            return AwsBasicCredentials.create(connectionConfig.accessKeyId(), connectionConfig.secretAccessKey());
        }
    }

    /**
     * Retrieves the entitlement values for a given product.
     *
     * @param env The Ballerina runtime environment.
     * @param bAwsMpeClient The Ballerina AWS MPE client object.
     * @param request The Ballerina AWS MPE `GetEntitlement` request.
     * @return A Ballerina `mpe:Error` if there was an error while processing the request or else the AWS MPE response.
     */
    public static Object getEntitlements(Environment env, BObject bAwsMpeClient, BMap<BString, Object> request) {
        MarketplaceEntitlementClient nativeClient = (MarketplaceEntitlementClient) bAwsMpeClient
                .getNativeData(NATIVE_CLIENT);
        GetEntitlementsRequest entitlementsRequest = CommonUtils.getNativeRequest(request);
        return env.yieldAndRun(() -> {
            try {
                GetEntitlementsResponse entitlementsResponse = nativeClient.getEntitlements(entitlementsRequest);
                BMap<BString, Object> bResponse = CommonUtils.getBallerinaResponse(entitlementsResponse);
                return bResponse;
            } catch (Exception e) {
                String errorMsg = String.format("Error occurred while retrieving entitlements for the product: %s",
                        e.getMessage());
                BError bError = CommonUtils.createError(errorMsg, e);
                return bError;
            }
        });
    }

    /**
     * Closes the AWS MPE client native resources.
     *
     * @param bAwsMpeClient The Ballerina AWS MPE client object.
     * @return A Ballerina `mpe:Error` if failed to close the underlying resources.
     */
    public static Object close(BObject bAwsMpeClient) {
        MarketplaceEntitlementClient nativeClient = (MarketplaceEntitlementClient) bAwsMpeClient
                .getNativeData(NATIVE_CLIENT);
        try {
            nativeClient.close();
        } catch (Exception e) {
            String errorMsg = String.format("Error occurred while closing the marketplace entitlement client: %s",
                    e.getMessage());
            return CommonUtils.createError(errorMsg, e);
        }
        return null;
    }
}
