#!/bin/bash

CMD=$1

function upload_config {
    sed -i "s/\$ZOOKEEPER_COUNT/$ZOOKEEPER_COUNT/" exhibitor.properties
    aws s3 put exhibitor.properties s3://${S3_BUCKET}/${S3_PREFIX}
}

function wait_for_s3 {
    RUNNING=0
    while [ $RUNNING -eq 0 ]; do
      RUNNING=$(aws s3 ls s3://${S3_BUCKET}/${S3_PREFIX} | wc -l)
      sleep 1
    done
}

function get_nodename {
  if [ -z $NODENAME ]; then
    # Guess that we might be inside Rancher:
    NODENAME=$(curl -s -m 2 http://rancher-metadata/2015-12-19/self/container/primary_ip 2> /dev/null)
  fi

  if [ -z $NODENAME ]; then
    # Guess that we might be on EC2:
    NODENAME=$(curl -s -m 2 http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)
  fi
  
  if [ -z $NODENAME ]; then
    NODENAME=unknown
  fi
  echo $NODENAME
}

function start_exhibitor {
    cat > s3.cfg <<EOF
com.netflix.exhibitor.s3.access-key-id=${AWS_ACCESS_KEY}
com.netflix.exhibitor.s3.access-secret-key=${AWS_SECRET_KEY}
EOF
    NODENAME=$(get_nodename)
    java -Dexhibitor-hostname=${NODENAME} \
         -jar exhibitor-1.0-jar-with-dependencies.jar \
         -c s3 \
	 --s3credentials s3.cfg \
	 --s3config=${S3_BUCKET}:${S3_PREFIX} \
	 --port 8181 \
	 --hostname ${NODENAME}
}

case $CMD in
init)
    upload_config
    ;;
run)
    configure_s3
    wait_for_s3
    start_exhibitor
    ;;
*)
    echo "Unknown command: $CMD"
esac
