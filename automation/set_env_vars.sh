#!/bin/bash

echo "export API_REGION=`echo $HOSTNAME | cut -d'.' -f1 | cut -d'-' -f2`" >> ~/.bashrc
echo "export BASE_NAME=openbanking" >> ~/.bashrc
echo "export API_DOMAIN=\$API_REGION.generic.opentlc.com" >> ~/.bashrc
echo "export API_USERNAME=api1" >> ~/.bashrc
echo "export API_MANAGER_NS=3scale-mt-api0" >> ~/.bashrc
echo "export OCP_USERNAME=user1" >> ~/.bashrc
echo "export GW_PROJECT_DEV=\$BASE_NAME-dev-gw" >> $HOME/.bashrc
echo "export GW_PROJECT_PROD=\$BASE_NAME-prod-gw" >> $HOME/.bashrc
echo "export CICD_PROJECT=\$BASE_NAME-cicd" >> $HOME/.bashrc
echo "export NEXUS_PROJECT=\$BASE_NAME-nexus" >> $HOME/.bashrc
echo "export DEV_API_PROJECT=\$BASE_NAME-api-dev" >> $HOME/.bashrc
echo "export TEST_API_PROJECT=\$BASE_NAME-api-test" >> $HOME/.bashrc
echo "export PROD_API_PROJECT=\$BASE_NAME-api-prod" >> $HOME/.bashrc

echo 'export API_PASSWD=admin' >> ~/.bashrc
echo 'export OCP_PASSWD=r3dh4t1!' >> ~/.bashrc

echo "export OCP_REGION=`echo $HOSTNAME | cut -d'.' -f1 | cut -d'-' -f2`" >> ~/.bashrc
echo "export OCP_DOMAIN=\$API_REGION.generic.opentlc.com" >> ~/.bashrc
echo "export OCP_WILDCARD_DOMAIN=apps-\$OCP_DOMAIN" >> ~/.bashrc
echo "export API_WILDCARD_DOMAIN=apps-\$API_DOMAIN" >> ~/.bashrc
echo "export TENANT_NAME_DEV=\$BASE_NAME-dev" >> ~/.bashrc
echo "export TENANT_NAME_PROD=\$BASE_NAME-prod" >> ~/.bashrc

source $HOME/.bashrc

echo "export API_ADMIN_ACCESS_TOKEN_DEV=`oc describe  deploy prod-apicast -n $GW_PROJECT_DEV | grep THREESCALE_PORTAL_ENDPOINT | cut -d'@' -f1 | cut -d'/' -f3`" >> ~/.bashrc
echo "export API_ADMIN_ACCESS_TOKEN_PROD=`oc describe  deploy prod-apicast -n $GW_PROJECT_PROD | grep THREESCALE_PORTAL_ENDPOINT | cut -d'@' -f1 | cut -d'/' -f3`" >> ~/.bashrc

echo "export THREESCALE_PORTAL_ENDPOINT_DEV=https://\${API_ADMIN_ACCESS_TOKEN_DEV}@\$TENANT_NAME_DEV-admin.\$API_WILDCARD_DOMAIN" >> ~/.bashrc
echo "export THREESCALE_PORTAL_ENDPOINT_PROD=https://\${API_ADMIN_ACCESS_TOKEN_PROD}@\$TENANT_NAME_PROD-admin.\$API_WILDCARD_DOMAIN" >> ~/.bashrc

