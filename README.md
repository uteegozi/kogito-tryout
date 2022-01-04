## Kogito Try-out installation

### Prerequisites
- [Developer sandbox ](https://developers.redhat.com/developer-sandbox/get-started)  or other Openshift cluster
- oc cli installed
- helm cli installed

#### Installable Infrastructure
- Infinispan via helm chart
- Kafka via helm chart

#### Installable Kogito services
- Installed version: 1.8.0
- Data Index for Infinispan from image
- Management console from image

### Installation
- login to OCP cluster: `oc login ...`
- switch to project: `oc project "your project"`
- update `./installer.properties`
- [prepare the Kogito application](#prepare-kogito-application)
- run `./installer.sh`

### Removal of installation
- login to OCP cluster: `oc login ...`
- switch to project: `oc project "your project"`
- update `./installer.properties`
- run `./uninstaller.sh`

## Prepare Kogito application

### Prepare application image
Description uses kogito example "Kogito-Travel-Agency" 
- Copy the properties required by the services and infrastructures that the Kogito application uses, 
into the application.properties file.
Properties are listed [below](#application-properties) per component.
- build the application: `mvn package`  
- build the image: `docker build -f src/main/docker/Dockerfile.jvm -t quarkus/kogito-travel-agency-travels-jvm .`  
- log into a image repository: `podman login quay.io`  
- tag the local image for your chosen remote repository: `imageId=$(podman images | grep quarkus/kogito-travel-gency-travels-jvm | awk '{printf $3}')
  podman tag "${imageId}" quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0`
- push the tagged image: `podman push quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0`

### Prepare application image installation
- copy domain svgs for the Kogito management console into the `./testapp/svg` folder
- copy protobuf files for Kogito data index to the `./testapp/protobuf` folder
- update `./testapp/testapp.sh` and any needed patch yaml files

### Installation of Kogito application
The application is installed together with the complete infrastructure 
when running the `./installer.sh`. To install the application separately, run `./testapp.sh install`

### Removal of Kogito application
The application is uninstalled together with the complete infrastructure
when running the `./uninstaller.sh`. To uninstall the application separately, run `./testapp.sh uninstall`

### Application Properties
#### Kogito Application
```
kogito.service.url=http://localhost:8080  ????S
```
#### Infinispan
```
quarkus.infinispan-client.server-list=${QUARKUS_INFINISPAN_CLIENT_SERVER_LIST:"localhost:11222"}
quarkus.infinispan-client.auth-server-name=infinispan
quarkus.infinispan-client.auth-realm=default
quarkus.infinispan-client.auth-username=${QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME:"infiniusr"}
quarkus.infinispan-client.auth-password=${QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD:"infinipwd"}
quarkus.infinispan-client.sasl-mechanism=DIGEST-MD5
```
### Kafka 
```
kafka.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS:"localhost:9092"}

# main transport
mp.messaging.incoming.kogito_incoming_stream.connector=smallrye-kafka
mp.messaging.incoming.kogito_incoming_stream.topic=visasresponses
mp.messaging.incoming.kogito_incoming_stream.value.deserializer=org.apache.kafka.common.serialization.StringDeserializer

mp.messaging.outgoing.kogito_outgoing_stream.connector=smallrye-kafka
mp.messaging.outgoing.kogito_outgoing_stream.topic=visaapplications
mp.messaging.outgoing.kogito_outgoing_stream.value.serializer=org.apache.kafka.common.serialization.StringSerializer

# metadata
mp.messaging.outgoing.kogito-processinstances-events.connector=smallrye-kafka
mp.messaging.outgoing.kogito-processinstances-events.topic=kogito-processinstances-events
mp.messaging.outgoing.kogito-processinstances-events.value.serializer=org.apache.kafka.common.serialization.StringSerializer

mp.messaging.outgoing.kogito-usertaskinstances-events.connector=smallrye-kafka
mp.messaging.outgoing.kogito-usertaskinstances-events.topic=kogito-usertaskinstances-events
mp.messaging.outgoing.kogito-usertaskinstances-events.value.serializer=org.apache.kafka.common.serialization.StringSerializer

mp.messaging.outgoing.kogito-variables-events.connector=smallrye-kafka
mp.messaging.outgoing.kogito-variables-events.topic=kogito-variables-events
mp.messaging.outgoing.kogito-variables-events.value.serializer=org.apache.kafka.common.serialization.StringSerializer
```
### Kogito Data-Index
```
kogito.dataindex.http.url=${KOGITO_DATAINDEX_HTTP_URL:"http://localhost:8180"}
kogito.dataindex.ws.url=${KOGITO_DATAINDEX_WS_URL:"ws://localhost:8180"}
```