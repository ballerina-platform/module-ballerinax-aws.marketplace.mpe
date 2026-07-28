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

Import the `ballerinax/aws` and `ballerinax/aws.marketplace.mpe` modules into your Ballerina project.

```ballerina
import ballerinax/aws;
import ballerinax/aws.marketplace.mpe;
```

### Step 2: Instantiate a new connector

Create a new `mpe:Client` by providing the region and authentication configurations.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

mpe:Client mpe = check new ({
    region: aws:US_EAST_1,
    auth: {
        accessKeyId,
        secretAccessKey
    }
});
```

#### Alternative authentication methods

##### Profile-based authentication

You can use AWS profile-based authentication as an alternative to static credentials.

```ballerina
mpe:Client sqsClient = check new ({
   region: aws:US_EAST_1,
   auth: {
      profileName: "myAwsProfile",
      credentialsFilePath: "/path/to/custom/credentials"
   }
});
```

##### Default credential provider chain

The standard default credential provider chain, trying each of the following in order and taking the first source that yields credentials:

1. Environment variables (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, and `AWS_WEB_IDENTITY_TOKEN_FILE` if set)
2. The shared config/credentials file's active profile (`AWS_PROFILE`, or `default` if unset) — which may itself resolve via SSO
, an external process, or a chained `AssumeRole` call, depending on that profile's configuration
3. Container credentials (ECS/EKS)
4. EC2 instance profile (IMDS)

```ballerina
mpe:Client sqsClient = check new ({
   region: aws:US_EAST_1,
   auth: auth:DEFAULT_CREDENTIALS
});
```

> **Note:** Ensure your AWS credentials file follows the standard format.
>
> ```ini
> [default]
> aws_access_key_id = YOUR_ACCESS_KEY_ID
> aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
>
> [myAwsProfile]
> aws_access_key_id = ANOTHER_ACCESS_KEY_ID
> aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY
> ```


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

## Examples

The `ballerinax/aws.marketplace.mpe` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/tree/main/examples):

1. [**Retrieve entitlements**](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/tree/main/examples/retrieve-entitlements) – Retrieves the entitlements of customers who have subscribed to a product, and filters them by customer identifier and dimension.
