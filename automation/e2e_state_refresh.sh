new_guid=`echo $HOSTNAME | cut -d'.' -f 1 | cut -d'-' -f 2`
stale_guid=`cat $HOME/guid`
api_control_plane_project=3scale-mt-api0
openbanking_dev_gw_project=openbanking-dev-gw
openbanking_prod_gw_project=openbanking-prod-gw
new_threescale_superdomain=apps-$new_guid.generic.opentlc.com

enableLetsEncryptCertsOnRoutes() {
    oc new-project prod-letsencrypt
    oc create -f https://raw.githubusercontent.com/tnozicka/openshift-acme/master/deploy/letsencrypt-live/cluster-wide/{clusterrole,serviceaccount,imagestream,deployment}.yaml
    oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme

    echo -en "metadata:\n  annotations:\n    kubernetes.io/tls-acme: \"true\"" > /tmp/route-tls-patch.yml
    oc patch route emergency-console --type merge --patch "$(cat /tmp/route-tls-patch.yml)" -n $api_control_plane_project
}

refreshControlPlane() {
  # Switch to namespace of API Manager Control Plane
  oc project $api_control_plane_project


  echo -en "\nwill update the following stale guid in the API Manager from: $stale_guid to $new_guid\n\n"


  ####  Update all references to old GUID in system-mysql database #####

  echo -en "stale URLs in system-mysql .... \n"
  oc exec `oc get pod | grep "system-mysql" | awk '{print $1}'` \
     -- bash -c 'mysql -u root system -e "select id, domain, self_domain from accounts where domain is not null"'

  # update self_domain in accounts (so as to fix existing API tenants )
  oc exec `oc get pod | grep "system-mysql" | awk '{print $1}'` \
     -- bash -c \
     'mysql -u root system -e "update accounts set self_domain = replace(self_domain, \"'$stale_guid'\", \"'$new_guid'\") where       self_domain like \"%'$stale_guid'%\";"'

  # update domain (so as to fix existing API tenants)
  oc exec `oc get pod | grep "system-mysql" | awk '{print $1}'` \
     -- bash -c \
     'mysql -u root system -e "update accounts set domain = replace(domain, \"'$stale_guid'\", \"'$new_guid'\") where domain like   \"%'$stale_guid'%\";"'

  echo -en "\n\nupdated URLs in system-mysql .... \n"
  oc exec `oc get pod | grep "system-mysql" | awk '{print $1}'` \
     -- bash -c 'mysql -u root system -e "select id, domain, self_domain from accounts where domain is not null"'

  echo -en "\n\n"


  ########   Patch backend-listener secret #######
  b64_url=`echo https://backend-t1-$api_control_plane_project.$new_threescale_superdomain | base64 -w 0`
  oc patch secret backend-listener -p "{\"data\":{\"route_endpoint\":\"$b64_url\"} }"

}

refreshDataPlane() {

  oldTPE=`oc get deploy prod-apicast -o json -n $openbanking_dev_gw_project | /usr/local/bin/jq .spec.template.spec.containers[0].env[0].value`
  newTPE=`echo $oldTPE | sed "s/apps-$stale_guid/apps-$new_guid/" | sed "s/\"//g"`
  oldAPIHOST=`oc get deploy wc-router -o json -n $openbanking_dev_gw_project | /usr/local/bin/jq .spec.template.spec.containers[0].env[0].value`
  newAPIHOST=`echo $oldAPIHOST | sed "s/apps-$stale_guid/apps-$new_guid/" | sed "s/\"//g"`

  # update dev_gw
  oc patch deploy prod-apicast -n $openbanking_dev_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"prod-apicast","env":[{"name":"THREESCALE_PORTAL_ENDPOINT","value":"'$newTPE'"}]}]}}}}'
  oc patch deploy stage-apicast -n $openbanking_dev_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"stage-apicast","env":[{"name":"THREESCALE_PORTAL_ENDPOINT","value":"'$newTPE'"}]}]}}}}'
  oc patch deploy wc-router -n $openbanking_dev_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"wc-router","env":  [{"name":"API_HOST","value":"'$newAPIHOST'"}]}]}}}}'

    # update prod_gw
  oc patch deploy prod-apicast -n $openbanking_prod_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"prod-apicast","env":[{"name":"THREESCALE_PORTAL_ENDPOINT","value":"'$newTPE'"}]}]}}}}'
  oc patch deploy stage-apicast -n $openbanking_prod_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"stage-apicast","env":[{"name":"THREESCALE_PORTAL_ENDPOINT","value":"'$newTPE'"}]}]}}}}'
  oc patch deploy wc-router -n $openbanking_prod_gw_project -p '{"spec":{"template":{"spec":{"containers":[{"name":"wc-router","env":  [{"name":"API_HOST","value":"'$newAPIHOST'"}]}]}}}}'

}

enableLetsEncryptCertsOnRoutes
refreshControlPlane
refreshDataPlane
