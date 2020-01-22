pipeline {
    agent any
    stages {
        stage('build') {
			environment{
				WSO2_IC_CREDS= credentials('wso2_integration_cloud')
			}
            steps {
                bat "curl -c cookies -v -X POST -k https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag  -d 'action=login&userName=${WSO2_IC_CREDS_USR}&password=${WSO2_IC_CREDS_PSW}'"
            }
        }
    }
}
