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
	* The code uses modules for terraform registry and custom modules for reusability
* State
	* Terraform state is keep in S3 in a remote bucket
* CMS - Wordpress
	* Used userdata to setup wordpress for demonstration purpose
	* Better alternative custom AMI 

## Running terraform

### Prerequisite
* Pem Key to access instances should be created
* S3 state backup bucket should be created

### Switch workspace

Switch to the right workspace
```
# export AWS_PROFILE="personal"
# terraform init
# terraform workspace select dev
```

### First run

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
