#!/bin/bash

function usage
{
    echo "usage: organization_new_acc.sh [-h] --account_name ACCOUNT_NAME
                                      --account_email ACCOUNT_EMAIL
                                      --newProfile CLI_PROFILE_NAME
                                      --ou_name ORGANIZATION_UNIT_NAME
                                      --region AWS_REGION
                                      --VPCCidrBlock 10.0.0.0/16
                                      --PublicSubnetCIDR1 10.0.0.0/16
                                      --PublicSubnetCIDR2 10.0.0.0/16
                                      --PrivateSubnetCIDR1 10.0.0.0/16
                                      --PrivateSubnetCIDR2 10.0.0.0/16
                                      --MetadataSamlfile samplemetada.xml"
}

newAccName=""
newAccEmail=""
newProfile=""
roleName="OrganizationAccountAccessRole"
destinationOUname=""
region="us-west-2"
VPCCidrBlock=""
PublicSubnetCIDR1=""
PublicSubnetCIDR2=""
PrivateSubnetCIDR1=""
PrivateSubnetCIDR2=""
MetadataSamlfile=""

while [ "$1" != "" ]; do
    case $1 in
        -n | --account_name )   shift
                                newAccName=$1
                                ;;
        -e | --account_email )  shift
                                newAccEmail=$1
                                ;;
        -p | --newProfile ) shift
                                newProfile=$1
                                ;;
        -o | --ou_name )        shift
                                destinationOUname=$1
                                ;;
        -r | --region )        shift
                                region=$1
                                ;;
        -v | --VPCCidrBlock )   shift
                                VPCCidrBlock=$1
                                ;;
        -pso | --PublicSubnetCIDR1 )   shift
                                PublicSubnetCIDR1=$1
                                ;;
        -pst | --PublicSubnetCIDR2 )   shift
                                PublicSubnetCIDR2=$1
                                ;;   
        -pso | --PrivateSubnetCIDR1 )   shift
                                PrivateSubnetCIDR1=$1
                                ;;
        -pst | --PrivateSubnetCIDR2)   shift
                                PrivateSubnetCIDR2=$1
                                ;; 
        -d | --MetadataSamlfile)   shift
                                MetadataSamlfile=$1
                                ;;                                                                                                                                                     
        -h | --help )           usage
                                exit
                                ;;
    esac
    shift
done

if [ "$newAccName" = "" ] || [ "$newAccEmail" = "" ] || [ "$newProfile" = "" ]
then
  usage
  exit
fi

printf "Create New Account\n"
ReqID=$(aws organizations create-account --email $newAccEmail --account-name "$newAccName" --role-name OrganizationAccountAccessRole \
--query 'CreateAccountStatus.[Id]' \
--output text)

echo "$ReqID"

printf "Waiting for New Account ..."
orgStat=$(aws organizations describe-create-account-status --create-account-request-id $ReqID \
--query 'CreateAccountStatus.[State]' \
--output text)
echo "$orgStat"
while [ $orgStat != "SUCCEEDED" ]
do
  if [ $orgStat = "FAILED" ]
  then
    printf "\nAccount Failed to Create\n"
    exit 1
  fi
  printf "."
  sleep 10
  orgStat=$(aws organizations describe-create-account-status --create-account-request-id $ReqID \
  --query 'CreateAccountStatus.[State]' \
  --output text)
done

echo "$orgStat"

accID=$(aws organizations describe-create-account-status --create-account-request-id $ReqID \
--query 'CreateAccountStatus.[AccountId]' \
--output text)

echo "$accID"

accARN="arn:aws:iam::$accID:role/OrganizationAccountAccessRole"

echo "$accARN"
printf "\nCreate New CLI Profile\n"
aws configure set region $region --profile $newProfile
aws configure set role_arn $accARN --profile $newProfile
aws configure set source_profile default --profile $newProfile

cfcntr=0
printf "Waiting for CF Service ..."
aws cloudformation list-stacks --profile $newProfile 
actOut=$?
while [[ $actOut -ne 0 && $cfcntr -le 10 ]]
do
  sleep 5
  aws cloudformation list-stacks --profile $newProfile > /dev/null 2>&1
  actOut=$?
  if [ $actOut -eq 0 ]
  then
    break
  fi
  printf "."
  cfcntr=$[$cfcntr +1]
done

if [ $cfcntr -gt 10 ]
then
  printf "\nCF Service not available\n"
  exit 1
fi

#aws cloudformation describe-stacks --stack-name VPC --profile $newProfile

#Create USER for Azure AD

