public without sharing class Assesment_Questions_Helper {
    public class QuesWrap{
        @auraEnabled
        public Student_Assessment_Result__c studentAssessmetResult ;
        @auraEnabled
        public List<String> picklistValues ;
        @auraEnabled
        public String answerType ;
        
        public QuesWrap(Student_Assessment_Result__c studentAssessmetResult,List<String> picklistValues,String answerType){
            this.studentAssessmetResult = studentAssessmetResult;
            this.picklistValues = picklistValues;
            this.answerType = answerType;
        }
    }
    @auraEnabled
    // will provide questions for test  
    public static List<QuesWrap> getAssQuestions(String studentTestAssId){//Contact conId
       // system.debug('ContactId==>'+conId);
        //String studentTestAssId = [SELECT Id FROM Student_Test_Association__c WHERE Contact__c =: conId limit 1].Id;
        system.debug('studentTestAssId==>'+studentTestAssId);
        String testMasterId = [SELECT Test_Master__c FROM Student_Test_Association__c Where Id =: studentTestAssId].Test_Master__c;
        system.debug('testMasterId==>'+testMasterId);
        String assQuesMasterId = [SELECT Assessment_Question_Master__c FROM Test_Master__c Where Id =: testMasterId].Assessment_Question_Master__c;
        system.debug('assQuesMasterId==>'+assQuesMasterId);
        List<Assessment_Question__c> assQuesList = [SELECT Answer_Choice__c,Answer_Picklist__c,Answer_Number__c,Category__c,Answer_Type__c,Assessment_Question_Master__c,Expected_Answer__c,Name,Question__c FROM Assessment_Question__c Where Assessment_Question_Master__c =:assQuesMasterId];
        System.debug('assQuesList==>'+assQuesList);
        //Map<Id, Assessment_Question__c> assesmentQuesMap = new Map<Id, Assessment_Question__c>([SELECT Answer_Choice__c,Answer_Picklist__c,Answer_Number__c,Answer_Type__c,Assessment_Question_Master__c,Expected_Answer__c,Name,Question__c FROM Assessment_Question__c Where Assessment_Question_Master__c =:assQuesMasterId]);
        Map<String, Assessment_Question__c> assesmentQuesMap = new Map<String, Assessment_Question__c>();
        for(Assessment_Question__c assessmentQuesRec : assQuesList){
            assesmentQuesMap.put(assessmentQuesRec.Question__c,assessmentQuesRec);
        }
        system.debug('assesmentQuesMap==>'+assesmentQuesMap);
        List<Student_Assessment_Result__c> listToBeUpdated = new List<Student_Assessment_Result__c>();
        List<QuesWrap> wrapList = new List<QuesWrap>();
        listToBeUpdated = [SELECT Answer__c,Name,Question__c,Student_Test_Association__c FROM Student_Assessment_Result__c WHERE Student_Test_Association__c =: studentTestAssId];
        system.debug('listToBeUpdated==>'+listToBeUpdated);
        if(!listToBeUpdated.isEmpty()){
            system.debug('in if ');
            for(Student_Assessment_Result__c assRes : listToBeUpdated){
                system.debug('assesmentQuesMap.get(assRes.Question__c).Answer_Picklist__c'+assesmentQuesMap.get(assRes.Question__c).Answer_Picklist__c);
                String answerOption = assesmentQuesMap.get(assRes.Question__c).Answer_Picklist__c;
                system.debug('answerOption==>'+answerOption);
                List<String> answerOptionList = answerOption.split(',');
                system.debug('answerOptionList==>'+answerOptionList);
                wrapList.add(new QuesWrap(assRes, answerOptionList,assesmentQuesMap.get(assRes.Question__c).Answer_Type__c));
            }
            system.debug('wraplist in if==>'+wrapList);
            return wrapList;
        }
        else{
            for(Assessment_Question__c selfAssRslt : assesmentQuesMap.values()){
                Student_Assessment_Result__c selfAssRsltRec = new Student_Assessment_Result__c();
                selfAssRsltRec.Question__c = selfAssRslt.Question__c;
                selfAssRsltRec.Que_Category__c = selfAssRslt.Category__c;
                selfAssRsltRec.Student_Test_Association__c = studentTestAssId;
                List<String> answerOptionList = new List<String>();
                if(selfAssRslt.Answer_Type__c == 'Picklist'){
                    String answerOption = selfAssRslt.Answer_Picklist__c;
                     answerOptionList = answerOption.split(',');
                    system.debug('answerOptionList==>'+answerOptionList);
                }
                else if(selfAssRslt.Answer_Type__c == 'Text' || selfAssRslt.Answer_Type__c == '' || selfAssRslt.Answer_Type__c == null ){
                     answerOptionList = new List<String> {'A,B,C,D'};
                }
                wrapList.add(new QuesWrap(selfAssRsltRec,answerOptionList,selfAssRslt.Answer_Type__c));
            }
            system.debug('wrapList in else==>'+wrapList);
            return wrapList;
        }
        
    }
    
    @auraEnabled
    public static List<Student_Assessment_Result__c> insertResponse(String wrapList){
        system.debug(wrapList);
        List<QuesWrap> listToSave = (List<QuesWrap>)JSON.deserialize(wrapList, List<QuesWrap>.class);
        List<Student_Assessment_Result__c> listToBeUpdated = new List<Student_Assessment_Result__c>();
        set<id> studentTestAssId = new set<id>();
        for(QuesWrap QuesWrapinstance : listToSave){
            listToBeUpdated.add(QuesWrapinstance.studentAssessmetResult);
            studentTestAssId.add(QuesWrapinstance.studentAssessmetResult.Student_Test_Association__c);
        }
       // System.debug('studentTestAssId'+studentTestAssId);
        System.debug('listToBeUpdated'+listToBeUpdated);
        if(listToBeUpdated.size()>0){
            //Database.SaveResult sr = Database.insert(listToBeUpdated,false);
            upsert listToBeUpdated;
        }
        evaluateResult(studentTestAssId);
        return listToBeUpdated;
    }
    
    public static void evaluateResult(set<id> studentTestAssId){
        Map<string,Student_Assessment_Result__c> resultMap = new Map<string,Student_Assessment_Result__c>();
        Map<string,Assessment_Question__c> questionMap = new Map<string,Assessment_Question__c>();
        List<Student_Assessment_Result__c> resultListToBeUpdated = new List<Student_Assessment_Result__c>();
        String testMasterId = [SELECT Test_Master__c FROM Student_Test_Association__c Where Id =: studentTestAssId].Test_Master__c;
        String assQuesMasterId = [SELECT Assessment_Question_Master__c FROM Test_Master__c Where Id =: testMasterId].Assessment_Question_Master__c;
        List<Assessment_Question__c> assQuesList = [SELECT Answer_Choice__c,Answer_Picklist__c,Answer_Number__c,Answer_Type__c,Assessment_Question_Master__c,Expected_Answer__c,Name,Question__c FROM Assessment_Question__c Where Assessment_Question_Master__c =:assQuesMasterId];
        List<Student_Assessment_Result__c> resultList = [SELECT Answer__c,Name,Question__c,Student_Test_Association__c,Marks__c FROM Student_Assessment_Result__c WHERE Student_Test_Association__c =: studentTestAssId];
        
        for(Assessment_Question__c assessmentQuesRec : assQuesList){
            questionMap.put(assessmentQuesRec.Question__c,assessmentQuesRec);
        }
        for(Student_Assessment_Result__c assessmentResultRec : resultList){
            resultMap.put(assessmentResultRec.Question__c,assessmentResultRec);
        }
        
        for(Assessment_Question__c assessmentQuesRec : questionMap.values()){
            
            if(resultMap.containsKey(assessmentQuesRec.Question__c)){
                integer i = 0;
                if(assessmentQuesRec.Expected_Answer__c == resultMap.get(assessmentQuesRec.Question__c).Answer__c){
                    i++;
                }
                Student_Assessment_Result__c studentAssessmentResult = new Student_Assessment_Result__c();
                studentAssessmentResult.Id = resultMap.get(assessmentQuesRec.Question__c).Id;
                studentAssessmentResult.Marks__c = i;
                resultListToBeUpdated.add(studentAssessmentResult);
            }
        }
        upsert resultListToBeUpdated;
    }	
}