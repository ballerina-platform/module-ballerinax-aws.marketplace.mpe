# Ballerina AWS Marketplace Entitlement connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/ci.yml)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.marketplace.mpe.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.marketplace.mpe/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/aws.marketplace.mpe.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Faws.marketplace.mpe)

[AWS Marketplace Entitlement Service](https://docs.aws.amazon.com/marketplace/latest/userguide/entitlement.html) is a
service that allows AWS Marketplace sellers to determine the entitlements of customers who have subscribed to their
products.

The `ballerinax/aws.marketplace.mpe` package offers APIs to interact with the AWS Marketplace Entitlement Service,
enabling developers to retrieve entitlement data for a product programmatically.

## Setup guide
Before using this connector in your Ballerina application, complete the following:
1. Create an [AWS account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start)
2. [Obtain tokens](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## Quickstart

To use the `aws.marketplace.mpe` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import the module

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

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`aws.marketplace.mpe` package](https://central.ballerina.io/ballerinax/aws.marketplace.mpe/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.