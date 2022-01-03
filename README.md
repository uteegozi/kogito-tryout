## Kogito Try-out installation

**Prerequisites**
- oc cli installed
- oc logged into OCP cluster
- oc project chosen
- helm cli installed

**Installed Infrastructure**
- Infinispan via helm chart
- Kafka via helm chart

**Installed Kogito services**
- Installed version: 1.8.0
- Data Index for Infinispan from image
- Management console from image

**Installed Kogito Test Application**
- Kogito Travel and Visa example from image

**To install**
- update `./installer.properties`
- run `./installer.sh`

**To uninstall**
- update `./installer.properties`
- run `./uninstaller.sh`