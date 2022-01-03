## Application test

**Prerequisites**
- oc cli installed
- oc logged into OCP cluster
- oc project chosen

**To install an example application**
- copy domain svgs for the Kogito management console into the svg folder
- copy protobuf files for Kogito data index to the protobuf folder
- make sure that the test application image was build with the `application.properties` containing all 
properties needed for the current infrastructure - copy the properties from ../Readme.md App properties sections for each
infrastructure component present  
then
- if the infrastructure is already installed: run `./testapp.sh install`
- if the infrastructure is not yet installed: run `../installer.sh`

**To uninstall**
- the test application: run `./testapp.sh uninstall`
- the test application incl. the infrastructure: update `installer.properties`, run `../uninstaller.sh`