pipeline {
    agent any
	environment{
				WSO2_IC_CREDS= credentials('55c97d12-ba8a-40b1-b73f-7289760722ea')
				APP_NAME = 'HelloWorld'
			}
			
    stages {
        stage('prep') {
			
            steps {
			
				//Login into WSO2 Integration Cloud, this gives puts the auth in a cookie so future requests are already authorized
                bat "curl -c cookies -v -X POST -F action=login -F userName=${env.WSO2_IC_CREDS_USR} -F password=${env.WSO2_IC_CREDS_PSW} https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag"
            
				script{ 
					
					//Get a list of all the version of the application to be deployed
                    response = bat (returnStdout: true, script: "curl -v -b cookies  -X POST -F action=getApplication -F applicationName=${APP_NAME} https://integration.cloud.wso2.com/appmgt/site/blocks/application/application.jag").trim()
                    response = response.readLines().drop(1).join(" ") 
                    
					//Extracts the default version, assuming this is the most current version, thus the one running
                    jsonObj = readJSON text: response
                    latest_ver = jsonObj.defaultVersion
                    
					//Use the latest_ver number to get the hashed key of the version number
                    response = bat (returnStdout: true, script: "curl -v -b cookies  -X POST -F action=getVersionHashId -F applicationName=${APP_NAME} -F applicationRevision=${latest_ver} https://integration.cloud.wso2.com/appmgt/site/blocks/application/application.jag").trim()
                    versionHash = response.readLines().drop(1).join(" ") 
                                       
                }
				
				//Stop the latest version of the application, using the versionHash
				bat "curl -c cookies -v -X POST -F action=stopApplication -F applicationName=${APP_NAME} -F applicationRevision=${latest_ver} -F versionKey=${versionHash} https://integration.cloud.wso2.com/appmgt/site/blocks/application/application.jag"
            
                

                
            }
        }
		stage('build') {
			
			steps {
				git credentialsId: '437104b4-e176-4c0e-bd87-74dd916f70e6', url: 'https://github.com/MTocchettoP/WSO2HelloWorld'
				bat "mvn clean install -Dmaven.test.skip=true"
			}
		}
		stage('deploy') {
		
			steps {
				
			}
			
		}
    }
}
