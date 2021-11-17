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
//                 autoscaler_name = sh(returnStdout: true, script: "terraform output autoscaling_group_name").trim()
//             }
//         }
//     }
// }
def agentsRegionsList = [
    // "AG-USE1": "us-east-1",
    "AG-USE1": "eu-west-3",
    "AG-USW2": "us-west-2",
    "AG-EUW1": "eu-west-1",
    ]

// Run a pipeline for each region in parallel
// def pipelines = [:]

for (elem in mapToList(agentsRegionsList)) {
    // pipelines["${elem[1]}-pipeline"] = createRegionPipeline(elem[0], elem[1])
    createRegionPipeline(elem[0], elem[1])
}

// parallel pipelines

def createRegionPipeline(agentName, region) {
    // return{
        def autoScalerName
        node(agentName) {
            withEnv([
                "AWS_DEFAULT_REGION=${region}",
                "TF_VAR_aws_region=${region}"
                ]){

                stage("Checkout") {
                    checkout scm
                }
                stage("Check infraestructure in region '${region}'") {
                    checkInfra()
                }
                if(region == "eu-west-3") {
                    stage("Apply infraestrucutre changes in region '${region}'") {
                        autoScalerName = applyInfra()
                    }

                    stage("Deploy app in region '${region}'") {
                        deployApp(autoScalerName)
                    }
                }
            }
        }
    // }
}

def checkInfra() {
    withCredentials([
        string(credentialsId: 'jenkins-aws-secret-key-id', variable: 'AWS_ACCESS_KEY_ID'),
        string(credentialsId: 'jenkins-aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
        string(credentialsId: 'autoupdater_server_username', variable: 'TF_VAR_autoupdater_server_username'),
        string(credentialsId: 'autoupdater_server_pass', variable: 'TF_VAR_autoupdater_server_pass')
    ]) {
        dir("src/terraform-aws-application") {
            sh '''
                terraform init -no-color
                terraform plan -no-color
            '''
        }
    }
}

String applyInfra() {
    withCredentials([string(credentialsId: 'jenkins-aws-secret-key-id', variable: 'AWS_ACCESS_KEY_ID'),
        string(credentialsId: 'jenkins-aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
        string(credentialsId: 'autoupdater_server_username', variable: 'TF_VAR_autoupdater_server_username'),
        string(credentialsId: 'autoupdater_server_pass', variable: 'TF_VAR_autoupdater_server_pass')
    ]) {
        dir("src/terraform-aws-application") {
            sh 'terraform apply --auto-approve -no-color'
            return sh(returnStdout: true, script: 'terraform output autoscaling_group_name').trim()
        }
    }
}

def deployApp(String autoScalerName) {
    withCredentials([string(credentialsId: 'jenkins-aws-secret-key-id', variable: 'AWS_ACCESS_KEY_ID'),
        string(credentialsId: 'jenkins-aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
    ]) {
        dir("src/autoupdater_script") {
            sh """
                source venv/bin/activate
                venv/bin/python ssm_autoupdater.py --autoscaling-group-name ${autoScalerName}"
            """
        }
    }
}


// Utils functions
@NonCPS
List<List<?>> mapToList(Map map) {
  return map.collect { it ->
    [it.key, it.value]
  }
}