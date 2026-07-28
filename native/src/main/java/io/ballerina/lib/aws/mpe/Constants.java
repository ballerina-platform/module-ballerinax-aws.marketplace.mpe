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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Represents the constants related to Ballerina MPE connector.
 */
public interface Constants {
    // Constants related to MPE `EntitlementsRequest`
    BString MPE_REQUEST_PRODUCT_CODE = StringUtils.fromString("productCode");
    BString MPE_REQUEST_MAX_RESULTS = StringUtils.fromString("maxResults");
    BString MPE_REQUEST_NEXT_TOKEN = StringUtils.fromString("nextToken");
    BString MPE_REQUEST_FILTER = StringUtils.fromString("filter");
    BString MPE_REQUEST_FILTER_CUS_IDNFR = StringUtils.fromString("customerIdentifier");
    BString MPE_REQUEST_FILTER_DIMENSION = StringUtils.fromString("dimension");

    // Constants related to MPE `EntitlementsResponse`
    String MPE_RESPONSE = "EntitlementsResponse";
    BString MPE_RESPONSE_NXT_TOKEN = StringUtils.fromString("nextToken");
    BString MPE_RESPONSE_ENTITLEMENTS = StringUtils.fromString("entitlements");

    // Constants related to MPE `Entitlement`
    String MPE_ENTITLEMENT = "Entitlement";
    BString MPE_ENTITLEMENT_PRODUCT_CODE = StringUtils.fromString("productCode");
    BString MPE_ENTITLEMENT_DIMENSION = StringUtils.fromString("dimension");
    BString MPE_ENTITLEMENT_CUS_IDNFR = StringUtils.fromString("customerIdentifier");
    BString MPE_ENTITLEMENT_EXP_DATE = StringUtils.fromString("expirationDate");
    BString MPE_ENTITLEMENT_VALUE = StringUtils.fromString("value");

    // Ballerina time module related constants
    String BTIME_ORG_NAME = "ballerina";
    String BTIME_PKG_NAME = "time";
    String BTIME_UTC = "Utc";

    // Constants related to MPE Error
    String MPE_ERROR = "Error";
    String MPE_ERROR_DETAILS = "ErrorDetails";
    BString MPE_ERROR_DETAILS_HTTP_STATUS_CODE = StringUtils.fromString("httpStatusCode");
    BString MPE_ERROR_DETAILS_HTTP_STATUS_TXT = StringUtils.fromString("httpStatusText");
    BString MPE_ERROR_DETAILS_ERR_CODE = StringUtils.fromString("errorCode");
    BString MPE_ERROR_DETAILS_ERR_MSG = StringUtils.fromString("errorMessage");
    BString MPE_ERROR_DETAILS_REQUEST_ID = StringUtils.fromString("requestId");
}
