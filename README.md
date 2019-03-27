# AWS automation 101

This are a set of basic instruction to touch a few cloud automation steps on AWS. In this workshops we will use the AWS CLI and Terraform.

## Automation
As you have experienced in the AWS 101 exercises it is quite cumbersome to create all the resources manually, keep track of what you have created. And it is even more hard to repeat your steps over time. This are just a few reason why normally those steps are automated.

For cloud automation you can choose from a variety of tools. The most basic option you have is to use the AWS CLI, a command line interface tool to manage AWS. More advances tools are for example CloudFormation and Terraform. CloudFormation is dedicated to AWS and provided via AWS. Terraform is an infrasctrure language to automate your task but not bounded to AWS only. You can use Terraform for several automation task. Such as automate your cloud (AWS, Google, Azure, ...), create a GIT repo, or manage DNS. And much more.

For now we only will have a look on the AWS ClI and Terraform.

## Setup
For this lab we use AWS Cloud9 execution of the automation task. This avoid installation of tools locally. And any other potential setup issue.

1. Go to [Cloud9](https://eu-west-1.console.aws.amazon.com/cloud9).
2. Choose `Create environment`
3. Provide a name for the environment, use your own name. And hit next
4. Environment type, default
5. Instance type, choose `large` for a better performance.
6. Other defaults should be fine. Click Next.
7. Choose create Environment
8. After a few minutes you environment will be live.

You have now a full development environment running in the Cloud. This environment is also an EC2 instance. The environment is created via CloudFormation.

1. The environment comes with pre installed tools such as the AWS CLI and GIT.
2. Clone the repo that contains a few automation scripts.
3. `git clone --recurse-submodules https://github.com/npalm/aws-automation-101.git`
4. Your are all set to start your first automations.

## AWS ClI
The [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/reference) is a unified tool to manage your AWS services.

Some basics
- Get some help, go to the terminal in cloud9, hint you can enlarge the window.
- Type `aws help` to see what you can do
- Show your EC2 instances `aws ec2 describe-instances`
- Do you have anything running that should be already terminated? Please terminate your non used instances.

Time to create an instance. Let's create a similar instances as in the EC2 instances. We create a AWS instance on which we run a simple web app. The web app will be installed via the `user_data.sh`. To access the instance via http we open port 80 via an security group.

To create a security group we use the command `aws ec2 create-security-group`. Have a look at the docs, `aws ec2 create-security-group help` To create the security group use the following Command
```
aws ec2 create-security-group --group-name <YOUR_NAME>-sg --description "<YOUR_NAME> Security Group 101"
```
Make a note of the returned security group id. Next create an rule top open incoming traffic via port 80/
```
aws ec2 authorize-security-group-ingress --group-id <SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
```

Finally we create the instance.
```
aws ec2 run-instances --image-id=ami-25488752 --count 1 --instance-type t2.micro  --security-group-ids <SECURITY_GROUP_ID> --user-data file://terraform/template/user_data.sh
```

Make a note of the instance id. Your server will be live in a few minutes. Lookup the public IP address and check your web app.

Time to clean up, first remove the instance.
```
aws ec2 terminate-instances --instance-ids <INSTANCE_ID>            
```
And the security group.
```
aws ec2 delete-security-group --group-id <SECURITY_GROUP_ID>
```
