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

ENV JAVA_VERSION 8u131
ENV JAVA_BUILD 11
ENV JAVA_HOME=/usr/java/latest


# Installation


RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-b${JAVA_BUILD}/d54c1d3a095b4ff2b6607d096fa80163/jdk-${JAVA_VERSION}-linux-x64.rpm
RUN yum localinstall -y jdk-${JAVA_VERSION}-linux-x64.rpm
RUN alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 200000
RUN alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 200000
RUN alternatives --install /usr/bin/jar jar ${JAVA_HOME}/bin/jar 200000

# Set JAVA_HOME in path

ENV PATH $PATH:$JAVA_HOME/bin

# Cleanup
RUN rm jdk-${JAVA_VERSION}-linux-x64.rpm
RUN unset JAVA_VERSION
RUN yum clean all

#Maven
ENV MAVEN_VERSION 3.5.0
ENV MAVEN_HOME /opt/maven
#Maven Installation

RUN cd ~
RUN wget http://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /opt/maven 

#Set MAVEN_HOME in path

ENV PATH $MAVEN_HOME/bin:$PATH

#Cleanup

RUN rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# generate dummy keys, centos doesn't autogenerate them like ubuntu does

RUN /usr/bin/ssh-keygen -A

# Set SSH Configuration to allow remote logins without /proc write access

RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User

RUN useradd jenkins -m -s /bin/bash \
  && echo 'jenkins ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:jenkins' | chpasswd

# Add public key for Jenkins login ,this is only required if you are trying to connect to docker slave using ssh key, Copy the id_rsa.pub as authorized_keys and place it in the files directory before building the image
RUN mkdir /home/jenkins/.ssh
COPY /files/authorized_keys /home/jenkins/.ssh/authorized_keys
RUN chown -R jenkins /home/jenkins
RUN chgrp -R jenkins /home/jenkins
RUN chmod 600 /home/jenkins/.ssh/authorized_keys
RUN chmod 700 /home/jenkins/.ssh

# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
