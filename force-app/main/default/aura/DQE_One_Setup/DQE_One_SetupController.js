({
    onInit : function(component, event, helper) {
        const empApi = component.find('empApi');
        
        empApi.onError($A.getCallback(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        }));
    },
    
    handleClickManual : function(component, event, helper) {
        component.set("v.isManual", true);
        component.set("v.installationStep", 'Not installed');

        helper.setupListenerManual(component);
    },

    handleClickAuto : function(component, event, helper) {  
        component.set("v.isAuto", true);
    },

    handleSubmit : function(component, event, helper) {
        const licence =  component.get('v.userLicense');
        
        if (licence) {
            const checkInstallationStatus = component.get('c.checkInstallationStatus');
            const updateMetadata = component.get('c.updateMetadata');

            updateMetadata.setParams({'metadataName' : 'Licence__c' , 'value' : licence});
            $A.enqueueAction(updateMetadata);

            component.set('v.isSubmit', true);
            component.set('v.isLoading', true);
            helper.setupListenerAuto(component);
            
            window.setTimeout(
                $A.getCallback(function() {
                    $A.enqueueAction(checkInstallationStatus);
                }), 2000
            );
        }
    },

    handleLicense: function(component, event, helper) {
        component.set("v.userLicense", event.detail.value);
    },

    handleServerUrl: function(component, event, helper) {
        component.set("v.userServerUrl", event.detail.value);
    },

    handleCancel: function(component, event, helper) {
        helper.resetAutoInstaller(component);
        helper.unsubscribe(component);

        component.set("v.isLoading", false);
    },

    handleCheckboxServerUrl: function(component, event, helper) {
        const urlCheckbox = component.find('urlCheckbox');

        if (urlCheckbox.get('v.checked') == true) {
            component.set('v.isDefaultUrl', true);
            component.set('v.userServerUrl', component.get('v.defaultServerUrl'));
        }
        else {
            component.set('v.userServerUrl', '');
        }
    },

    handleSubmitServerUrl: function(component, event, helper) {
        const serverUrl = component.get("v.userServerUrl");

        if (helper.isValidHttpUrl(serverUrl) == true) {
            const action = component.get("c.processNamedCredential");

            component.set('v.isLoading', true);
            action.setParams({"url" : serverUrl});
            $A.enqueueAction(action);
        }
        else {
            const urlInput = component.find("urlInput");
            urlInput.setCustomValidity("Invalid URL (make sure the protocol is https)");
        }
        
    },

    handlerCheckStep : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.checkManualStep(component);
    },

    handleUninstall : function(component, event, helper) {
        console.log('unisntall');
        const action = component.get("c.uninstallProcess");

        helper.unsubscribe(component);
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.resetAutoInstaller(component);
                component.set('v.isInstalled', false);
            }
            else
                console.log('Error during the uninstallation');
        });

        $A.enqueueAction(action);
    }
})