printf "Create ADCLIUSERS for Azure AD to Connect\n"
aws cloudformation create-stack --stack-name ADCLIUSERS --template-body file://CF-USER.json --capabilities CAPABILITY_NAMED_IAM --profile $newProfile 
cfStat2=$(aws cloudformation describe-stacks --stack-name ADCLIUSERS --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
echo "$cfStat2"
while [ $cfStat2 != "CREATE_COMPLETE" ]
do
  sleep 5
  printf "."
  cfStat2=$(aws cloudformation describe-stacks --stack-name ADCLIUSERS --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
  if [ $cfStat2 = "CREATE_FAILED" ]
  then
    printf "\ADCLIUSERS Failed to Create\n"
    exit 1
  fi
done
printf "\ADCLIUSERS Created\n"

aws cloudformation describe-stacks --stack-name ADCLIUSERS --profile $newProfile


#Create new SAML connector and upload it

printf "Create a new SAML connector and uploading metadata file from Azure \n"

SAMLID=$(aws iam create-saml-provider --saml-metadata-document file://$MetadataSamlfile --name $newAccName --profile $newProfile | jq -r '.SAMLProviderArn')

echo "$SAMLID"

#aws iam create-saml-provider --saml-metadata-document file://SAMLMetaData.xml --name $newAccName-ADConnector --profile $newProfile


printf "Create Roles and Policy for AD Azure integration\n"
aws cloudformation create-stack --stack-name Roles --template-body file://CF-IAM-AD.json --parameters  ParameterKey=SAMLID,ParameterValue=$SAMLID --capabilities CAPABILITY_NAMED_IAM --profile $newProfile 
cfStat3=$(aws cloudformation describe-stacks --stack-name Roles --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
echo "$cfStat3"
while [ $cfStat3 != "CREATE_COMPLETE" ]
do
  sleep 5
  printf "."
  cfStat3=$(aws cloudformation describe-stacks --stack-name Roles --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
  if [ $cfStat3 = "CREATE_FAILED" ]
  then
    printf "\Role Failed to Create AD Azure integration\n"
    exit 1
  fi
done
printf "\Role Created AD Azure integration\n"

aws cloudformation describe-stacks --stack-name Roles --profile $newProfile 


printf "Create Role and Policy\n"
aws cloudformation create-stack --stack-name ConfigRoles --template-body file://CF-IAM-ConfigRule.json --capabilities CAPABILITY_NAMED_IAM --profile $newProfile > /dev/null 2>&1
cfStat=$(aws cloudformation describe-stacks --stack-name ConfigRoles --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
while [ $cfStat != "CREATE_COMPLETE" ]
do
  sleep 5
  printf "."
  cfStat=$(aws cloudformation describe-stacks --stack-name ConfigRoles --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
  if [ $cfStat = "CREATE_FAILED" ]
  then
    printf "\Role Failed to Create\n"
    exit 1
  fi
done
printf "\Role Created\n"

printf "Create Configure Rule\n"
configRole=arn:aws:iam::$accID:role/service-role/config-rule-role

aws configservice put-configuration-recorder --configuration-recorder name=default,roleARN=$configRole --recording-group allSupported=true,includeGlobalResourceTypes=true --profile $newProfile > /dev/null 2>&1
aws configservice put-config-rule --config-rule file://CF-ConfigRules.json --profile $newProfile > /dev/null 2>&1

if [ "$destinationOUname" != "" ]
then
  printf "Moving New Account to OU\n"
  rootOU=$(aws organizations list-roots --query 'Roots[0].[Id]' --output text)
  destOU=$(aws organizations list-organizational-units-for-parent --parent-id $rootOU --query 'OrganizationalUnits[?Name==`'$destinationOUname'`].[Id]' --output text)

  aws organizations move-account --account-id $accID --source-parent-id $rootOU --destination-parent-id $destOU > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    printf "Moving Account Failed\n"
  fi
fi

printf "\nCreate VPC Under New Account\n"
aws cloudformation create-stack --stack-name VPC --template-body file://CF-VPC.json --parameters  ParameterKey=VPCCidrBlock,ParameterValue=$VPCCidrBlock ParameterKey=PublicSubnetCIDR1,ParameterValue=$PublicSubnetCIDR1 ParameterKey=PublicSubnetCIDR2,ParameterValue=$PublicSubnetCIDR2 ParameterKey=PrivateSubnetCIDR1,ParameterValue=$PrivateSubnetCIDR1 ParameterKey=PrivateSubnetCIDR2,ParameterValue=$PrivateSubnetCIDR2 --profile $newProfile
if [ $? -ne 0 ]
then
  printf "CF VPC Stack Failed to Create\n"
  exit 1
fi

printf "Waiting for CF Stack to Finish ..."
cfStat=$(aws cloudformation describe-stacks --stack-name VPC --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
echo "$cfStat"
while [ $cfStat != "CREATE_COMPLETE" ]
do
  sleep 5
  printf "."
  cfStat=$(aws cloudformation describe-stacks --stack-name VPC --profile $newProfile --query 'Stacks[0].[StackStatus]' --output text)
  if [ $cfStat = "CREATE_FAILED" ]
  then
    printf "\nVPC Failed to Create\n"
    exit 1
  fi
done
printf "\nVPC Created\n"
aws cloudformation describe-stacks --stack-name VPC
