pipeline {
    agent any
    stages {
        stage('build') {
			environment{
				WSO2_IC_CREDS= credentials('55c97d12-ba8a-40b1-b73f-7289760722ea')
			}
            steps {
                bat 'curl -c cookies -v -X POST -k https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag  -d "action=login&userName=${WSO2_IC_CREDS_USR}&password=${WSO2_IC_CREDS_PSW}"'
            }
        }
    }
}
