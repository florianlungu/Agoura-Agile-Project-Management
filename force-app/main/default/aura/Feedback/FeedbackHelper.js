({
    setWebPageTitle: function (component) {
        document.title = "Agoura Help";
        component.set("v.windowTitle", document.title); 
    },
    loadUserInfo: function(component) {
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var returnValue = response.getReturnValue();
            component.set("v.userInfo", returnValue);
        });
        $A.enqueueAction(action);
    },
    loadOrgInfo: function(component) {
        var action = component.get("c.getOrgInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "ERROR") {
                this.handleError(response);
                return;
            }
            var returnValue = response.getReturnValue();
            var orgId = returnValue.Id;
            component.set("v.orgInfo", orgId.substring(0,15));
        });
        $A.enqueueAction(action);
    },
    sendFeedbackHelper: function(component) {
        var getcontact = 'Name: ' + component.find('propName').get("v.value") + '\n' +
            'Title: ' + component.find('propTitle').get("v.value") + '\n' +
            'Company: ' + component.find('propCompany').get("v.value") + '\n' +
            'Phone: ' + component.find('propPhone').get("v.value") + '\n' +
            'Mobile: ' + component.find('propMobile').get("v.value") + '\n' +
            'Email: ' + component.find('propEmail').get("v.value") + '\n' +
            'Salesforce Organization Id: ' + component.find('propOrgId').get("v.value") + '\n\n';
        var getbody = component.find('propFeedback').get("v.value");
        var mbody = getcontact + getbody;
        var action = component.get("c.sendFeedback"); 
        action.setParams({'mbody': mbody});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.showConfirmSentModal", true);
            } else if (state === "ERROR") {
                this.handleError(response);
                return;
            }         
        });
        $A.enqueueAction(action);
    },
    handleError: function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({ "message": errors[0].message, "type": "error"});
            resultsToast.fire();
        } else {
            console.log("Unknown error");
        }  
    },
    hasProjects: function (component) {
        var action = component.get("c.hasProjectObject");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.hasProjects", result);
        });
        $A.enqueueAction(action);
    }
})