function aws-profile() {
	BUFFER=$(grep '\[[a-z_-]\+\]$' $HOME/.aws/credentials | sed -e 's/\[//g' -e 's/\]//g' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_CONFIG > ")
	AWS_PROFILE=$BUFFER
	echo $BUFFER
}

function aws-log-events() {
	BUFFER1=$(aws logs describe-log-groups | jq '.logGroups[].logGroupName' | sed 's/\"//g' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_GROUP > ")
	echo "[Prealse Enter] You choose $BUFFER1" && read
	BUFFER2=$(aws logs describe-log-streams --log-group-name $BUFFER1 | jq '.logStreams[].logStreamName' | sed 's/\"//g' | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_LOG_STREAM > ")
	aws logs get-log-events --log-group-name $BUFFER1 --log-stream-name $BUFFER2 | jq '.events'
}

function aws-s3-file-search() {
	BUFFER=$(aws s3 ls | cut -d ' ' -f 3 | fzf --no-sort +m --query "$LBUFFER" --prompt="AWS_S3_BUCKET > ")
	aws s3 ls s3://$BUFFER --recursive | fzf
}
