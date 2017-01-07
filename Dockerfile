FROM elasticsearch:5
MAINTAINER Bohyung kim https://github.com/dsdstudio

RUN apt-get update && apt-get install -yy gcc g++ make automake
RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz &&\
  tar xvf mecab-0.996-ko-0.9.2.tar.gz &&\
  cd /opt/mecab-0.996-ko-0.9.2 &&\
  ./configure &&\
  make &&\
  make check &&\
  make install &&\
  ldconfig

RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150920.tar.gz &&\
  tar xvf mecab-ko-dic-2.0.1-20150920.tar.gz &&\
  cd /opt/mecab-ko-dic-2.0.1-20150920 &&\
  ./autogen.sh &&\
  ./configure &&\
  make &&\
  make install

# Install user dic
ONBUILD COPY servicecustom.csv /opt/mecab-ko-dic-2.0.1-20150920/user-dic/servicecustom.csv
ONBUILD RUN cd /opt/mecab-ko-dic-2.0.1-20150920 &&\
  tools/add-userdic.sh &&\
  make install

# Add synonym
ONBUILD COPY synonym.txt /usr/share/elasticsearch/config/synonym.txt

ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8
RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-java/downloads/mecab-java-0.996.tar.gz &&\
  tar xvf mecab-java-0.996.tar.gz &&\
  cd /opt/mecab-java-0.996 &&\
  sed -i 's|/home/parallels/Programs/jdk1.7.0_75|/usr/lib/jvm/java-8-oracle|' Makefile &&\
  cat Makefile &&\
  make &&\
  cp libMeCab.so /usr/local/lib
RUN plugin install mobz/elasticsearch-head
RUN plugin install https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-5.1.1.0.zip

COPY config /usr/share/elasticsearch/config

VOLUME /usr/share/elasticsearch/data

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch"]
