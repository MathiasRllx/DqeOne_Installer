global with sharing class CheckMetadata {

    public static Boolean checkConnectedApp() {
        try {
            ConnectedApplication[] ca = [SELECT name FROM ConnectedApplication WHERE name='connected_app_dqe_one'];
            
            if (ca.IsEmpty() == true) {
                system.debug('ConnectedApp Do not exist');
                return false;
            }
            return true;
        } catch(DmlException e) {
            throw e;
        }
    }

    public static Boolean checkAuthProvider() {
        try {
            AuthProvider[] ap = [SELECT DeveloperName FROM AuthProvider WHERE DeveloperName='AuthProviderDqeOne'];
            
            if (ap.IsEmpty() == true) {
                system.debug('Auth Provider Do not exist');
                return false;
            }
            return true;
        } catch(DmlException e) {
            throw e;
        }
    }

    public static Boolean checkNamedCredential() {
        try {
            NamedCredential[] nc = [SELECT DeveloperName FROM NamedCredential WHERE DeveloperName='Customer_Dqe_One'];

            if (nc.IsEmpty() == true) {
                system.debug('Named Credential Do not exist');
                return false;
            }
            return true;
        } catch(DmlException e) {
            throw e;
        }
    }

    public static Boolean checkConsumerKeySecret() {
        try {
            dqe_test__DQE_ONE__mdt installationData = dqe_test__DQE_ONE__mdt.getInstance('InstallationData');
            if (installationData.dqe_test__ConsumerKey__c == null || installationData.dqe_test__ConsumerSecret__c == null) {
                system.debug('Consumer Key Secret Do not exist');
                return false;
            }
            return true;
        } catch(DmlException e) {
            throw e;
        }
    }
}
