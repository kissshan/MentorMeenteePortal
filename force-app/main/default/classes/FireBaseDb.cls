public class FireBaseDb {
    public static String SendFCMNotification(){
        
        //

        string deviceToken = 'kK0ESxQXBXAteJGEwXJYoztr0mZdNUqwpRKgIQRN'; //your device token
        string msg ='test msg';
        string title =' Hello test 123';
       
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://firestore.googleapis.com/v1/projects/salesforce-database-e6bb1/databases');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Key=AAAApzfiohw:APA91bFN_zQWa6O6MD6SBz8bIFwxBZPp-pXvSYrPRhey37blJZq5pXSvXlJpDWvTXgZBH44DBRjUq-FzpzBTzBRPh4mkAPLsTtCfXt-BM0wmyFYstPEOBLLUiV9CjMY4CgeUvJIkbWt1'); //legacy server key

        
        // Set the body as a JSON object
        request.setBody('{"to":"'+deviceToken+'", "notification":{"body":"'+msg+'", "title":"'+title+'"} }');
        HttpResponse response = http.send(request);
        
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            return string.valueOf(response.getStatus());
        } else {
            System.debug(response.getBody());
            return string.valueOf(response.getStatus());
        }
    }

}