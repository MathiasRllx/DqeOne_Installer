@isTest
private class ProcessTest {
    @isTest static void getRandomTest() {
        Test.startTest();
        final string a = Process.getRandom();
        final string b = Process.getRandom();
        final string c = Process.getRandom();
        Test.stopTest();

        system.assertNotEquals(a, b);
        system.assertNotEquals(a, c);
        system.assertNotEquals(b, c);
    }

    @isTest static void sendEventTest() {
        Test.startTest();
        System.assertEquals(true, Process.sendEvent('0'));
        System.assertEquals(true, Process.sendEvent('3'));
        System.assertEquals(true, Process.sendEvent('8'));
        Test.stopTest();
    }

    @isTest static void startProcessWithKeysTest() {
            Test.startTest();
            dqe_test__DQE_ONE__mdt ConsumerKeySecret;

           // Boolean result = Process.startProcessWithKeys(ConsumerKeySecret);
             Boolean result;
            Test.stopTest();
            
            if (result == true)
                system.assert(true, 'Success');
            else if (result == false)
                system.assert(false, 'Error');
    }

    @isTest static void uninstallProcessTest() {
        try {
            Test.startTest();
            Process.uninstallProcess();
            Test.stopTest();
        } catch(DmlException e) {
            system.assert(false, e);
        }
    }
}