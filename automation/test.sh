error_file=/tmp/error.txt
rm -f $error_file
touch $error_file

while read p; do

  echo -en "\n\n\n$p\n"
  host master00-$p.generic.opentlc.com
  oc login -u admin -p r3dh4t1! https://master00-$p.generic.opentlc.com --insecure-skip-tls-verify=true
  responseCode=$?
  if [ $responseCode -ne 0 ];then
    echo -en "\nError with the following guid :  $p    $responseCode\n"
    echo -en "$p" >> $error_file

  fi

  oc get pod -n rhpam-dev-user1

done </tmp/availableguids-R2015.csv
