({
    doInit : function(component, event, helper) {
        helper.setWebPageTitle(component);
        helper.loadUserInfo(component);
        helper.loadOrgInfo(component);
        helper.hasProjects(component);
    },
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");  
    },
    cancelDialog: function(component, event, helper) {
        var hasProjects = component.get("v.hasProjects");
        if (hasProjects) {
            window.location = '/lightning/n/AgouraFree__Home';            
        } else {
            window.location = '/lightning/o/AgouraFree__IdeaBoard__c/home';            
        }
    },
    submitFeedback: function(component, event, helper) {
        helper.sendFeedbackHelper(component);
    }
})