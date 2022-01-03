## Kogito Try-out installation

**Prerequisites**
- oc cli installed
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
- oc login
- oc project <your project>
- update `./installer.properties`
- run `./installer.sh`

**To uninstall**
- oc login
- oc project <your project>
- update `./installer.properties`
- run `./uninstaller.sh`