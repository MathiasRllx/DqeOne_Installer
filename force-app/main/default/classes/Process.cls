public with sharing class Process {

    @AuraEnabled
    public static String getRandom() {
        Blob aesKey = Crypto.GenerateAESKey(192);
        String key = EncodingUtil.ConvertTohex(aesKey);

        key = key.toUpperCase();
        return key;
    }

    @AuraEnabled
    public static void checkInstallationStatus() {
        dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');
        string status = installationData.dqe_test__installationStatus__c;

        switch on status {
            when 'Not Installed' {
                Process.sendEvent('Remote Site Settings');
            }
            when 'Remote Site Settings' {
                Process.sendEvent('Consumer Key Secret');
            }
            when 'Custom Metadata' {
                if (CheckMetadata.checkConsumerKeySecret() == false) {
                    Process.sendEvent('Error Consumer Key');
                }
                else {
                    Process.sendEvent('Connected App');
                }
            }
            when 'Connected App' {
                if (CheckMetadata.checkConsumerKeySecret() == false || CheckMetadata.checkConnectedApp() == false) {
                    Process.sendEvent('Error Connected App');
                }
                else {
                   Process.sendEvent('Auth Provider');
                }
            }
            when 'Auth Provider' {
                if (CheckMetadata.checkConsumerKeySecret() == false || CheckMetadata.checkConnectedApp() == false || CheckMetadata.checkAuthProvider() == false) {
                    Process.sendEvent('Error Auth Provider');
                }
                else {
                    Process.sendEvent('Named Credential');
                }
            }
            when 'Installed' {
                if (CheckMetadata.checkConsumerKeySecret() == false || CheckMetadata.checkConnectedApp() == false || CheckMetadata.checkAuthProvider() == false || CheckMetadata.checkNamedCredential() == false) {
                    Process.sendEvent('Error Installed');
                }
                else {
                    Process.sendEvent('Installed');
                }
            }
            when else {
                system.debug('Error unknow status');
            }
        }
    }

    @AuraEnabled
    public static string getMetadata(string metadataName){
        try {
            dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');
            string currentValue = (string)installationData.get(metadataName);

            return currentValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateMetadata(string metadataName, string value) {
        try {
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'dqe_test__DQE_ONE__mdt.InstallationData'; 
            customMetadata.label = 'InstallationData';
            customMetadata.protected_x = true;

            Metadata.CustomMetadataValue customFieldStatus = new Metadata.CustomMetadataValue();   
            customFieldStatus.field = metadataName;
            customFieldStatus.value = value;
            customMetadata.values.add(customFieldStatus);

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);

            Metadata.Operations.enqueueDeployment(mdContainer, null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean sendEvent(String step) {
        List<dqe_test__DqeOneEvent__e> inkEvents = new List<dqe_test__DqeOneEvent__e>();
        dqe_test__DqeOneEvent__e event = new dqe_test__DqeOneEvent__e();

        event.dqe_test__InstallationStep__c = step;
        inkEvents.add(event);

        List<Database.SaveResult> results = EventBus.publish(inkEvents);
        return results[0].isSuccess();
    }

    @AuraEnabled
    public static void processNamedCredential(string url) {
        try {
            PushMetadata.pushNamedCredential(url);
        } catch(DmlException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void processAuthProvider() {
        try {
            dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');

            final String consumerKey = installationData.dqe_test__ConsumerKey__c;
            final String consumerSecret = installationData.dqe_test__consumerSecret__c;

            PushMetadata.pushAuthProvider(consumerKey, consumerSecret);

        } catch(DmlException e) {
            throw e;
        }
    }
    
    @AuraEnabled
    public static void processConnectedApp() {
        try {
            dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');

            final String consumerKey = installationData.dqe_test__ConsumerKey__c;
            final String consumerSecret = installationData.dqe_test__consumerSecret__c;

            PushMetadata.pushConnectedApp(consumerKey, consumerSecret);
        } catch(DmlException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void processConsumerKeySecret() {
        try {
            dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');

            final String consumerKey = (installationData.dqe_test__ConsumerKey__c == null ? getRandom() : installationData.dqe_test__ConsumerKey__c);
            final String consumerSecret = (installationData.dqe_test__consumerSecret__c == null ? getRandom() : installationData.dqe_test__consumerSecret__c);

            PushMetadata.pushConsumerKeySecret(consumerKey, consumerSecret);
        } catch(DmlException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void processRemoteSiteSettings() {
        try {
            PushMetadata.pushRemoteSiteSettings();
        } catch(DmlException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void uninstallProcess() {
        try {
            PushMetadata.uninstallation();
        } catch(DmlException e) {
            throw e;
        }
    }

    @AuraEnabled
    public static void processCheckMetadataManual(String step) {
        try {
            switch on step {
                when 'Connected App' {
                    if (CheckMetadata.checkConnectedApp() == false) {
                        Process.sendEvent('Error Connected App');
                    }
                    else {
                        Process.sendEvent('Auth Provider');
                    }
                }
                when 'Auth Provider' {
                    if (CheckMetadata.checkConnectedApp() == false || CheckMetadata.checkAuthProvider() == false) {
                        Process.sendEvent('Error Auth Provider');
                    }
                    else {
                        Process.sendEvent('Named Credential');
                    }
                }
                when 'Named Credential' {
                    if (CheckMetadata.checkConnectedApp() == false || CheckMetadata.checkAuthProvider() == false || CheckMetadata.checkNamedCredential() == false) {
                        Process.sendEvent('Error Named Credential');
                    }
                    else {
                        Process.sendEvent('Installed');
                    }
                }
                when else {
                    Process.sendEvent('Error Step Unknown');
                }
            }
        } catch(DmlException e) {
            throw e;
        }
    }
}