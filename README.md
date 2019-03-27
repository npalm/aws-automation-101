# AWS automation 101

This are a set of basic instruction to touch a few cloud automation steps on AWS. In this workshops we will use the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference) and [Terraform](https://www.terraform.io/).

## Automation
As you have experienced in the AWS 101 exercises it is quite cumbersome to create all the resources manually, keep track of what you have created. And it is even more hard to repeat your steps over time. This are just a few reason why normally those steps are automated.

For cloud automation you can choose from a variety of tools. The most basic option you have is to use the AWS CLI, a command line interface tool to manage AWS. More advances tools are for example CloudFormation and Terraform. CloudFormation is dedicated to AWS and provided via AWS. Terraform is an infrastructure language to automate your task but not bounded to AWS only. You can use Terraform for several automation task. Such as automate your cloud (AWS, Google, Azure, ...), create a GIT repo, or manage DNS. And much more.

For now we only will have a look on the AWS ClI and Terraform.

## Setup
For this lab we use [AWS Cloud9](https://console.aws.amazon.com/cloud9) execution of the automation task. This avoid installation of tools locally. And any other potential setup issue.

1. Go to [Cloud9](https://console.aws.amazon.com/cloud9).
2. Choose `Create environment`
3. Provide a name for the environment, use your own name. And hit next
4. Environment type, default
5. Instance type, choose `large` for a better performance.
6. Other defaults should be fine. Click Next.
7. Choose create Environment
8. After a few minutes you environment will be live.

You have now a full development environment running in the Cloud. This environment is also an [EC2 instance](https://console.aws.amazon.com/ec2). The environment is created via [CloudFormation](https://console.aws.amazon.com/cloudformation).

1. The environment comes with pre installed tools such as the AWS CLI and GIT.
2. Clone this repo including submodule that contains a few automation scripts.
3. `git clone --recurse-submodules https://github.com/npalm/aws-automation-101.git`
4. Your are now ready to start your first automations.

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
aws ec2 create-security-group --group-name <YOUR_NAME>-sg \
  --description "<YOUR_NAME> Security Group 101"
```
Make a note of the returned security group id. Next create an rule to accept incoming traffic on port 80.
```
aws ec2 authorize-security-group-ingress --group-id <SECURITY_GROUP_ID \
  --protocol tcp --port 80 --cidr 0.0.0.0/0
```

Finally we create the instance.
```
aws ec2 run-instances --image-id=ami-25488752 --count 1 --instance-type \
  t2.micro  --security-group-ids <SECURITY_GROUP_ID> \
  --user-data file://terraform/template/user_data.sh
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

## Terraform
In many cased we not use the cli but choose a language that makes it a lot easier to automate the cloud. Today we have a brief look at [Terraform](https://www.terraform.io/).

We walk trough a simple demo in a few steps. Which creates the same web app as in the previous AWS CLI example.

Two import concepts in Terraform are Providers and Resources.

> A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS (e.g. AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS services (e.g. Terraform Enterprise, DNSimple, CloudFlare).

> Resources are the most important element in the Terraform language. Each resource block describes one or more infrastructure objects, such as virtual networks, compute instances, or higher-level components such as DNS records.

So for now we will not more about Terraform but just have a look at the code.

Open the [main.tf](https://github.com/npalm/tf-helloworld-demo/blob/6ccd118aefc66c43773ec1457470092332ef8b60/main.tf) in the dir `terraform`. Here you will see that there is defined a provider and two resources. Do you recognise them from the previous exercise?

Tiem to create our awesome web server. First we need to install Terraform. A script is provided to help you. Excute the script.
```
./bin/install.sh
```
As output you should see the installed Terraform version.

The first step is to initialize Terraform.
```
cd terraform
terraform init
```
Next we run a dry run, to inspect what changes Terraform will make.
```
terraform plan -out plan.out
```
Check the output, is it what you expect? Apply the changes now.
```
terraform apply "plan.out"
```
In a few minutes your web app should be live. Check your web app. Finally we clean up our resources.
```
terraform destroy --force
```


## Clean up
That is all, please ensure you have removed all your resources to avoid any unwanted costs.

Most of the resources should already be removed.
- Cloud9, delete your Cloud9 istance.
- EC2, first terminate instances, next remove security groups.
