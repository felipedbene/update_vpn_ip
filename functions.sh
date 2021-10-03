function revoke_and_auth_new_ip {
  #Revoke Previous IP
  echo "Revoking old ip"
  aws ec2 revoke-security-group-ingress --group-id $1 \
    --ip-permissions \
    "`aws ec2 describe-security-groups --output json --group-ids $1 --query "SecurityGroups[0].IpPermissions"`"

  #Authorize New IP
  echo "Authorizing new ip"
  aws ec2 authorize-security-group-ingress --group-id $1 --cidr $2 --protocol udp --port 51820

}


function clean_env_vars {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  unset current_ip
  unset sg_ip
  #unset groupId
}


function clean_tmp {
  rm -r /tmp/curIp
  rm -r /tmp/tempCred
}
