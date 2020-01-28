pipeline {
    agent any
	environment{
				//Set all variables and credentials here to avoid any changes in the script
				WSO2_IC_CREDS= credentials('55c97d12-ba8a-40b1-b73f-7289760722ea')
				APP_NAME = 'HelloWorld'
				GIT_REPO = 'https://github.com/MTocchettoP/WSO2HelloWorld'
				GIT_CRED = '437104b4-e176-4c0e-bd87-74dd916f70e6'
				WSO2_IC_LOGIN_URL = 'https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag'
				WSO2_IC_APP_URL = 'https://integration.cloud.wso2.com/appmgt/site/blocks/application/application.jag'
			}
			
    stages {
        stage('prep') {
			
            steps {
			
				//Login into WSO2 Integration Cloud, this gives puts the auth in a cookie file so future requests are already authorized
                bat "curl -c cookies -v -X POST -F action=login -F userName=${env.WSO2_IC_CREDS_USR} -F password=${env.WSO2_IC_CREDS_PSW} ${WSO2_IC_LOGIN_URL}"
            
				script{ 
					
					//Get a list of all the version of the application to be deployed
                    response = bat (returnStdout: true, script: "curl -v -b cookies  -X POST -F action=getApplication -F applicationName=${APP_NAME} ${WSO2_IC_APP_URL}").trim()
                    response = response.readLines().drop(1).join(" ") 
                    
					//Extracts the default version, assuming this is the most current version, thus the one running
                    jsonObj = readJSON text: response
                    latest_ver = jsonObj.defaultVersion
                    
					//Use the latest_ver number to get the hashed key of the version number
                    response = bat (returnStdout: true, script: "curl -v -b cookies  -X POST -F action=getVersionHashId -F applicationName=${APP_NAME} -F applicationRevision=${latest_ver} ${WSO2_IC_APP_URL}").trim()
                    versionHash = response.readLines().drop(1).join(" ").trim() 
                                       
                }
            
				
				//Stop the latest version of the application, using the versionHash
				bat "curl -v -b cookies -X POST -F action=stopApplication -F applicationName=${APP_NAME} -F applicationRevision=${latest_ver} -F versionKey=${versionHash} ${WSO2_IC_APP_URL}"
                
                

                
            }
        }
		stage('build') {
			
			steps {
				git credentialsId: "${GIT_CRED}", url: "${GIT_REPO}"
				bat "mvnDebug -e -X clean install -DtestServerType=local -DtestServerPort=9008 -DtestServerPath=C:\\IntegrationStudio\\runtime\\microesb\\bin\\micro-integrator.bat" //-Dmaven.test.skip=true" 
			}
		}
		stage('deploy') {
		
			steps {
				//Prep
				script {
				    pom = readMavenPom file: 'pom.xml'
				    deployFolder = pom.properties.'car.folder'
				}
				
				//Go into the folder where the car file is located
				dir(deployFolder) {
                    script {
    				    pom = readMavenPom file: 'pom.xml'
    				    deployVersion = pom.properties.'deploy.version'
						//buildDir = pom.properties.'build.dir'
				    
                        //Deploy
						//Since we are inside a subfolder from where our auth cookie was created, we need to add a step up to the cookie file ..\\
					    bat "curl -v -b ..\\cookies -X POST -F action=createApplication -F applicationName=${APP_NAME} -F conSpec=5 -F runtime=24 -F appTypeName=wso2esb -F applicationRevision=${deployVersion}.${env.BUILD_NUMBER} -F fileupload=@target\\${pom.artifactId}_${pom.version}.car -F isFileAttached=true -F isNewVersion=true -F appCreationMethod=default -F setDefaultVersion=true ${WSO2_IC_APP_URL}"                  	
                    }
                    
					//Change the visibility to private
					bat "curl -v -b cookies -X POST https://integration.cloud.wso2.com/appmgt/site/blocks/settings/settings.jag -F action=updateVersionExposureLevel -F applicationName=${APP_NAME} -F versionName=${deployVersion}.${env.BUILD_NUMBER} -F exposureLevel=private"
					
                }
								
			}
			
		}
    }
}
