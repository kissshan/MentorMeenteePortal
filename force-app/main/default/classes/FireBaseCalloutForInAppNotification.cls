public class FireBaseCalloutForInAppNotification {
    public static void makeHTTPrequestToFirebaseToNotify(){
        string apiKey = 'AIzaSyAtXKINw4smcNQSNu0cCQv1o5nJg7ZxLbs';
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        NotificationForMentor__c notificationRecord = [SELECT Contact__c,Message__c,Name,Notification_Timing__c,Record_Id__c FROM NotificationForMentor__c];
        String endpoint = 'https://firestore.googleapis.com/v1/projects/utilitarian-3bee4/databases/(default)/documents/contacts?key={'+apiKey+'}'; 
        
        /*TestwrapeerHandler.test1 sm1= new TestwrapeerHandler.test1();
		sm1.str = 'kishan';
		sm1.str1 = 'panchal';
		system.debug('data::'+sm1);*/
        NotificationForMentor__c mentorNotification = [SELECT Message__c,Notification_Timing__c,Record_Id__c FROM NotificationForMentor__c];
        FireBaseWrapper fbw = new FireBaseWrapper(); 
        
        FireBaseWrapper.ElapsedTime abc= new FireBaseWrapper.ElapsedTime();
        abc.integerValue = '100';
        
        FireBaseWrapper.Message mess= new FireBaseWrapper.Message();
        mess.stringValue = mentorNotification.Message__c;
        
        FireBaseWrapper.Fields feild= new FireBaseWrapper.Fields();
        feild.message = mess;
        feild.ElapsedTime = abc;
        system.debug('jsonString'+feild);
        
        fbw.fields = feild;
        fbw.createTime = '2020-05-13T23:00:29.0Z';
        
        String jsonString = JSON.serialize(fbw);
        
        system.debug('jsonString'+jsonString);
        
        string body =  jsonString;
        req.setEndpoint(endpoint);
        system.debug('EndpointUrl=='+endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('Accept', '*/*');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setBody(body);
        system.debug('body=='+body);
        HttpResponse response = http.send(req);
        if (response.getStatusCode() == 200) {
            system.debug('Successfully creeated record=='+response.getBody()+'Response'+response);
            Map<String, object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('results'+results);
            system.debug('results.get(fields)'+results.get('fields'));
            /* Messaging__c msg = new Messaging__c();
			msg.Message__c = String.valueOf(results.get('fields'));
			msg.Firestore_Doc_Id__c = String.valueOf(results.get('name'));*/
        }
        else{
            system.debug('Error Might Occured=='+response.getBody());
        }
    }
}