# Provision AWS resources

After installing the AWS CLI. Configure it to use your credentials.

```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: <region>
Default output format [None]: json
```

This enables Terraform access to the configuration file and performs operations on your behalf with these security credentials.

After you've done this, initalize Terraform, which will download the provider and initialize it with the values provided in the `terraform.tfvars` file.

```shell
$ terraform init
```
Then, provision your EKS cluster by running `terraform apply`. This will 
take approximately 10 minutes.

```shell
$ terraform apply
```

## Currently the code provisions 
- MSK ( Managed Streaming for Apache Kafka ) 
