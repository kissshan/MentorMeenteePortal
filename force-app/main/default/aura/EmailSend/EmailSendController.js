({
     doInit: function (component, event, helper) {

        var contactId = component.get("v.recordId");
        var getAndSetEmail = component.get("c.getContactEmail");
        getAndSetEmail.setParams({
            "conId": contactId
        });

        getAndSetEmail.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    component.set("v.email", response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(getAndSetEmail);
         helper.getEmailTemplateHelper(component, event);
    },
    
    onSelectEmailTemplate: function (component, event, helper) {
        debugger;
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.Id == emailTempId && element.HtmlValue != null) {
                    emailbody = element.HtmlValue;
                    emailSubject = element.Subject;
                }
            });
        }
        component.set("v.body", emailbody);
        component.set("v.subject", emailSubject);

    },
    
    
    
    sendMail: function(component, event, helper) {
        debugger;
        // when user click on Send button 
        // First we get all 3 fields values 	
        var getEmail = component.get("v.email");
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var contactId = component.get("v.recordId");
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody,contactId);
        }
    },
 
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
})