def agentsRegionsList = [
    "AG-USE1": "us-east-1",
    "AG-USW2": "us-west-2",
    "AG-EUW1": "eu-west-1",
    ]

// Run a pipeline for each region
for (elem in mapToList(agentsRegionsList)) {
    createRegionPipeline(elem[0], elem[1])
}

// Define a pipeline
def createRegionPipeline(agentName, region) {
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
                    updateApp(autoScalerName)
                }
            }
        }
    }
}

// Check infrastructure state
def checkInfra() {
    withCredentials([
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

// Apply infrastructure changes
String applyInfra() {
    withCredentials([
        string(credentialsId: 'autoupdater_server_username', variable: 'TF_VAR_autoupdater_server_username'),
        string(credentialsId: 'autoupdater_server_pass', variable: 'TF_VAR_autoupdater_server_pass')
    ]) {
        dir("src/terraform-aws-application") {
            sh 'terraform apply --auto-approve -no-color'
            return sh(returnStdout: true, script: 'terraform output autoscaling_group_name').trim()
        }
    }
}

// Update 'test-app'
def updateApp(String autoScalerName) {
    dir("src/autoupdater_script") {
        sh """
            venv/bin/python ssm_autoupdater.py --autoscaling-group-name ${autoScalerName}
        """
    }
}

// Utils functions
@NonCPS
List<List<?>> mapToList(Map map) {
  return map.collect { it ->
    [it.key, it.value]
  }
}