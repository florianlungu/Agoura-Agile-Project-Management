({
    doInit : function(component, event, helper) {
        var viewName = component.get("v.viewName");
        var linkList =  [
            {title: 'Agoura Help', url: '/lightning/cmp/AgouraFree__Feedback'},          
            {title: 'Agoura Quick Start Guide', url: 'https://www.agourasoftware.com/wp-content/uploads/Agoura-Quick-Start-Guide.pdf'}, 
            {title: 'Agoura User Manual', url: 'https://www.agourasoftware.com/wp-content/uploads/Agoura-User-Manual.pdf'},
            {title: 'Anchor Stories', url: '/lightning/o/AgouraFree__AnchorStory__c/home'},
            {title: 'Chatter', url: '/lightning/page/chatter'},
            {title: 'Dashboards', url: '/lightning/o/Dashboard/home'},
            {title: 'Idea Boards', url: '/lightning/o/AgouraFree__IdeaBoard__c/home'},
            {title: 'Project Templates', url: '/lightning/n/AgouraFree__Project_Templates'}, 
            {title: 'Reports', url: '/lightning/o/Report/home'}, 
            {title: 'Tags', url: '/lightning/o/AgouraFree__Tag__c/home'}
        ];      
        component.set("v.quickLinks", linkList);
        helper.setWebPageTitle(component);
        helper.checkAccess(component);
    }, 
    updateWebPageTitle : function(component, event, helper) {
        document.title = component.get("v.windowTitle");    
    }
})