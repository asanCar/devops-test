// pipeline {
//     stages {
//         stage('Terraform test') {
//             environment {
//                 AWS_DEFAULT_REGION="us-east-1"
//                 TF_VAR_aws_region="us-east-1"
//                 TF_VAR_autoupdater_server_username=credentials('autoupdater_server_username')
//                 TF_VAR_autoupdater_server_pass=credentials('autoupdater_server_pass')
//             }
//             steps {
//                 sh "AWS_DEFAULT_REGION=us-east-1 cd src && terraform init && terraform plan"
//             }
//         }
//         stage('Terraform Apply us-east-1') {
//             environment {
//                 AWS_DEFAULT_REGION="us-east-1"
//             }
//             steps {
//                 sh "cd src && terraform init && terraform apply --auto-approve"
//             }
//         }
//         stage('Terraform Apply eu-west-1') {
//             environment {
//                 AWS_DEFAULT_REGION="us-east-1"
//             }
//             steps {
//                 sh "AWS_DEFAULT_REGION=eu-west-1 cd src && terraform init && terraform apply --auto-approve"
//                 autoscaler_name = sh(returnStdout: true, script: "terraform output load_balancer_dns_name").trim()
//             }
//         }
//     }
// }
def agentsRegionsList = [
    "AG-USE1": "us-east-1",
    "AG-USW2": "us-west-2",
    "AG-EUW1": "eu-west-1",
    ]

def createRegionPipeline(agentName, region) {
    return{
        node(agentName) {
            stage("Check infraestructure") {
                echo "Hello ${region}"
            }
        }
    }
}

// Run a pipeline for each region in parallel
def pipelines = [:]
echo mapToList(agentsRegionsList).toString()
for (elem in mapToList(agentsRegionsList)) {
    pipelines["${elem[1]}-pipeline"] = createRegionPipeline(elem[0], elem[1])
}

parallel pipelines

// Utils functions
@NonCPS
List<List<?>> mapToList(Map map) {
  return map.collect { it ->
    [it.key, it.value]
  }
}