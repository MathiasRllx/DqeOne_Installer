@isTest
private class PushMetadataTest {

    @isTest static void pushRemoteSiteSettingsTest() {
        Test.startTest();
        try {
            PushMetadata.pushRemoteSiteSettings();
        } catch(DmlException e) {
            system.assert(false, e);
        }
        Test.stopTest();
    }

    @isTest static void pushConnectedAppTest() {
  
        final string consumerKey = 'D6C25EF7BA4AA01733F817C9B6CB194347198AC9D3BE79A0';
        final string consumerSecret = '4D5D29DC25F27AE2A671EDDDCDA4B842B31A837545157389';

        Test.startTest();
        try {
            PushMetadata.pushConnectedApp(consumerKey, consumerSecret);
        } catch(DmlException e) {
            system.assert(false, e);
        }
        Test.stopTest();
    }

    @isTest static void pushNamedCredentialTest() {
        Test.startTest();
        try {
            PushMetadata.pushNamedCredential('www.randomUrl.com');
        } catch(DmlException e) {
            system.assert(false, e);
        }
        Test.stopTest();
    }

    @isTest static void pushConsumerKeySecretTest() {
        final string consumerKey = 'D6C25EF7BA4AA01733F817C9B6CB194347198AC9D3BE79A0';
        final string consumerSecret = '4D5D29DC25F27AE2A671EDDDCDA4B842B31A837545157389';

        Metadata.DeployContainer container = PushMetadata.pushConsumerKeySecret(consumerKey, consumerSecret);
       
        List<Metadata.Metadata> contents = container.getMetadata();
        System.assertEquals(1, contents.size());

        Metadata.CustomMetadata md = (Metadata.CustomMetadata) contents.get(0);
        System.assertEquals('dqe_test__DQE_ONE__mdt.ConsumerKeySecret', md.fullName);
        System.assertEquals(consumerKey, md.values[0].value);
        System.assertEquals(consumerSecret, md.values[1].value);
    }

    @isTest static void uninstallationTest() {

        Test.startTest();
        try {
            PushMetadata.uninstallation();
        } catch (DmlException e) {
            system.assert(false, e);
        }
        Test.stopTest();
    }
}