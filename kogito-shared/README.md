Any oc resources that more than one of the kogito services need and that can be shared between
several services.

PVC `kogito-app-pvc` is used by
- the data-index: folder `/home/kogito/data/protobufs` contains the application protobuf files
- the management console: folder `/home/kogito/data/svg` contains the application domain svgs

ConfigMap `kogito-configs` is used by all the kogito services and apps for their environment variables
