({
    handleFilesChange: function(component, event, helper) {
        debugger;
        var customFileName = 'No File Selected..';
        var customFileType = '';
        var fileExtension ='';
        if (event.getSource().get("v.files").length > 0) {
            customFileName = event.getSource().get("v.files")[0]['name'];
            customFileType = event.getSource().get("v.files")[0]['type'];
            fileExtension = customFileName.split('.')[1];
        }
        //alert(customFileType);
        //alert(fileExtension);
        component.set("v.Upload_sign_File", customFileName);
    },
    
    doSave: function(component, event, helper) {
        debugger;
        helper.uploadHelper(component, event);
    },
    
    dodownload: function(component, event, helper) {
        debugger;
        var id = component.get("v.recordId");
        var downloadingFile =  component.get("c.downloadFileFromFireStoreDatabase");
        downloadingFile.setParams({ 
            "mentorCourseScheduleId" : id
        });
        downloadingFile.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
                alert("Success");
            }
            else {
                alert("Error");
            }
        });
        $A.enqueueAction(downloadingFile);
    },
   
})