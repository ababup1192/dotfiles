function aws-profile() {
	BUFFER=$(grep '\[[a-z_-]\+\]$' $HOME/.aws/credentials | sed -e 's/\[//g' -e 's/\]//g' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_CONFIG > ")
	AWS_PROFILE=$BUFFER
	echo $BUFFER
}

function aws-log-events() {
	BUFFER1=$(aws logs describe-log-groups | jq -r '.logGroups[].logGroupName' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_GROUP > ")
	BUFFER2=$(aws logs describe-log-streams --log-group-name $BUFFER1 | jq '.logStreams[]' | jq '.lastEventTimestamp, .logStreamName' | paste -d " " - -)
	BUFFER3=$(echo $BUFFER2 | while read t n; do
		echo "$(date -r $((t / 1000)))" ":" {$n}
	done | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_STREAM > " | cut -d '{' -f 2 | cut -d '}' -f 1 | sed 's/\"//g')
	aws logs get-log-events --log-group-name $BUFFER1 --log-stream-name $BUFFER3 | jq '.events'
}

function aws-s3-file-search() {
	BUFFER=$(aws s3 ls | cut -d ' ' -f 3 | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_S3_BUCKET > ")
	aws s3 ls s3://$BUFFER --recursive | fzf
}
