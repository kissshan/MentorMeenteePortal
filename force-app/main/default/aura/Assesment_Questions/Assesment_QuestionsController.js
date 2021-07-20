({
    doInit: function(component, helper) {
        debugger;
        var getAssQues = component.get("c.getAssQuestions");
        getAssQues.setParams({ 
            "studentTestAssId" : component.get("v.recordId")
        });
        getAssQues.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.quesAnswerWrapper", response.getReturnValue());
            
        });
        $A.enqueueAction(getAssQues);
    },
    handleAnswer: function(component, helper) {
        debugger;
        component.set("v.checkSpinner",true); 
        var dataForApex = component.get("v.quesAnswerWrapper"); 
        var insrtRespo = component.get("c.insertResponse");
        insrtRespo.setParams({ 
            "wrapList" : JSON.stringify(dataForApex)
        });
        insrtRespo.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                for (var i = 0; i < dataForApex.length; i++) {
                  dataForApex[i].studentAssessmetResult = response.getReturnValue()[i];        
                }
                component.set("v.quesAnswerWrapper",dataForApex);
                component.set("v.checkSpinner",false); 
            }
            else if(state === "ERROR"){
                alert('Error Occured');
                component.set("v.checkSpinner",false); 
            }
        });
        $A.enqueueAction(insrtRespo);
    },
})