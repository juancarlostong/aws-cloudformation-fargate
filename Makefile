# make create-cluster create-service get-url


StackName=test-fargate
StackNameService=${StackName}-service
AWS_REGION ?= us-west-1

CFTBASE=fargate-networking-stacks/public-private-vpc.yml
CFTSERVICE=service-stacks/private-subnet-public-loadbalancer.yml

create-cluster:
	aws --region=$(AWS_REGION) cloudformation create-stack --stack-name ${StackName} \
                                  --template-body file://${CFTBASE} \
                                  --capabilities CAPABILITY_IAM
	aws --region=$(AWS_REGION) cloudformation wait stack-create-complete --stack-name ${StackName}

create-service:
	aws --region=$(AWS_REGION) cloudformation create-stack \
                --stack-name ${StackNameService} \
                --template-body file://${CFTSERVICE} \
                --parameters ParameterKey=StackName,ParameterValue=${StackName} \
                --capabilities CAPABILITY_IAM
	aws --region=$(AWS_REGION) cloudformation wait stack-create-complete --stack-name ${StackNameService}

update-service:
	aws --region=$(AWS_REGION) cloudformation update-stack \
                --stack-name ${StackNameService} \
                --template-body file://${CFTSERVICE} \
                --parameters ParameterKey=StackName,ParameterValue=${StackName} \
                --capabilities CAPABILITY_IAM
	aws --region=$(AWS_REGION) cloudformation wait stack-update-complete --stack-name ${StackNameService}

delete-cluster:
	aws --region=$(AWS_REGION) cloudformation delete-stack --stack-name ${StackName}
	aws --region=$(AWS_REGION) cloudformation wait stack-delete-complete --stack-name ${StackName}

delete-service:
	aws --region=$(AWS_REGION) cloudformation delete-stack --stack-name ${StackNameService}
	aws --region=$(AWS_REGION) cloudformation wait stack-delete-complete --stack-name ${StackNameService}

get-url:
	aws --region=$(AWS_REGION) cloudformation describe-stacks --stack-name ${StackName} --query 'Stacks[].Outputs[?OutputKey==`ExternalUrl`].OutputValue' --output text
