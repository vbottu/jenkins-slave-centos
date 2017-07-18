FROM centos:7
MAINTAINER vv2599@gmail.com

# Install Essentials

RUN yum update -y && \
    yum clean all
         
# Install Packages
RUN yum install -y git && \
         yum install -y wget && \
         yum install -y openssh-server && \
         yum install -y sudo && \
         yum clean all
# Java 

ENV JAVA_VERSION 8u131 && \
    JAVA_BUILD 11 && \
    JAVA_HOME=/usr/java/latest && \
    PATH $PATH:$JAVA_HOME/bin


# Installation


RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD}/d54c1d3a095b4ff2b6607d096fa80163/jdk-${JAVA_VERSION}-linux-x64.rpm && \
    yum localinstall -y jdk-${JAVA_VERSION}-linux-x64.rpm && \
    alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 200000 && \
    alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 200000 && \
    alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 200000 && \
    rm -f jdk-${JAVA_VERSION}-linux-x64.rpm && \
    unset JAVA_VERSION && \
    yum clean all

#Maven

ENV MAVEN_VERSION 3.5.0 && \
    MAVEN_HOME /opt/maven && \
    PATH $MAVEN_HOME/bin:$PATH
#Maven Installation

RUN cd ~ && \
    wget http://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /opt/maven && \
    rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    yum clean all


# generate dummy keys, centos doesn't autogenerate them like ubuntu does

RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access

RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User

RUN useradd jenkins -m -s /bin/bash \
  && echo 'jenkins ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:jenkins' | chpasswd

# Add public key for Jenkins login ,this is only required if you are trying to connect to docker slave using ssh key, Copy the id_rsa.pub as authorized_keys and place it in the files directory before building the image
RUN mkdir /home/jenkins/.ssh && \
    touch /home/jenkins/.ssh/authorized_keys && \ #copy the id_rsa.pub contents to this file from the jenkins master in order to enable logging in using ssh private key.
    chown -R jenkins /home/jenkins && \
    chgrp -R jenkins /home/jenkins && \
    chmod 600 /home/jenkins/.ssh/authorized_keys && \
    chmod 700 /home/jenkins/.ssh


# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
