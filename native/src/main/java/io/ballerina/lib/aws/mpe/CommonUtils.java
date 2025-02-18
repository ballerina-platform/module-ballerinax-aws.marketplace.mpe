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

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.time.nativeimpl.Utc;
import software.amazon.awssdk.awscore.exception.AwsErrorDetails;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.services.marketplaceentitlement.model.Entitlement;
import software.amazon.awssdk.services.marketplaceentitlement.model.EntitlementValue;
import software.amazon.awssdk.services.marketplaceentitlement.model.GetEntitlementFilterName;
import software.amazon.awssdk.services.marketplaceentitlement.model.GetEntitlementsRequest;
import software.amazon.awssdk.services.marketplaceentitlement.model.GetEntitlementsResponse;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * {@code CommonUtils} contains the common utility functions for the Ballerina AWS MPE connector.
 */
public final class CommonUtils {
    private static final RecordType ENTITLEMENT_REC_TYPE = TypeCreator.createRecordType(
            Constants.MPE_ENTITLEMENT, ModuleUtils.getModule(), SymbolFlags.PUBLIC, true, 0);
    private static final ArrayType ENTITLEMENT_ARR_TYPE = TypeCreator.createArrayType(ENTITLEMENT_REC_TYPE);
    private static final TupleType BUTC_TYPE = TypeCreator.createTupleType(
            Constants.BTIME_UTC, new Module(Constants.BTIME_ORG_NAME, Constants.BTIME_PKG_NAME),
            0, false, true);

    private CommonUtils() {
    }

    @SuppressWarnings("unchecked")
    public static GetEntitlementsRequest getNativeRequest(BMap<BString, Object> request) {
        String productCode = request.getStringValue(Constants.MPE_REQUEST_PRODUCT_CODE).getValue();
        GetEntitlementsRequest.Builder requestBuilder = GetEntitlementsRequest.builder().productCode(productCode);
        if (request.containsKey(Constants.MPE_REQUEST_MAX_RESULTS)) {
            int maxResults = request.getIntValue(Constants.MPE_REQUEST_MAX_RESULTS).intValue();
            requestBuilder = requestBuilder.maxResults(maxResults);
        }
        if (request.containsKey(Constants.MPE_REQUEST_NEXT_TOKEN)) {
            String nextToken = request.getStringValue(Constants.MPE_REQUEST_NEXT_TOKEN).getValue();
            requestBuilder = requestBuilder.nextToken(nextToken);
        }
        if (request.containsKey(Constants.MPE_REQUEST_FILTER)) {
            Map<GetEntitlementFilterName, List<String>> requestFilters = new HashMap<>();
            BMap<BString, Object> bRequestFilters = (BMap<BString, Object>) request.getMapValue(
                    Constants.MPE_REQUEST_FILTER);
            if (bRequestFilters.containsKey(Constants.MPE_REQUEST_FILTER_CUS_IDNFR)) {
                List<String> cusIdentifiers = List.of(
                        bRequestFilters.getArrayValue(Constants.MPE_REQUEST_FILTER_CUS_IDNFR).getStringArray());
                requestFilters.put(GetEntitlementFilterName.CUSTOMER_IDENTIFIER, cusIdentifiers);
            }
            if (bRequestFilters.containsKey(Constants.MPE_REQUEST_FILTER_DIMENSION)) {
                List<String> dimensions = List.of(
                        bRequestFilters.getArrayValue(Constants.MPE_REQUEST_FILTER_DIMENSION).getStringArray());
                requestFilters.put(GetEntitlementFilterName.DIMENSION, dimensions);
            }
            if (!requestFilters.isEmpty()) {
                requestBuilder = requestBuilder.filter(requestFilters);
            }
        }
        return requestBuilder.build();
    }

