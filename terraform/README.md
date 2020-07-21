#Infrastructure


# Running terraform

## Switch workspace

Switch to the right workspace
```
# export AWS_PROFILE="personal"
# terraform init
# terraform workspace select dev
```

## First run

On first run and whenever EC2 instances are changed below commands should be used. 
```
terraform apply --var-file=dev.tfvars -target=module.ec2_cms 
terraform apply --var-file=dev.tfvars 
```

## Subsequent runs

Once the initial run is complete, the subsequent changes in infra can be performed with below command
```
# terraform plan --var-file=dev.tfvars
```

## Considerations

* Using userdata to setup wordpress for demonstration purpose
	* Best alternative is to use a custom wordpress AMI
	* Remote exec/Ansible can be used to setup the CMS
* Key should be created
* S3 state backup folder should be created and configured  
