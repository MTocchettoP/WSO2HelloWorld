pipeline {
    agent any
	
    stages {
        stage('build') {
			environment{
				WSO2_IC_CREDS= credentials('55c97d12-ba8a-40b1-b73f-7289760722ea')
			}
            steps {
                bat 'C:\Program Files\cURL\bin\curl.exe'
            }
        }
    }
}