    public static BMap<BString, Object> getBallerinaResponse(GetEntitlementsResponse nativeResponse) {
        BMap<BString, Object> entitlementsResponse = ValueCreator.createRecordValue(
                ModuleUtils.getModule(), Constants.MPE_RESPONSE);
        String nextToken = nativeResponse.nextToken();
        if (Objects.nonNull(nextToken)) {
            entitlementsResponse.put(Constants.MPE_RESPONSE_NXT_TOKEN, StringUtils.fromString(nextToken));
        }
        BArray bEntitlements = ValueCreator.createArrayValue(ENTITLEMENT_ARR_TYPE);
        nativeResponse.entitlements().forEach(e -> {
            BMap<BString, Object> bEntitlement = convertToBEntitlement(e);
            bEntitlements.append(bEntitlement);
        });
        entitlementsResponse.put(Constants.MPE_RESPONSE_ENTITLEMENTS, bEntitlements);
        return entitlementsResponse;
    }

    private static BMap<BString, Object> convertToBEntitlement(Entitlement nativeEntitlement) {
        BMap<BString, Object> bEntitlement = ValueCreator.createRecordValue(ENTITLEMENT_REC_TYPE);
        String productCode = nativeEntitlement.productCode();
        if (Objects.nonNull(productCode)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_PRODUCT_CODE, StringUtils.fromString(productCode));
        }
        String dimension = nativeEntitlement.dimension();
        if (Objects.nonNull(dimension)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_DIMENSION, StringUtils.fromString(dimension));
        }
        String customerIdentifier = nativeEntitlement.customerIdentifier();
        if (Objects.nonNull(dimension)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_CUS_IDNFR, StringUtils.fromString(customerIdentifier));
        }
        Instant expirationDate = nativeEntitlement.expirationDate();
        if (Objects.nonNull(expirationDate)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_EXP_DATE, new Utc(expirationDate).build());
        }
        populateEntitlementValue(nativeEntitlement, bEntitlement);
        return bEntitlement;
    }

    private static void populateEntitlementValue(Entitlement nativeEntitlement, BMap<BString, Object> bEntitlement) {
        EntitlementValue nativeEntitlementValue = nativeEntitlement.value();
        Boolean entitlementBoolVal = nativeEntitlementValue.booleanValue();
        if (Objects.nonNull(entitlementBoolVal)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_VALUE, entitlementBoolVal);
            return;
        }
        Double entitlementDoubleVal = nativeEntitlementValue.doubleValue();
        if (Objects.nonNull(entitlementDoubleVal)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_VALUE, entitlementDoubleVal);
            return;
        }
        Integer entitlementIntVal = nativeEntitlementValue.integerValue();
        if (Objects.nonNull(entitlementIntVal)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_VALUE, entitlementIntVal.longValue());
            return;
        }
        String entitlementStrVal = nativeEntitlementValue.stringValue();
        if (Objects.nonNull(entitlementStrVal)) {
            bEntitlement.put(Constants.MPE_ENTITLEMENT_VALUE, StringUtils.fromString(entitlementStrVal));
        }
    }

    public static BError createError(String message, Throwable exception) {
        BError cause = ErrorCreator.createError(exception);
        BMap<BString, Object> errorDetails = ValueCreator.createRecordValue(
                ModuleUtils.getModule(), Constants.MPE_ERROR_DETAILS);
        if (exception instanceof AwsServiceException awsSvcExp && Objects.nonNull(awsSvcExp.awsErrorDetails())) {
            AwsErrorDetails awsErrorDetails = awsSvcExp.awsErrorDetails();
            if (Objects.nonNull(awsErrorDetails.sdkHttpResponse())) {
                errorDetails.put(
                        Constants.MPE_ERROR_DETAILS_HTTP_STATUS_CODE, awsErrorDetails.sdkHttpResponse().statusCode());
                awsErrorDetails.sdkHttpResponse().statusText().ifPresent(httpStatusTxt -> errorDetails.put(
                        Constants.MPE_ERROR_DETAILS_HTTP_STATUS_TXT, StringUtils.fromString(httpStatusTxt)));
            }
            errorDetails.put(
                    Constants.MPE_ERROR_DETAILS_ERR_CODE, StringUtils.fromString(awsErrorDetails.errorCode()));
            errorDetails.put(
                    Constants.MPE_ERROR_DETAILS_ERR_MSG, StringUtils.fromString(awsErrorDetails.errorMessage()));
        }
        return ErrorCreator.createError(
                ModuleUtils.getModule(), Constants.MPE_ERROR, StringUtils.fromString(message), cause, errorDetails);
    }
}
