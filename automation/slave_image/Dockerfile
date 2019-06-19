# sudo podman build --rm -t quay.io/rhtgptetraining/3scale_toolbox_jenkins_slave:1.1 slave_image 
# podman login .....
# podman push quay.io/rhtgptetraining/3scale_toolbox_jenkins_slave:1.1

FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11

USER root

RUN yum install -y skopeo podman

RUN rpm -ivh https://github.com/3scale/3scale_toolbox_packaging/releases/download/v0.11.0/3scale-toolbox-0.11.0-1.el7.x86_64.rpm

RUN yum clean all

USER 1001
