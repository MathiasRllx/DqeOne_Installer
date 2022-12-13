public class CallbackConsumerKeySecret implements Metadata.DeployCallback {

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        try {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                Process.sendEvent('Connected App');
                Process.updateMetadata('InstallationStatus__c', 'Custom Metadata');
            } 
            else {
                Process.sendEvent('Error deploying the Consumer Key and Consumer Secret');
                throw new DmlException('Error deploying the Consumer Key and Consumer Secret');
            }
        } catch(DmlException e) {
            throw e;
        }
    }
}