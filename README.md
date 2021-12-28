# DevOps Engineer Test

The purpose of this exercise is to test and know the level of knowledge of:
- Jenkins declarative pipelines
- Terraform
- AWS
- Python

Take a deep breath, follow the instructions, be creative, but concise, and have fun.

## Main Requisites of the test

This exercise is about to deploy a new stack of an application called "test-app" on an already created AWS account (which you don't have access, but you must work as it is exists).

This project presents:

- A jenkinsfile with "somewhat" valid structure
- A terraform file with "somewhat" valid structure
- A python file scaffold 

The idea of this tests is have a Jenkinsfile to check that the infrastructure is up-to-date on AWS regarding the terraform file, and after the checks it should send an SSM command to the EC2 instances to execute "/usr/local/bin/testapp-autoupdater" command.

Take in mind:

- There are three regions where the application needs to be deployed: us-east-1, us-west-2, and eu-west-1
- There are no AWS credentials in Jenkins, the jenkins pipeline can be executed on the agents AG-USE1, AG-USW2 and AG-EUW1 which are already configured to have IAM role to execute everything on them.  
- Both jenkinsfiles and terraform files should be "fixed" according to your experience/judgement, taking in mind:
    - Security
    - Reusability of the code
    - Dynamic resourcing (for example, getting data from the provider)
    - Feel free to improve as much as you want.
- The application stack should have:
    - An elastic load balancer.
    - An autoscaling group of minimum 3 instances and maximum 6 instances.
    - The client told us that sometimes the application needs a lot of CPU and bandwith.
    - The user data needs to download the file "https://server.com/testapp-autoupdater" to the /usr/local/bin folder
        - The credentials for the download are: user:tUkArsHqQX4A7Hk7
    - The port 80 and 443 open to incoming traffic.

## Extra exercises

Do this exercises if you have time to spare and you want to polish a lot more this exercise.

1) The client says that executing the Jenkins Pipeline every time that we want to update the application is very costly. They ask if the execution of the autoupdater through SSM could be done using a lambda function instead of inside the jenkinsfile. That way, going to the AWS console and executing the lambda function will let they to execute the autoupdater whenever they want.

2) The client asked for a deployment of an MySQL RDS because they want to set up a new backoffice with metrics inside the same AMI. The RDS should not be accessible from internet, but accessible from the EC2 machines. Keep in mind that the application needs to be reachable through port 80 and 443 only.
