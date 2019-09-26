failed_status=MatchNodeSelector
namespace=3scale-mt-api0

for pod in `oc get pods -n $namespace -o template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do \
    reason=`oc get pod $pod -o template --template {{.status.reason}} -n $namespace`;

    echo -en "$pod $reason\n" ;

    if [[ "$failed_status" == "$reason" ]]; then
      echo -n "will delete:  $pod $reason" ;
      echo -en '\n\n';
      oc delete pod $pod -n $namespace
    fi
done

