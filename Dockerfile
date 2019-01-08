# The MIT License
#
#  Copyright (c) 2015-2017, CloudBees, Inc. and other Jenkins contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM openjdk:8-jdk
MAINTAINER Andrew Elliott <aelliot@embotics.com>

ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
RUN echo 'jenkins:screencast' | chpasswd
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="3.14"

ARG VERSION=3.14
ARG AGENT_WORKDIR=/home/jenkins/agent

RUN apt-get update -y
RUN apt-get install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

RUN mkdir -p /home/jenkins/.ivy2 \
  && chown jenkins:jenkins /home/jenkins/.ivy2

ENV ANT_HOME='/apache-ant-1.10.1'
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.10.1-bin.tar.gz \
  && tar -zxvf apache-ant-1.10.1-bin.tar.gz \
  && ln -s /apache-ant-1.10.1/bin/ant /usr/local/bin/ant && rm -rf apache-ant-1.10.1-bin.tar.gz

RUN wget https://nodejs.org/download/release/v8.9.2/node-v8.9.2-linux-x64.tar.gz \
  && tar -zxvf node-v8.9.2-linux-x64.tar.gz \
  && ln -s /node-v8.9.2-linux-x64/bin/node /usr/local/bin/node \
  && ln -s /node-v8.9.2-linux-x64/bin/npm /usr/local/bin/npm \
  && ln -s /node-v8.9.2-linux-x64/bin/npmx /usr/local/bin/npmx \
  && rm -rf node-v8.9.2-linux-x64.tar.gz

USER jenkins
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/jenkins/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/jenkins

USER root
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
