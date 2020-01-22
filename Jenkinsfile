pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                bat "curl -c cookies -v -X POST -k https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag  -d 'action=login&userName=${WSO2_IC_USER}&password=${WSO2_IC_PASSWORD}'"
            }
        }
    }
}
