({
	keyupHandler : function(component, event) {
        var changeEvent = component.getEvent("onchange");
        var searchTerm = event.target.value;
        if (searchTerm.length == 1) {
            return;   
        }
        changeEvent.setParams({
            "value": searchTerm
        });
        changeEvent.fire();
	},
    clearHandler : function(component) {
		component.find("searchInput").getElement().value = "";
        var changeEvent = component.getEvent("onchange");
        changeEvent.setParams({
            "value": ""
        });
        changeEvent.fire();
	}
})