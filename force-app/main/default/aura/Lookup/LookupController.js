({
    search : function(component, event, helper) {
        const action = event.getParam('arguments').serverAction;        
        action.setParams({
            searchTerm : component.get('v.searchTerm'),
            selectedIds : helper.getSelectedIds(component),
            "recStr" : component.get('v.recStr')
        });
        action.setCallback(this, (response) => {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Process server success response
                const returnValue = response.getReturnValue();
                component.set('v.searchResults', returnValue);
        	} else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {console.log("Error message: " + errors[0].message);}
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({ "message": errors[0].message, "type": "error"});
                    resultsToast.fire();
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error");
            }
        });
        //action.setStorable(); // Enables client-side cache & makes action abortable
        $A.enqueueAction(action);
    },
    onInput : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        const newSearchTerm = event.target.value;
        helper.updateSearchTerm(component, newSearchTerm);
    },
    onResultClick : function(component, event, helper) {
        const recordId = event.currentTarget.id;
        helper.selectResult(component, recordId);
    },
    onComboboxClick : function(component, event, helper) {
        // Hide combobox immediatly
        const blurTimeout = component.get('v.blurTimeout');
        if (blurTimeout) {
            clearTimeout(blurTimeout);
        }
        component.set('v.hasFocus', false);
    },
    onFocus : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        component.set('v.hasFocus', true);
    },
    onBlur : function(component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }        
        // Delay hiding combobox so that we can capture selected result
        const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
            }), 300
        );
        component.set('v.blurTimeout', blurTimeout);
    },
    onRemoveSelectedItem : function(component, event, helper) {
        const itemId = event.getSource().get('v.name');
        helper.removeSelectedItem(component, itemId);
    },
    onClearSelection : function(component, event, helper) {
        helper.clearSelection(component);
    }
})