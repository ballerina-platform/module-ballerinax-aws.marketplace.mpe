# Retrieve entitlements with AWS Marketplace Entitlement Service

This example demonstrates how to retrieve customer entitlements for an AWS Marketplace product using the Ballerina AWS Marketplace Entitlement (MPE) connector. It showcases:

- Instantiating the `mpe:Client` with static AWS credentials
- Retrieving all entitlements for a product
- Iterating over the returned entitlements

## Prerequisites

- An AWS account with an AWS Marketplace product
- AWS Access Key ID and Secret Access Key
- Ballerina Swan Lake 2201.12.0 or later

## Configuration

Update the `Config.toml` with your AWS credentials and product code.

```toml
# AWS credentials
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"

# AWS Marketplace product code
productCode = "<YOUR_PRODUCT_CODE>"
```

## Run the example

1. Ensure you have updated the `Config.toml` with your AWS credentials and product code.
2. Run the example.

```bash
bal run
```

## References

- [Ballerina AWS Marketplace Entitlement Module](https://central.ballerina.io/ballerinax/aws.marketplace.mpe)
