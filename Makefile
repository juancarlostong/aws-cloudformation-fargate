# make create-cluster create-service get-url


StackName=test-fargate
StackNameService=${StackName}-service

CFTBASE=fargate-networking-stacks/public-vpc.yml
CFTSERVICE=service-stacks/public-subnet-public-loadbalancer.yml

create-cluster:
	aws cloudformation create-stack --stack-name ${StackName} \
                                  --template-body file://${CFTBASE} \
                                  --capabilities CAPABILITY_IAM
	aws cloudformation wait stack-create-complete --stack-name  ${StackName}

create-service:
	aws cloudformation create-stack \
                --stack-name ${StackNameService} \
                --template-body file://${CFTSERVICE} \
                --parameters ParameterKey=StackName,ParameterValue=${StackName} \
                --capabilities CAPABILITY_IAM
	aws cloudformation wait stack-create-complete --stack-name ${StackNameService}

delete-cluster:
	aws cloudformation delete-stack --stack-name ${StackName}
	aws cloudformation wait stack-delete-complete --stack-name ${StackName}

delete-service:
	aws cloudformation delete-stack --stack-name ${StackNameService}
	aws cloudformation wait stack-delete-complete --stack-name ${StackNameService}

get-url:
	aws cloudformation describe-stacks --stack-name ${StackName} --query 'Stacks[].Outputs[?OutputKey==`ExternalUrl`].OutputValue' --output text
