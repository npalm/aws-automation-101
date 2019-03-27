# AWS automation 101

These are a set of basic instructions to show a few cloud automation steps on AWS. In this workshops we will use the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference) and [Terraform](https://www.terraform.io/).

## Automation
As you have experienced in the AWS 101 exercises it is quite cumbersome to create all the resources manually, keep track of what you have created, and it is even harder to repeat your steps over time. These are just a few reasons why we normally automate those steps.

For cloud automation you can choose from a variety of tools. The most basic option you have is to use the AWS CLI, a command line interface tool to manage AWS. There are more advanced tools like CloudFormation and Terraform. CloudFormation is an AWS specific service created by AWS themselves. Terraform is a declerative infrastructure configuration language to manage your infrastructure on many cloud providers, including AWS, Azure, Google Cloud, etc. You can use Terraform for several automation tasks like managing infrastructure, create a GIT repo, manage DNS, and much more.

Today we'll use the AWS ClI and Terraform.

## Setup
For this lab we'll use [AWS Cloud9](https://console.aws.amazon.com/cloud9) to execute the automation task. This avoids having to install tools locally and other potential setup issues.

1. Go to [Cloud9](https://console.aws.amazon.com/cloud9).
2. Choose `Create environment`
3. Provide a name for the environment, use your own name. And hit next
4. Environment type, default
5. Instance type, choose `large` for a better performance.
6. Other defaults should be fine. Click Next.
7. Choose create Environment
8. After a few minutes you environment will be live.

You now have a full development environment running in the Cloud. This environment is also an [EC2 instance](https://console.aws.amazon.com/ec2) and created via [CloudFormation](https://console.aws.amazon.com/cloudformation). (Many AWS services use cloudformation "under the hood" to provision resources and you can actually look at them in the [CloudFormation](https://console.aws.amazon.com/cloudformation) console.)

1. The environment comes with pre installed tools such as the AWS CLI and GIT.
2. Clone this repo including the submodule that contains a few automation scripts.
3. `git clone --recurse-submodules https://github.com/npalm/aws-automation-101.git`
4. Now you're ready to start your first automations.

## AWS ClI
The [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/reference) is a unified tool to manage your AWS services.

Some basics
- To get some help, go to the terminal in cloud9, hint: you can enlarge the window.
- Type `aws help` to see what you can do
- Show your EC2 instances `aws ec2 describe-instances`
- Do you see anything running that should have been terminated already? Please terminate your unused instances.

Time to create an instance. Let's create a similar instance as in the EC2 hands-on. We'll create an AWS instance on which we run a simple web app. The web app will be installed via the `user_data.sh`. To access the instance via http we'll open port 80 via an security group.

The command `aws ec2 create-security-group` is used to create a security group. You can get documentation on how to use this command by entering `aws ec2 create-security-group help`. To create our new security group enter the following command:
```
aws ec2 create-security-group --group-name <YOUR_NAME>-sg \
  --description "<YOUR_NAME> Security Group 101"
```
Make a note of the returned security group id. The next step is creating a rule to accept incoming traffic on port 80.
```
aws ec2 authorize-security-group-ingress --group-id <SECURITY_GROUP_ID> \
  --protocol tcp --port 80 --cidr 0.0.0.0/0
```

Finally we are ready to create the instance:
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
In many cases we don't use the cli but choose a declarative language that makes it a lot easier to automate the cloud. Today we'll take a brief look at [Terraform](https://www.terraform.io/).

We'll walk trough a simple demo that, in just a few steps, creates the same web app as in the previous AWS CLI example.

Two important concepts in Terraform are Providers and Resources.

> A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS (e.g. AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS services (e.g. Terraform Enterprise, DNSimple, CloudFlare).

> Resources are the most important element in the Terraform language. Each resource block describes one or more infrastructure objects, such as virtual networks, compute instances, or higher-level components such as DNS records.

We won't go too deep into Terraform for now, but have a look at the code.

Open the [main.tf](https://github.com/npalm/tf-helloworld-demo/blob/6ccd118aefc66c43773ec1457470092332ef8b60/main.tf) in the dir `terraform`. You'll see we have defined a provider and two resources. Do you recognise them from the previous exercise?

Time to create our awesome web server! First we will need to install Terraform using a script we provided to help you a bit. Excute the script.
```
./bin/install.sh
```
The output should show the installed Terraform version.

The first step is to initialize Terraform.
```
cd terraform
terraform init
```
Next we'll do a dry run to review what changes Terraform will make.
```
terraform plan -out plan.out
```
Check the output. Is it what you expected? If so, apply the changes.
```
terraform apply "plan.out"
```
In a few minutes your web app should be live. Check whether your web app is running and clean up our resources.
```
terraform destroy --force
```


## Clean up
That is all, please ensure you have removed all your resources to avoid any unwanted costs.

Most of the resources should already be removed.
- Cloud9, delete your Cloud9 istance.
- EC2, first terminate instances, next remove security groups.
