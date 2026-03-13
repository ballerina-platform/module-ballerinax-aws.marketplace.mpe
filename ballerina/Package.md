## Overview

[AWS Marketplace Entitlement Service](https://docs.aws.amazon.com/marketplace/latest/userguide/entitlement.html) is a service that allows AWS Marketplace sellers to determine the entitlements of customers who have subscribed to their products.

The AWS Marketplace Entitlement Service connector offers APIs to interact with the service, enabling developers to retrieve entitlement data for a product programmatically.

### Key Features

- Determine entitlements of customers who have subscribed to products
- Programmatic retrieval of entitlement data

## Setup guide
Before using this connector in your Ballerina application, complete the following:
1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
2. [Obtain tokens](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## Quickstart

To use the `aws.marketplace.mpe` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import the module

Import the `ballerinax/aws.marketplace.mpe` module into your Ballerina project.

```ballerina
import ballerinax/aws.marketplace.mpe;
```

### Step 2: Instantiate a new connector

Create a new `mpe:Client` by providing the access key ID, secret access key, and the region.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

mpe:Client mpe = check new(region = mpe:US_EAST_1, auth = {
    accessKeyId,
    secretAccessKey
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

```ballerina
mpe:EntitlementsResponse response = check mpe->getEntitlements(productCode = "<aws-product-code>");
```

### Step 4: Run the Ballerina application

Use the following command to compile and run the Ballerina program.

```bash
bal run
```