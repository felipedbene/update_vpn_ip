#!/usr/bin/bash
# Configuration Session
#SecurityGroupId
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export groupId="sg-0a93c3ccb03ea2a88"

# Aux functions
source ~/duckdns/functions.sh

# Clean Previous Credentials
clean_env_vars

#Paso 1 - AssumeRole
aws sts assume-role --role-arn arn:aws:iam::479679319155:role/UpdateSecurityGroup --role-session-name UpdateSecurityGroupScript > /tmp/tempCred

#Step 2 - Send to env Vars
export AWS_ACCESS_KEY_ID=$(jq -r ".Credentials.AccessKeyId" /tmp/tempCred)
export AWS_SECRET_ACCESS_KEY=$(jq -r ".Credentials.SecretAccessKey" /tmp/tempCred)
export AWS_SESSION_TOKEN=$(jq -r ".Credentials.SessionToken" /tmp/tempCred)

#Step 3 - Get SecurityGroup configuredip
aws ec2 describe-security-groups --group-ids $groupId > /tmp/curIp

#Parse json
export sg_ip=`jq -r ".SecurityGroups[].IpPermissions[].IpRanges[].CidrIp" /tmp/curIp`

#sg_ip=$(aws ec2 describe-security-groups --group-ids $groupId --query "SecurityGroups[0].IpPermissions[0].IpRanges[0].CidrIp")

# Get the new ip
export current_ip=$(curl https://ifconfig.me/ip)
export current_ip="$current_ip/32"
#echo $current_ip
if [ $sg_ip == $current_ip ]
then
  echo "Nothing to do"
else
  echo "Updating SG on AWS"
  revoke_and_auth_new_ip $groupId $current_ip
  clean_tmp
  clean_env_vars
fi
