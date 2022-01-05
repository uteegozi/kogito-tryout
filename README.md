# Kogito Try-out installation
The goal of this procedure is to simplify the deployment of an existing Kogito application on the Openshift platform.
This deployment includes both the required infrastructure and the Kogito application.

* The reference application is taken from [Kogito Travel Agency (extended)](https://github.com/kiegroup/kogito-examples/blob/stable/kogito-travel-agency/extended) 
* Few customizations might be needed to integrate with the deployed infrastructure, as detailed [here](#application-properties)
* The deployment is based on pre-built container images of the Kogito applications, according to the [instructions](#prepare-application-image) 
* The reference version of the Kogito platform is `1.14.0.Final`

## Prerequisites
- [Developer sandbox ](https://developers.redhat.com/developer-sandbox/get-started)  or other Openshift cluster
- oc cli installed
- helm cli installed

### Installable Infrastructure
- Infinispan via helm chart
- Kafka via helm chart

### Installable Kogito services
- Installed version: 1.14.0
- Data Index for Infinispan from image
- Management console from image

## Installation
- [prepare the Kogito application](#prepare-kogito-application)
- login to OCP cluster: `oc login ...`
- switch to project: `oc project "your project"`
- update `./installer.properties`
- run `./installer.sh`

## Removal of installation
- login to OCP cluster: `oc login ...`
- switch to project: `oc project "your project"`
- update `./installer.properties`
- run `./uninstaller.sh`

## Prepare Kogito application

### Prepare application image
Description uses kogito example `Kogito-Travel-Agency`
- Copy the properties required by the services and infrastructures that the Kogito application uses, 
into the `application.properties` file.
Properties are listed [below](#application-properties) per component. The following steps are described to build the image of
the [Travels](https://github.com/kiegroup/kogito-examples/blob/stable/kogito-travel-agency/extended/travels/) application:
- build the application: `mvn clean package`  
- build the image: `docker build -f src/main/docker/Dockerfile.jvm -t quarkus/kogito-travel-agency-travels-jvm .`  
- log into a image repository: `docker login quay.io`
- tag the local image for your chosen remote repository:
  `docker tag $(podman images | grep quarkus/kogito-travel-gency-travels-jvm | awk '{printf $3}') quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0` 
- push the tagged image: `docker push quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0`

The same steps must be repeated for the [Visas](https://github.com/kiegroup/kogito-examples/blob/stable/kogito-travel-agency/extended/visas)
application, or adapted to match the target application.

### Prepare application image installation
- copy domain svgs for the Kogito management console into the `./testapp/svg` folder 
(they are located under `target/classes/META-INF/processSVG/*`)
- copy protobuf files for Kogito data index to the `./testapp/protobuf` folder 
(they are located under `target/classes/META-INF/resources/persistence/protobuf/*.proto`)
- update `./testapp/testapp.sh` and any needed patch yaml files

### Installation of Kogito application
The application is installed together with the complete infrastructure 
when running the `./installer.sh`. 

To install the application separately, run `./testapp/testapp.sh install`

### Removal of Kogito application
The application is uninstalled together with the complete infrastructure
when running the `./uninstaller.sh`. 

To uninstall the application separately, run `./testapp/testapp.sh uninstall`

### Application Properties
The following properties are needed to connect the existing application to rge deployed infrastructure.

#### Infinispan
```
quarkus.infinispan-client.server-list=${QUARKUS_INFINISPAN_CLIENT_SERVER_LIST:"localhost:11222"}
quarkus.infinispan-client.auth-server-name=infinispan
quarkus.infinispan-client.auth-realm=default
quarkus.infinispan-client.auth-username=${QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME:"infiniusr"}
quarkus.infinispan-client.auth-password=${QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD:"infinipwd"}
quarkus.infinispan-client.sasl-mechanism=DIGEST-MD5
```
#### Kafka 
```
kafka.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS:"localhost:9092"}
```
#### Kogito Data-Index
```
kogito.dataindex.http.url=${KOGITO_DATAINDEX_HTTP_URL:"http://localhost:8180"}
kogito.dataindex.ws.url=${KOGITO_DATAINDEX_WS_URL:"ws://localhost:8180"}
```

## Validating Kafka topics
You can optionally run the following commands to deploy a new `kafka-client` Pod to verify the events sent to the
Kafka topics:

```shell
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:2.8.1-debian-10-r57 --namespace dmartino-test --command -- sleep infinity
kubectl exec --tty -i kafka-client --namespace dmartino-test -- bash
kafka-topics.sh --bootstrap-server kafka.dmartino-test.svc.cluster.local:9092 --list
```
The following are sample commands that you can use on the `kafka-client` shell to monitor some of the relevant topics:
```shell
kafka-console-consumer.sh  --bootstrap-server kafka.dmartino-test.svc.cluster.local:9092 --topic kogito-processinstances-events --from-beginning
kafka-console-consumer.sh  --bootstrap-server kafka.dmartino-test.svc.cluster.local:9092 --topic visaapplications --from-beginning
kafka-console-consumer.sh  --bootstrap-server kafka.dmartino-test.svc.cluster.local:9092 --topic visasresponses --from-beginning
```
