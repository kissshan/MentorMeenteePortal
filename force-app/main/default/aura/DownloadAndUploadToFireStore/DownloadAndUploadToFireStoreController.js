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
        var id = event.target.id;
        var downloadingFile =  component.get("c.downloadFileFromFireStoreDatabase");
        downloadingFile.setParams({ 
            "sessionId" : id
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
    doInit: function(component, helper) {
        debugger;
        var allModulesAndSession = component.get("c.getCourseModuleAndSession");
        allModulesAndSession.setParams({ 
            "courseMasterId" : component.get("v.recordId")
        });
        allModulesAndSession.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    var start = key.indexOf("Name");
                    var  ending = key.indexOf(",");
                    var modifiedKey = key.substring(start+5, ending);
                    arrayMapKeys.push({key: modifiedKey, value: result[key]});
                }
                component.set("v.mapValues", arrayMapKeys);
            }
        });
        $A.enqueueAction(allModulesAndSession);
    },
})