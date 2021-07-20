/**
 * Author : Prithvi
 */

global class MentorshipServiceModels {
	
    global class Response {
        global Object result;
        global ErrorInfo error;
    } 
    
    global class GenericResponse {
    	global Boolean success;
        global String message;
    }
    
    public class Error{
        string code;
        string message;
    }
    
    public class ErrorInfo{
        public errorInfo(){
            errors = new List<Error>();
        }
        List<Error> errors;
    }
    
    global class RegistrationModel {
        global String firebaseId;
        global String email;
        global String firstName;
        global String lastName;
        global String userType;
    }  
}