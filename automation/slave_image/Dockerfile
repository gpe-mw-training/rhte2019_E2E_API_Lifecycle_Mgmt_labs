FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11

USER root

RUN yum install -y skopeo

RUN rpm -ivh https://github.com/3scale/3scale_toolbox_packaging/releases/download/v0.10.0/3scale-toolbox-0.10.0-1.el7.x86_64.rpm

RUN yum clean all

USER 1001
