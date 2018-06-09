FROM centos:7

MAINTAINER Sergii Rolskyi

ENV ELASTIC_VERSION 5.5.1

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk

# Install Java and the "which" command, which is needed by Logstash's shell
RUN yum update -y && yum install -y java-1.8.0-openjdk-devel wget which ruby git && \
yum clean all

# Provide a non-root user to run the process.
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home-dir /usr/share/logstash --no-create-home \
      logstash

# Add Logstash itself.
WORKDIR /usr/share/logstash

RUN wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-${ELASTIC_VERSION}.tar.gz && \
    tar zxf logstash-${ELASTIC_VERSION}.tar.gz && \
    chown -R logstash:logstash logstash-${ELASTIC_VERSION} && \
    mv logstash-${ELASTIC_VERSION}/* . && \
    rmdir logstash-${ELASTIC_VERSION} && \
    rm logstash-${ELASTIC_VERSION}.tar.gz 



# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
#ADD config/logstash.yml config/logstash.yml
ADD config/log4j2.properties config/
#ADD pipeline/default.conf pipeline/logstash.conf
#RUN chown --recursive logstash:logstash config/ pipeline/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
#ADD bin/docker-entrypoint /usr/local/bin/
#RUN chmod 0755 /usr/local/bin/docker-entrypoint
ADD bin/logstash-docker /usr/local/bin/
RUN chmod 0755 /usr/local/bin/logstash-docker

USER root

RUN cd /usr/share/logstash && logstash-plugin install logstash-filter-translate && logstash-plugin install logstash-filter-json_encode && logstash-plugin install logstash-filter-prune && logstash-plugin install x-pack

EXPOSE 9600 5044

#ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

CMD [ "/bin/bash", "/usr/local/bin/logstash-docker" ]


