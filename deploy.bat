REM Build the artefacts
call mvn clean install -q
echo on
REM Deploy them into servers
echo "Starting to deploy into Prod"
cd ./HelloWorldCompositeApplication
call mvn clean deploy -Dmaven.deploy.skip=true -Dmaven.car.deploy.skip=false
