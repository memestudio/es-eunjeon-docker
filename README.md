# es-eunjeon-docker

- oracle jdk 1.8
- elasticsearch 2.3.1
- eunjeon-elasticsearch 

## sample docker-compose.yml

```
elasticsearch: 
  build: elastic
  command: "/docker-entrypoint.sh -Djava.library.path=/usr/local/lib -Des.security.manager.enabled=false"
  ports:
    - "9200:9200"
    - "9300:9300"
  expose:
    - "9200"
    - "9300"
```
