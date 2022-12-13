global with sharing class PushMetadata { // NOPMD

    @Future(callout=true)
    public static void pushRemoteSiteSettings() {
        system.debug('Push Remote Site Settings');

        try {
            MetadataService.RemoteSiteSetting remoteSiteSettingsAuthProvider = new MetadataService.RemoteSiteSetting();

            remoteSiteSettingsAuthProvider.fullName = 'AuthProviderRemote';
            remoteSiteSettingsAuthProvider.url = 'https://dqesoftware4-dev-ed.my.salesforce.com/services/data/v54.0/sobjects/AuthProvider/';
            remoteSiteSettingsAuthProvider.isActive=true;
            remoteSiteSettingsAuthProvider.disableProtocolSecurity=false;

            if (!Test.isRunningTest()) {
                system.debug(MetadataService.createMetadata(remoteSiteSettingsAuthProvider)); // NOPMD
            }
            Process.sendEvent('Consumer Key Secret');
            Process.updateMetadata('InstallationStatus__c', 'Remote Site Settings');
        } catch(DmlException e) {
            throw e;
        }
    }

    @Future(callout=true)
    public static void pushAuthProvider(String consumerKey, String consumerSecret) { // NOPMD
        system.debug('Push Auth Provider');
        try {
            final String appUrl = URL.getSalesforceBaseUrl().toExternalForm();  
            String authProviderData = '{ "AuthorizeUrl": "' + appUrl + '/services/oauth2/authorize", "ConsumerKey": "'+ consumerKey + '", "ConsumerSecret": "'+ consumerSecret + '", "DeveloperName": "AuthProviderDqeOne", "FriendlyName": "AuthProviderDqeOne", "ProviderType": "Salesforce"}';
    
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(appUrl + '/services/data/v54.0/sobjects/AuthProvider/');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); // NOPMD
            req.setHeader('Content-Type', 'application/json');
            req.setBody(authProviderData);
            Http binding = new Http();

            if (!Test.isRunningTest()) {
                HttpResponse response = binding.send(req);
                system.debug(response);
            }

            Process.sendEvent('Named Credential');
            Process.updateMetadata('InstallationStatus__c', 'Auth Provider');
        } catch(DmlException e) {
            throw e;
        }
    }   

    @Future(callout=true)
    public static void pushConnectedApp(String consumerKey, String consumerSecret) {
        system.debug('push Connected App');

        final String userName = UserInfo.getUserName();
        final String userEmail = [Select Email From User where Username = : userName limit 1].Email;

        try {
            MetadataService.ConnectedApp connectedApp = new MetadataService.ConnectedApp();
            connectedApp.contactEmail = userEmail;
            connectedApp.fullName = 'DQE_ONE';
            connectedApp.label = 'connected_app_dqe_one';

            MetadataService.ConnectedAppOauthConfig connectedAppOauthConfig = new MetadataService.ConnectedAppOauthConfig();
            connectedAppOauthConfig.consumerKey = consumerKey;
            connectedAppOauthConfig.consumerSecret = consumerSecret;
            connectedAppOauthConfig.callbackUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/authcallback/AuthProviderDqeOne';
            connectedAppOauthConfig.scopes = new List<String>();
            connectedAppOauthConfig.scopes.add('Full');
            connectedAppOauthConfig.scopes.add('RefreshToken');
            connectedAppOauthConfig.scopes.add('OfflineAccess');
            ConnectedApp.oauthConfig = connectedAppOauthConfig;

            if (!Test.isRunningTest()) {
                system.debug(MetadataService.createMetadata(ConnectedApp));
            }

            Process.sendEvent('Auth Provider');
            Process.updateMetadata('InstallationStatus__c', 'Connected App');
        } catch(DmlException e) {
            throw e;
        }
    }

    @Future(callout=true)
    public static void pushNamedCredential(string url) {
        system.debug('Push Named Credential');

        try {
            MetadataService.NamedCredential credential = new MetadataService.NamedCredential();
            credential.label = 'Customer DQE One';
            credential.fullName = 'Customer_Dqe_One';
            credential.endpoint = url;
            credential.principalType = 'NamedUser';
            credential.protocol = 'Oauth'; 
            credential.authProvider = 'AuthProviderDqeOne';
            credential.oauthScope = 'full refresh_token offline_access';
            credential.allowMergeFieldsInHeader = true;
            credential.allowMergeFieldsInBody = true;
            credential.generateAuthorizationHeader = true;
            
            if (!Test.isRunningTest()) {
                system.debug(MetadataService.createMetadata(credential));
            }

            Process.sendEvent('Installed');
            Process.updateMetadata('InstallationStatus__c', 'Installed');
        } catch(DmlException e) {
            throw e;
        }
    }

    public static Metadata.DeployContainer pushConsumerKeySecret(String consumerKey, String consumerSecret) {
        system.debug('Push Consumer Keys and Secret');

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'dqe_test__DQE_ONE__mdt.InstallationData'; 
        customMetadata.label = 'InstallationData';
        customMetadata.protected_x = true;

        Metadata.CustomMetadataValue customFieldConsumerKey = new Metadata.CustomMetadataValue();   
        customFieldConsumerKey.field = 'ConsumerKey__c';
        customFieldConsumerKey.value = consumerKey;
        customMetadata.values.add(customFieldConsumerKey);

        Metadata.CustomMetadataValue customFieldConsumerSecret = new Metadata.CustomMetadataValue(); 
        customFieldConsumerSecret.field = 'ConsumerSecret__c' ;
        customFieldConsumerSecret.value = consumerSecret;
        customMetadata.values.add(customFieldConsumerSecret);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        CallbackConsumerKeySecret callback = new CallbackConsumerKeySecret();

        if (!Test.isRunningTest()) {
            Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
        return mdContainer;
    }

    @Future(callout=true)
    public static void uninstallation() {
        system.debug('Start Uninstallation');

        try {
            if (!Test.isRunningTest()) {

                system.debug(MetadataService.createService().deleteMetadata('RemoteSiteSetting', new String[] { 'dqe_test__AuthProviderRemote' }));
                system.debug(MetadataService.createService().deleteMetadata('RemoteSiteSetting', new String[] { 'dqe_test__LoginRemote' }));
                system.debug(MetadataService.createService().deleteMetadata('ConnectedApp', new String[] { 'dqe_test__DQE_ONE' })); 
                system.debug(MetadataService.createService().deleteMetadata('AuthProvider', new String[] { 'AuthProviderDqeOne' }));
                system.debug(MetadataService.createService().deleteMetadata('NamedCredential', new String[] { 'dqe_test__Customer_Dqe_One' }));
                
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                customMetadata.fullName = 'dqe_test__DQE_ONE__mdt.InstallationData'; 
                customMetadata.label = 'InstallationData';
                customMetadata.protected_x = true;

                Metadata.CustomMetadataValue customFieldInstalationStatus = new Metadata.CustomMetadataValue();   
                customFieldInstalationStatus.field = 'InstallationStatus__c';
                customFieldInstalationStatus.value = 'Not Installed';
                customMetadata.values.add(customFieldInstalationStatus);

                Metadata.CustomMetadataValue customFieldConsumerKey = new Metadata.CustomMetadataValue();   
                customFieldConsumerKey.field = 'ConsumerKey__c';
                customFieldConsumerKey.value = '';
                customMetadata.values.add(customFieldConsumerKey);

                Metadata.CustomMetadataValue customFieldConsumerSecret = new Metadata.CustomMetadataValue();   
                customFieldConsumerSecret.field = 'ConsumerSecret__c';
                customFieldConsumerSecret.value = '';
                customMetadata.values.add(customFieldConsumerSecret);
        
                Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                mdContainer.addMetadata(customMetadata);
                Metadata.Operations.enqueueDeployment(mdContainer, null);
            }
        } catch(DmlException e) {
                throw e;
        }
    }
}