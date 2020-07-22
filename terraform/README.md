## Infrastructure Layout
![CMS infrastructure](https://blog.hossanrose.com/cm_infra.png)

## Considerations
* High Availabilty/Fault tolerance
	* Using Application Loadbalancer across AZ's and Instances spread across AZ's
	* Uing RDS Mysql MultiAZ
* Scalability
	* Can be scaled by changing a variable
	* Shared storage in place to keep uploads across instances in sync
	* Autoscaling can be easily integrated
* Security
	* All assets are in private subnets with no public access
	* Security groups in place with restrictive opening
	* Access to Application and infrastructure only through jump box
* Modularised 
	* The code uses modules for terraform registry and custom module for reusability
* State
	* Terraform state is keep on S3 in a remote bucket
* CMS - Wordpress
	* Used userdata to setup wordpress for demonstration purpose
	* Better alternative is to use a custom AMI 

## Running terraform

### Prerequisite
* Pem Key to access instances should be created
* S3 bucket for Terraform state backup should be created

### Switch workspace

Switch to the right workspace
```
# export AWS_PROFILE="personal"
# terraform init
# terraform workspace select dev
```

### Setting up infrastructure

On first run and whenever EC2 instances are recreated below command should be used, to bring up the instance first in a targetted way. 
You'll be prompted for RDS DB password 
```
terraform apply --var-file=dev.tfvars -target=module.ec2_cms 
```

Once the initial run is complete, the subsequent changes in infra can be performed with below command. 
You'll be prompted for RDS DB password

```
terraform apply --var-file=dev.tfvars 
```

### Removing infrastructure
```
terraform destroy 
```

## Testing strategy
* A manual check with below will give an idea on the changes that are going to be made.
```
terraform validate
terraform plan
```
* The basic rule once deployment is done is to test the end points.
	* HTTP - ALB end point for 200 response / curl can be used here
		This validates that the backend systems are all properly configured and security groups are opened properly
	* SSH  - For Bastion host SSH response / ssh -q ec2-user@bastion exit; echo $?
		This validates the connectivity to the infrastructure
* For advanced infrastructure testing a tool similar to Terratest can be used.
