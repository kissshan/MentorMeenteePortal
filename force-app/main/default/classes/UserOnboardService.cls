/**
 * Author: Prithvi
 */

@RestResource(urlMapping='/user_onboard')
global class UserOnboardService {
	
    @HttpPost global static String doOnboard() {
        String requestJSON = RestContext.request.requestBody.toString();
        System.debug(requestJSON);
        if(!String.isBlank(requestJSON)) {
            MentorshipServiceModels.RegistrationModel mentorWrapper = (MentorshipServiceModels.RegistrationModel) JSON.deserialize(requestJSON, MentorshipServiceModels.RegistrationModel.class);
            if(mentorWrapper != null && mentorWrapper.firebaseId != null && mentorWrapper.email != null) {
                Account mentorHousehold = new Account(Name = mentorWrapper.lastName + ' Household');
                insert mentorHousehold;
                
                Contact cUser = new Contact(AccountId = mentorHousehold.Id, Email = mentorWrapper.email, Firebase_Id__c = mentorWrapper.firebaseId, FirstName = mentorWrapper.firstName, LastName = mentorWrapper.lastName);
                if(!String.isBlank(mentorWrapper.userType)) {
                    if(mentorWrapper.userType.equalsIgnoreCase(MentorshipServiceConstants.USER_TYPE_INSTRUCTOR))
                		cUser.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(MentorshipServiceConstants.MENTOR_RECORD_TYPE_NAME).getRecordTypeId();
                    else
                        cUser.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(MentorshipServiceConstants.STUDENT_RECORD_TYPE_NAME).getRecordTypeId();
                    
                    insert cUser;
                    system.debug('---'+cUser);
                    return JSON.serialize(createSuccessResponse(cUser));
                }else {
                    JSON.serialize(createErrorResponse(false, 'Invalid request.'));
                }
            }else {
				JSON.serialize(createErrorResponse(false, 'Missing required fields.'));
            }
        }
        return null;
    }
    
    global static MentorshipServiceModels.Response createSuccessResponse(Object result) {
        MentorshipServiceModels.Response res = new MentorshipServiceModels.Response();
        res.result = result;
        return res;
    }
    
    global static MentorshipServiceModels.GenericResponse createErrorResponse(Boolean success, String message) {
        MentorshipServiceModels.GenericResponse genRes = new MentorshipServiceModels.GenericResponse();
        genRes.success = success;
        genRes.message = message;
        return genRes;
    }
    
    
}