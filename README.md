# WSO2HelloWorld


Basic project to illustrate how to create a very basic CD/CI for WSO2 involving:
  - Integration Studio
  - Github
  - Jenkins
  - WSO2 Integration Cloud
 
 Created based on these tutorials:
https://github.com/chanakaudaya/WSO2-ESB-CICD
https://docs.wso2.com/display/IntegrationCloud/Implement+Continuous+Integration+and+Deployment+with+Jenkins


Pre-requisites:

	
	-cURL on PATH (Win 10 comes with cURL, but you need to install the same or another version somewhere and add it to PATH, otherwise Jenkins will not find the command)
	-Maven on PATH
	-Git on PATH
	-WSO2 Integration cloud account
	
Steps:

	- Start a regular project (Multi Maven don't seem to work properly, will need more investigation in the future)
	- Set up a VCS (Better to do via command line than using WSO2's interface)
	- Add a parent POM to the root directory and configure it and the children to reflect this relationship
	- Install jenkins on a shared server (for multi developers team, I used it locally)
	- In the global tool configuration from jenkins, set all the tools paths (JDK,GIT,MAVEN)
	- In the credentials section of Jenkins, create two global credentials, one for Git one for the WSO2 Integration Cloud (the git one might have already been set when git was set in the global tools)
	- Add a file without any extension to your VCS root, called jenkinsfile
	- Configure the jenkinsfile to do the following steps using the WSO2 Integration Cloud API:
		- curl: Log into WSO2 cloud
		- curl: getApplication or getApplicationList, this is done to get the Default version of the application, the assumption is that is the most up to date and running version
		- curl: get version ID hash (provide the version number acquired before and returns a hash of it, used to STOP the application)
		- curl: stop application (in a 100% free version, you have to stop the application before deployment, you might want to skip this step depending on your prod strategy)
		- git pull repo 
		- mvn clean install (mvn test is currently being run separatly due to an issue explained on the jenkinsfile)
		- curl: deploy a new version (it has to be deployed as a new version always, that's why Jenkins build number is included in the command)
		- curl: update the visibility to private (ensure app is only accesible via API gateway, using WSO2 API Cloud here)
		
	As noticed above, many of the steps depend on each other and need some response manipulation and variable assignment, for this reason you can either use the jenkinsfile mentioned above and create a Jenkins Pipeline to process this or use a bunch of maven plugins like a psycho
	
	In the pipeline configuration you can configure jenkins to pull the SCM based on a cron, which will cause it to build if there are changes to the git repo
	
	The Registry is not necessary, but was left to illustrate how to add branch specific information, like endpoints. This 
	can be further understood by taking a look at the github repo used as basis for this, referenced at the begining.
	
	Known Problems
	- Due to some security measures baked into jenkins in regards as pipelines that live in a SCM, like the one above (jenkinsfile inside github),
	  you or and admin might need to authorize some scripts
		SOLUTION: this will be on Manage Jenkins > In-Process Script Approval, and will pop up at the first time a jenkinsfile that requires such authorization 
		runs.
	  
	- With a paid subcription, multiple versions of an application can be running. This won't incur any update to the gateway as whatever version is set as default will point to the URL given to the gateway and older versions will have the version number in their URL, HOWEVER, even in this scenario, where the old version is still running when a new version is deployed, because there is a handoff of the default URL from one version to the other there is a period of +- 1 minute of LOSS Of Service where the client receives a 500 error. This problem still happens when the Update path is taken (update the car file instead of deploying a new one).
		SOLUTION: No solution exists at the moment
	  	  
	TODOs:
	
	- There is no easy way to promote a process from a QA to a Prod , the better way is to deploy the project as a different application i.E HelloWorldProd and HelloWorldQA, these would be independent applications as they should
	- In order to deploy the QA app all it would take is a change in name, a quick tweek to the jenkinsfile should do it based on a variable I.E Every commit to a dev branch will push to QA, things are only pushed to Prod after a merge from a senior member etc etc
  
  Note:
  
  Updating the capp file of an existing application
 
1. First login with your credentials to the integration cloud.
 
curl -c cookies -v -X POST -k https://integration.cloud.wso2.com/appmgt/site/blocks/user/login/ajax/login.jag  -d 'action=login&userName=<USER_NAME@TENANTDOMAIN>&password=<CLOUD_PASSWORD>'
 
2. Next you need to get the details of your existing application. You can use the below sample CURL for that.
 
curl -v -b cookies -X POST  https://integration.cloud.wso2.com/appmgt/site/blocks/application/application.jag -d 'action=getVersionHashId&applicationName=<APPLICATION_NAME>&applicationRevision=<APPLICATION_VERSION>'
 
3. From the response received from the above request, mark down the following details. We will be using them in step 4,5 below.
•	applicationName
•	versionHashId
•	appTypeName
•	version
•	applicationHashId
•	conSpecCpu
•	conSpecMemory

4. Next we need to upload the file(car file in this case) to the desired application's version. This will update the file only of the existing application in the existing version. For that see the sample request.
 
curl -v -b cookies -X POST https://integration.cloud.wso2.com/appmgt/site/blocks/updateVersion/updateVersion.jag -F action=uploadUpdatedArchive -F applicationName=<APPLICATION_NAME> -F appTypeName=wso2esb -F applicationRevision=<APPLICATION_VERSION> -F fileupload=@<ABSOLUTE_PATH_OF_CAR_FILE_IN_THE_FILESYSTEM>
 
eg: curl -v -b cookies -X POST https://integration.cloud.wso2.com/appmgt/site/blocks/updateVersion/updateVersion.jag -F action=uploadUpdatedArchive -F applicationName=CloudIntegration -F appTypeName=wso2esb -F applicationRevision=1.0.0 -F fileupload=@/home/SampleServices_3.car
 
5. Next you need to update the application details pointing to this updated car file using the below command. You can get the values for the fields from the information gathered in step 3 above.
 
curl -v -b cookies -X POST https://integration.cloud.wso2.com/appmgt/site/blocks/updateVersion/updateVersion.jag -F action=updateApplication  -F description=<UPDATE_NAME/DESCRIPTION> -F applicationName=<APPLICATION_NAME> -F versionHashId=<VERSION_HASH_ID> -F appTypeName=wso2esb -F version=<APPLICATION_VERSION> -F applicationHashId=<APPLICATION_HASH_ID> -F conSpecCpu=<CON_SPEC_CPU> -F conSpecMemory=<CON_SPEC_MEMORY> -F uploadMethod=default

eg: curl -v -b cookies -X POST https://integration.cloud.wso2.com/appmgt/site/blocks/updateVersion/updateVersion.jag -F action=updateApplication  -F description=updatedApp -F applicationName=CloudIntegration -F versionHashId=36087131111681174214 -F appTypeName=wso2esb -F version=1.0.0 -F applicationHashId=2214164122220502200 -F conSpecCpu=1000 -F conSpecMemory=2048 -F uploadMethod=default
