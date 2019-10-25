FROM arm32v7/ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y -q \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    git \
    wget \
    curl \
    gnupg \
    tzdata \
    maven \
    openjdk-11-jdk \
    vim \
    less \
    procps \
    unzip \
    wget \
    npm \
    grunt \
    ffmpeg \
    mediainfo \
    tesseract-ocr \
    tesseract-ocr-fra \
    tesseract-ocr-ita \
    tesseract-ocr-kor \
    tesseract-ocr-rus \
    tesseract-ocr-ukr \
    tesseract-ocr-spa \
    tesseract-ocr-ara \
    tesseract-ocr-hin \
    tesseract-ocr-deu \
    tesseract-ocr-pol \
    tesseract-ocr-jpn \
    tesseract-ocr-por \
    tesseract-ocr-tha \
    tesseract-ocr-jpn \
    tesseract-ocr-chi-sim \
    tesseract-ocr-chi-tra \
    tesseract-ocr-nld \
    tesseract-ocr-tur \
    tesseract-ocr-heb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure settings
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# get files simics/ubuntu
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    git clone https://github.com/sismics/docker-ubuntu.git && \
    cp -r docker-ubuntu/etc /etc && \
    rm -r docker-ubuntu && \
    echo "for f in \`ls /etc/bashrc.d/*\`; do . \$f; done;" >> ~/.bashrc

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-armhf/
ENV JAVA_OPTS -Duser.timezone=UTC -Dfile.encoding=UTF-8 -Xmx512m

ENV JETTY_VERSION 9.4.12.v20180830
RUN wget -nv -O /tmp/jetty.tar.gz \
    "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz" \
    && tar xzf /tmp/jetty.tar.gz -C /opt \
    && mv /opt/jetty* /opt/jetty \
    && useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /opt/jetty \
    && chmod +x /opt/jetty/bin/jetty.sh

# Init configuration and get files from sismics/ubuntu-java
RUN git clone https://github.com/sismics/docker-ubuntu-jetty.git && \
    cp -r docker-ubuntu-jetty/opt /opt && \
    rm -r docker-ubuntu-jetty

ENV JETTY_HOME /opt/jetty
ENV JAVA_OPTIONS -Xmx512m

# Remove the embedded javax.mail jar from Jetty and get files from sismics/docs
RUN rm -f /opt/jetty/lib/mail/javax.mail.glassfish-*.jar && \
    git clone https://github.com/sismics/docs.git /tmp/docs && \
    cp /tmp/docs/docs.xml /opt/jetty/webapps/docs.xml
WORKDIR /tmp/docs
RUN mvn -Pprod -DskipTests clean install && \
    cp docs-web/target/docs-web-*.war /opt/jetty/webapps/docs.war

# Set the default command to run when starting the container
WORKDIR /opt/jetty
EXPOSE 8080
CMD ["bin/jetty.sh", "run"]