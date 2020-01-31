# Introduction 
This project is to automate end to end creation of new accounts in AWS

# Structure

1.	New Account creation.
2.	VPC creation
3.	IAM Role and User creation
4.	Azure ADD SSO setup

# Current State
This project is currently in incubation period.


# Script Usage

usage: organization_new_acc.sh [-h] --account_name ACCOUNT_NAME
                                      --account_email ACCOUNT_EMAIL
                                      --newProfile CLI_PROFILE_NAME
                                      --ou_name ORGANIZATION_UNIT_NAME
                                      --region AWS_REGION
                                      --VPCCidrBlock 10.0.0.0/16
                                      --PublicSubnetCIDR1 10.0.0.0/16
                                      --PublicSubnetCIDR2 10.0.0.0/16
                                      --PrivateSubnetCIDR1 10.0.0.0/16
                                      --PrivateSubnetCIDR2 10.0.0.0/16
                                      --MetadataSamlfile samplemetada.xml

# Author

For more information please contact Hammad Haqqani !
phaqqani@gmail.com

Text


