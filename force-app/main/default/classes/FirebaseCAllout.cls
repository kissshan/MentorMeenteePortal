public class FirebaseCAllout {
    public static void makeHTTPrequestToFirebaseToInsertData(){
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://salesforce-database-e6bb1-default-rtdb.firebaseio.com/'; 
        string documentName = 'EmpolyeesData.json'; //name of collection in which we want to insert new data record
        //bodi in json format
        NotificationForMentor__c notification = new NotificationForMentor__c();
        notification.Message__c = 'Your Seesion is Going to Start Soon';
        notification.Notification_Timing__c = system.now();
        
        string body = '{"Notifications": {"Message": {"Notification_Timing": "october 29, 1994","Message": "Your Seesion is Going to Start Soon"}}}';
        req.setEndpoint(endpoint+documentName);
        system.debug('EndpointUrl=='+endpoint+documentName);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setBody(body);
        system.debug('body=='+body);
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            system.debug('Successfully creeated record=='+response.getBody()+'Response'+response);
        }
        else{
            system.debug('Error Might Occured=='+response.getBody());
        }
    }
    
    public static void getDataFromFirebase(){
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://utilitarian-3bee4-default-rtdb.firebaseio.com/'; 
        string documentName = 'Employees/-McA-RZw3CzLMOYV4SGX.json'; //name of collection from which we want to retrive data from
        //https://utilitarian-3bee4-default-rtdb.firebaseio.com/Employees/-McA-RZw3CzLMOYV4SGX(from a particular thread under a record).json
        req.setEndpoint(endpoint+documentName);
        system.debug('EndpointUrl=='+endpoint+documentName);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            system.debug('Successfully creeated record=='+response.getBody());
            /*
             * response.getBody() = '{"Employee": 
             * {"Shubham Kumar": {"date_of_birth": "october 29, 1994","Designation": "Senior Developer","Company":"UtilitarianLab"}
             * ,"Aakash Jain": {"date_of_birth": "october 25, 1996","Designation": "Developer","Company":"UtilitarianLab"}}
             * }';
             * 
             */
        }
        else{
            system.debug('Error Might Occured=='+response.getStatusCode());
        }
    }
}