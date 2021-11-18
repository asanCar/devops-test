# Some notes about my thoughts

## Terraform

- As Jenkins Agents nodes are configured with the IAM Role required to operate to an AWS Account, no credentials configuration is needed in Terraform.
- I was thinking to split Terraform root module in smaller ones to group resources by the same context, but trying to accomplish a MVP solution I decided to stay with the root module and take that into account for a future refactor.
- We asume that an s3 has been created previously in each AWS region (us-east-1, us-west-2, eu-west-1).

### Auto Scaling Group

- As we don't have enough information to get the AMI Data Resource from the provider, we asume that the Terraform user has to provide an AMI id in case it has to be changed.
- The EC2 type has been changed to a t3.medium instead of a t2.medium. Besides both machine types have a CPU credits system that is capable to respond to CPU bursts, the T3 type has also a system to manage Networking bursts.
- For security concerns EC2 instances should be deployed without a public IP address and only accessible through the ELB or from inside the same VPC. With this configuration a NAT Gateway or custom VPC endpoints would be necessary to allow EC2 instances to access Internet and SSM endpoints. To keep this exercise simple, we decided to configure public IP addresses for EC2 instances.
- To avoid CPU throttling we have configured T3 instances to use the "Unlimited" credits tier.
- We assume that the provided AMI has preinstalled the SSM Agent.

### Security Group

- The security groups has been configured to allow incoming TCP traffic to 80 and 443 ports. It also allows all TCP egress traffic, to make 'testapp-autoupdater' script available to all EC2 instances.
- It is supposed that a non default VPC is created and the user will provide its ID. A default ID is provided for simplicity.

### Elastic Load Balancer

- Since the Application needs to accept HTTP traffic through 80 and 443 ports, we decided to use an Application Load Balancer.
- As we don't know who will consume the Application deployed (internal or external users), in terms of simplicity, each ELB has been configured to be exposed to Internet. Because of this, we also don't know which multi region architecture needs to be configured (failover regions or active-active), so we suppose that a Network Team will be responsible to configure Route 53 rules and other services to make available the Application (for example configuring latency based routing).
- As we don't know what DNS entries will be created, we decided to not create a Certificate and ask the user to specify one as an input variable (currently the Certificate ARN). For sake of simplicity we have set a fake value as default.

## Jenkins

- Credentials used to download the `https://server.com/testapp-autoupdater` script are supposed to be stored in the Jenkins credentials Store.
- We asume that the Jenkins agents have Terraform and Python installed.
- We have decided to configure Jenkins to run region pipelines in sequence instead running them in parallel. While running region pipelines in parallel we reduce the overall duration, we decided to run pipelines in sequence trying to simulate a "Rolling Update". That way if something goes wrong with one deployment (and is detected as an error by the pipeline), the rest of deployments won't proceed and only one region is affected. To make pipelines fail, maybe some tests should be added in the future.
