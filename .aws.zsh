function aws-profile() {
	BUFFER=$(grep '\[[a-z_-]\+\]$' $HOME/.aws/credentials | sed -e 's/\[//g' -e 's/\]//g' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_CONFIG > ")
	AWS_PROFILE=$BUFFER
	echo $BUFFER
}

function aws-log-events() {
	BUFFER1=$(aws logs describe-log-groups | jq -r '.logGroups[].logGroupName' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_GROUP > ")
	BUFFER2=$(aws logs describe-log-streams --log-group-name $BUFFER1 | jq '.logStreams[]' | jq '.lastEventTimestamp, .logStreamName' | paste -d " " - - | sort -r)
	BUFFER3=$(echo $BUFFER2 | while read t n; do
		echo "$(date -r $((t / 1000)))" ":" {$n}
	done | head -n ${1:-40} | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_STREAM > " | cut -d '{' -f 2 | cut -d '}' -f 1 | sed 's/\"//g')
	aws logs get-log-events --log-group-name $BUFFER1 --log-stream-name $BUFFER3 | jq '.events'
}

function aws-s3-bucket() {
	BUFFER1=$(aws s3 ls | cut -d ' ' -f 3 | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_S3_BUCKET > ")
	BUFFER2=$(aws s3 ls s3://$BUFFER1 --recursive | tail -n ${1:-40} | rev | cut -d ' ' -f 1 | rev | sort -r | fzf -m --prompt="AWS_S3_PATH_NAME > ")
	BUFFER3=$(aws s3 ls s3://$BUFFER1/$BUFFER2 | cut -d ' ' -f 1,2)
	echo file_name: $BUFFER2
	echo last_updated_at: $BUFFER3
}

function aws-route53-hosted-zone() {
	BUFFER1=$(aws route53 list-hosted-zones | jq -r '.HostedZones[]|{Id: .Id, Name: .Name}' -c)
	BUFFER2=$(echo $BUFFER1 | jq '.Name' | fzf)
	# ID
	BUFFER3=$(echo $BUFFER1 | jq -r 'select(.Name == '"$BUFFER2"')' | jq -r ".Id")
	BUFFER4=$(aws route53 list-resource-record-sets --hosted-zone-id $BUFFER3 | jq -r ".ResourceRecordSets[]|.Name" | uniq | fzf --prompt="AWS_ROUTE53_DOMAIN_NAME > ")
	if [ -n "$1" ]; then
		echo $(echo $BUFFER4 | sed "s/\.\$//")/$1
	else
		echo $BUFFER4
	fi
}
