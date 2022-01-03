# Kogito Infra structure and service installation

## General
Installed version: Kogito example stable branch with Kogito dependencies version 1.8.0  

## Constraints
- Developer Sandbox does not allow to install additional operators - (https://www.youtube.com/watch?v=oDqw8aBGDD8 from 18.02.2021 - time: 9:09)
=> cannot use Kogito Operator install
- Developer Sandbox storage limit per cluster: 15Gi  
=> Kafka helm chart storage values set to 1Gi each (default is 8Gi)
- Developer Sandbox PVC limit per cluster: 5  
=> Created 1 PVC to be used by both Data-Index and Management Console
- Developer Sandbox service resource limit per cluster: 10  
=> suggestions to be validated: create more than 1 container in the same pod
Other limits: 7GB RAM, 2 namespaces

## Problems
**Frontend:** Uncaught TypeError: Cannot read properties of undefined (reading 'firstName')   
Path seems to be different than expected:   
**is:** data.parameters.traveller.firstName  
**expected:** data.traveller.firstName  

**Helm install infinispan:** redhat-charts/datagrid -f infinispan-values.yaml
Error: INSTALLATION FAILED: failed to download "redhat-charts/datagrid"
=> when checking repo, the directory for this chart is empty

**Infinispan Helm chart:** upgrade deletes the "Generated Secrets" resource
=> Either add manually (below) or remove/create Helm chart resource

## Components
### General
App properties: Properties defined under this section for each component need to be added to the 
application.properties file of the installed application if the component is part of the installation

### Infinispan
#### Installation

_**Install from OCP Sandbox via Helm chart**_
- Go to `Developer` view -> Helm -> search for `Infinispan` -> Click Release and choose `Install Helm Chart`
- [configuration of hotrod connector](https://access.redhat.com/documentation/en-us/red_hat_data_grid/7.0/html/administration_and_configuration_guide/sect-securing_interfaces)  
follow `Procedure 25.5. Configure Hot Rod Authentication (MD5)` and update config-map created during the helm installation
```
deploy: infinispan: server: endpoints: connectors:
            hotrod:
              hotrodConnector:
                authentication:
                  sasl:
                    mechanisms: DIGEST-MD5
                    qop: auth
                    serverName: infinispan
```

_**Install / Uninstall from local machine - automated procedure**_
Prerequisites
- helm client installed
- oc cli installed
- oc logged into OCP cluster

Scripts
- Install: ` ./infinispan/infinispan.sh install`
- Uninstall: ` ./infinispan/infinispan.sh uninstall`

**_Access Infinispan console_**  
- In OCP console, under the namespace infinispan was installed, look for the infinispan route. 
Click on the route and login with `developer` user (the password can be found in OCP secret `infinispan-generated-secret`)

#### App properties
```
quarkus.infinispan-client.server-list=${QUARKUS_INFINISPAN_CLIENT_SERVER_LIST:"localhost:11222"}
quarkus.infinispan-client.auth-server-name=infinispan
quarkus.infinispan-client.auth-realm=default
quarkus.infinispan-client.auth-username=${QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME:"infiniusr"}
quarkus.infinispan-client.auth-password=${QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD:"infinipwd"}
quarkus.infinispan-client.sasl-mechanism=DIGEST-MD5
```

#### Troubleshoot
When upgrading Helm through OCP, generated secret holding QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME and QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD is deleted
Note: when running chart again depending secret users need to also be updated
```
    env:
    - name: QUARKUS_INFINISPAN_CLIENT_SERVER_LIST
      value: "172.30.158.45:11222"
    - name: QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME
      value: "developer"
    - name: QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD
      value: "hdP9k3mM"
```

### Kafka 
#### Installation

_**Install / Uninstall from local machine - automated procedure**_
Prerequisites
- helm client installed
- oc cli installed
- oc logged into OCP cluster

Scripts
- Install: ` ./kafka/kafka.sh install`
- Uninstall: ` ./kafka/kafka.sh uninstall`

#### App properties
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

#### Sanity  
Using kafka pods terminal:
```
$ kafka-topics.sh --bootstrap-server=kafka-release.uegozi-dev.svc.cluster.local:9092 --list
kafka-topics.sh --bootstrap-server=kafka.uegozi-kogito.svc.cluster.local:9092 --list
# response should be:
__consumer_offsets
visasresponses

# after having run first travel request on the travels endpoint should see:
__consumer_offsets
kogito-processinstances-events
kogito-usertaskinstances-events
visasresponses
```

### Kogito Data-Index
#### Installation
```
oc new-app quay.io/kiegroup/kogito-data-index-infinispan:1.8.0 --env-file=data-index.env
oc expose service/kogito-data-index-infinispan

add  data index files to same claim like management console (limit of PVC is 5)
copy the protobufs
oc rsync ../docker-compose/target/protobuf/ kogito-data-index-infinispan-86bd889ff9-8fmr2:/home/kogito/data/protobufs

```
#### App properties
```
    env:
    - name: QUARKUS_INFINISPAN_CLIENT_SERVER_LIST
      value: "infinispan.uegozi-dev.svc.cluster.local:11222"
    - name: QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME
      value: "developer"
    - name: QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD
      value: "hdP9k3mM"
    - name: KAFKA_BOOTSTRAP_SERVERS
      value: 'kafka-release.uegozi-dev.svc.cluster.local:9092'
    - name: KOGITO_DATA_INDEX_PROPS
      value: '-Dkogito.protobuf.folder=/home/kogito/data/protobufs/'  

  volumeMounts:
    - name: protobufs
      mountPath: /home/kogito/data/protobufs    
volumes:
  - name: protobufs
    persistentVolumeClaim:
      claimName: domain-pics-pv-claim        
      
```
#### Sanity
browse to exposed route:
```
query example:
{
  ProcessInstances {
    id
  }
}
possible result:
{
  "data": {
    "ProcessInstances": [
      {
        "id": "a7630f9d-8747-41e8-9543-934fef7add1a"
      }
    ]
  }
}
```
Check that PVC is connected -> see "Documentation Explorer" on the right, see "Root Types", Query, Subscription

### Kogito Management Console
#### Installation
```
oc new-app quay.io/kiegroup/kogito-management-console:1.8.0
oc expose service/kogito-management-console

create 
domain-pics-pv-claim
copy the pics
oc rsync ../docker-compose/svg/ kogito-management-console-79c88dbf7c-mnv6m:/home/kogito/data/svg --no-perms
```
#### App properties
KOGITO_DATAINDEX_HTTP_URL: the route of the KOGITO_DATAINDEX installation
```
  env:
    - name: KOGITO_DATAINDEX_HTTP_URL
      value: 'http://kogito-data-index-infinispan-uegozi-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com'
    - name: KOGITO_MANAGEMENT_CONSOLE_PROPS
      value: '-Dkogito.svg.folder.path=/home/kogito/data/svg'
  volumeMounts:
    - name: domain-pics
      mountPath: /home/kogito/data/svg    
volumes:
  - name: domain-pics
    persistentVolumeClaim:
      claimName: domain-pics-pv-claim          
```
#### Sanity
browse to exposed route:
Check that PVC is connected -> click: Process Instances -> click into one instance -> see process diagram

#### Errors
- click: Process Instances -> click on "Endpoint" link under one instance (id column) => invalid url
- click: Process Instances -> click into one instance (id column) => error message

### Travel and Visa Applications
Build the images as described in the Dockerfile.jvm
Tag and push the images to a public repository e.g. quay.io
Create a new deployment
Expose a route
Update Env parameters in the deployments yaml
Update ports (why are those autocreated? 8778 and 9779) => update 8778 port to 8080 for travels and 8090 for visas  
```
podman login quay.io
podman tag <IMAGE_ID> quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0
podman push quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0
oc new-app quay.io/uegozi/kogito-travel-agency-travels-jvm:1.0.0 
oc expose service/kogito-travel-agency-travels-jvm


podman tag <IMAGE_ID> quay.io/uegozi/kogito-travel-agency-visas-jvm:1.0.0
podman push quay.io/uegozi/kogito-travel-agency-visas-jvm:1.0.0
oc new-app quay.io/uegozi/kogito-travel-agency-visas-jvm:1.0.0 
oc expose service/kogito-travel-agency-visas-jvm
**********
env:
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: 'kafka-release.uegozi-dev.svc.cluster.local:9092'
  - name: QUARKUS_INFINISPAN_CLIENT_SERVER_LIST
    value: 'infinispan.uegozi-dev.svc.cluster.local:11222'
  - name: QUARKUS_INFINISPAN_CLIENT_AUTH_USERNAME
    value: developer
  - name: QUARKUS_INFINISPAN_CLIENT_AUTH_PASSWORD
    value: hdP9k3mM
  - name: KOGITO_DATAINDEX_HTTP_URL
    value: >-
      http://kogito-data-index-infinispan-uegozi-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com
  - name: KOGITO_DATAINDEX_WS_URL
    value: >-
      ws://kogito-data-index-infinispan-uegozi-dev.apps.sandbox-m2.ll9k.p1.openshiftapps.com  
```
### Check installation
```
curl -H "Content-Type: application/json" -H "Accept: application/json" -X POST http://localhost:8080/travels -d '{"traveller" : {"firstName" : "Jan","lastName" : "Kowalski","email" :"jan.kowalski@example.com","nationality" : "Polish","address" : {"street" : "polna","city" : "Krakow","zipCode" : "32000","country" : "Poland"}},"trip" : {"city" : "New York","country" : "US","begin" : "2019-12-10T00:00:00.000+02:00","end" : "2019-12-15T00:00:00.000+02:00"	}}'
```

#### Troubleshoot
```
# check if app is up directly from pod terminal:
curl -H "Content-Type: application/json" -H "Accept: application/json" -X POST http://localhost:8080/travels -d '{"traveller" : {"firstName" : "Jan","lastName" : "Kowalski","email" :"jan.kowalski@example.com","nationality" : "Polish","address" : {"street" : "polna","city" : "Krakow","zipCode" : "32000","country" : "Poland"}},"trip" : {"city" : "New York","country" : "US","begin" : "2019-12-10T00:00:00.000+02:00","end" : "2019-12-15T00:00:00.000+02:00"	}}'
```
### Prometheus/Grafana


## Suggestions
- install 1+ containers per pod
- create install pod that orchestrates the install (e.g. simple yaml install - saving the user to install oc locally)
would need way to let user choose example to install