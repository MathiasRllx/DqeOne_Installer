({
    unsubscribe : function(component) {
        const empApi = component.find('empApi');
        const subscription = component.get('v.subscription');

        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.subscription', null);
        }));
    },

    setupListenerManual : function(component) {
        const empApi = component.find('empApi');

        empApi.subscribe('/event/dqe_test__DqeOneEvent__e', -1, $A.getCallback(eventReceived => {
            const installationStep = component.get("v.installationStep");
            const newStep = eventReceived['data']['payload']['dqe_test__InstallationStep__c'];
            const currentStep = component.get("v.currentStep");
            console.log('Received ' + installationStep);

            component.set('v.isLoading', false);

            if (newStep == installationStep) {
                component.set('v.processError', true);
                return;
            }
            
            if (component.get("v.processError") == true) {
                component.set('v.processError', false);
            }

            component.set("v.installationStep", component.get("v.manualInstallationStepList")[newStep]);
            component.set("v.currentStep", currentStep + 1);
            

            if (newStep == 'Installed') {
                component.set('v.isInstalled', true);
                this.unsubscribe(component);
            }

        })).then(subscription => {
            component.set('v.subscription', subscription);
        });
    },

    checkManualStep : function(component) {
        const installationStep = component.get("v.installationStep");
        const action = component.get("c.processCheckMetadataManual");

        action.setParams({"step" : installationStep });
        $A.enqueueAction(action)
    },

    setupListenerAuto : function(component) {
        const empApi = component.find('empApi');

        empApi.subscribe('/event/dqe_test__DqeOneEvent__e', -1, $A.getCallback(eventReceived => {
            const step = eventReceived['data']['payload']['dqe_test__InstallationStep__c'];

            component.set("v.installationStep", 'Deploy ' + step);
            console.log('Receive step : ' + step);

            switch (step) {
                case 'Remote Site Settings':
                    component.set('v.currentStep', 0);
                    this.requestController('c.processRemoteSiteSettings', component);
                    break;
                case 'Consumer Key Secret':
                    component.set('v.currentStep', 1);
                    this.requestController('c.processConsumerKeySecret', component);
                    break;
                case 'Connected App':
                    component.set('v.currentStep', 2);
                    this.requestController('c.processConnectedApp', component);
                    break;
                case 'Auth Provider':
                    component.set('v.currentStep', 3);
                    this.requestController('c.processAuthProvider', component);
                    break;
                case 'Named Credential':
                    component.set('v.currentStep', 4);
                    this.requestServerUrl(component);
                    component.set('v.isLoading', false);
                    break;
                case 'Installed':
                    component.set('v.currentStep', 5);
                    component.set('v.isLoading', false);
                    component.set('v.isInstalled', true);
                    break;
                default:
                    component.set('v.processError', true);
                    console.log('Error: Receive Unknown Event from Apex: ' + steps);
            }
        })).then(subscription => {
            component.set('v.subscription', subscription);
        });
    },

    requestController : function(string, component) {
        const action = component.get(string);

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('Succes ' + string + ' has been executed');
            }
            else {
                console.log('Error ' + string + ' has not been executed')
            }
        });

        $A.enqueueAction(action);
    },

    requestServerUrl : function(component) {
        const getMetadataValue = component.get("c.getMetadata");  
        
        getMetadataValue.setParams({ 'metadataName' : 'dqe_test__defaultUrl__c' });
        getMetadataValue.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.defaultServerUrl', response.getReturnValue());
            }
            else {
                component.set('v.defaultServerUrl', 'https://invalid_default_url.com');
            }
        });
        $A.enqueueAction(getMetadataValue);
    },

    resetAutoInstaller : function(component) {
        component.set('v.isAuto', false);
        component.set('v.isSubmit', false);
        component.set('v.isDefaultUrl', false);
        component.set('v.processError', false);
        component.set('v.currentStep', '0');
        component.set('v.installationStep', 'Preparing Installation ...');
    },

    isValidHttpUrl : function(string) {
        let url;

        try {
          url = new URL(string);
        } catch (_) {
          return false;
        }
        return url.protocol === "https:";
      }
})