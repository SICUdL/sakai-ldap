FROM maven:3.8.6-jdk-11 as build

ARG release=master

COPY lib/settings.xml /usr/share/maven/conf/settings.xml
RUN mkdir /deploy
WORKDIR /deploy
RUN git clone https://github.com/sakaiproject/sakai.git
WORKDIR /deploy/sakai
RUN git checkout ${release}
RUN sed -i 's|<!--  import resource="unboundid-ldap\.xml" / -->|<import resource="unboundid-ldap\.xml"/>|g' providers/component/src/webapp/WEB-INF/components.xml
RUN mvn clean install sakai:deploy -Dmaven.test.skip=true


FROM tomcat:9.0.20-jre11

COPY certs/server.der /usr/local/tomcat/server.der
COPY lib/server.xml /usr/local/tomcat/conf/server.xml
COPY lib/context.xml /usr/local/tomcat/conf/context.xml
COPY --from=build /deploy/components /usr/local/tomcat/components/
COPY --from=build /deploy/lib /usr/local/tomcat/sakai-lib/
COPY --from=build /deploy/webapps /usr/local/tomcat/webapps/

RUN mkdir -p /usr/local/sakai/properties

ENV CATALINA_OPTS_MEMORY -Xms2000m -Xmx2000m
ENV CATALINA_OPTS \
-server \
-verbose:gc -XX:+PrintGCDetails -XX:+UseConcMarkSweepGC \
-Djava.awt.headless=true \
-Dsun.net.inetaddr.ttl=0 \
-Dsakai.component.shutdownonerror=true \
-Duser.language=en -Duser.country=US \
-Dsakai.home=/usr/local/sakai/properties -Dsakai.security=/usr/local/tomcat/sakai \
-Duser.timezone=US/Eastern \
-Dsun.net.client.defaultConnectTimeout=300000 \
-Dsun.net.client.defaultReadTimeout=1800000 \
-Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false \
-Dsun.lang.ClassLoader.allowArraySyntax=true \
-Dhttp.agent=Sakai \
-Djava.util.Arrays.useLegacyMergeSort=true 

RUN sed -i '/^common.loader\=/ s/$/,"\$\{catalina.base\}\/sakai-lib\/*.jar"/' /usr/local/tomcat/conf/catalina.properties

RUN curl -L -o /usr/local/tomcat/lib/mysql-connector-java-4.1.47.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar

RUN keytool -import -trustcacerts -cacerts -storepass changeit -noprompt -file /usr/local/tomcat/server.der
RUN mkdir -p /usr/local/tomcat/sakai
COPY lib/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
