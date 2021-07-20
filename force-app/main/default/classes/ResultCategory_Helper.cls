public class ResultCategory_Helper {
    public static void updateResultCategory(map<id,Student_Assessment_Result__c> studenrtAssessmentResultMap){
        system.debug('once in method');
        List<Student_Assessment_Result__c> ListforStudResultByType = new List<Student_Assessment_Result__c>();
        system.debug('studenrtAssessmentResultMap'+studenrtAssessmentResultMap);
        Set<String> CategoriesOfQues = new Set<String>();
        List<Result_Category__c> resultCategoryListToBeUpdated = new List<Result_Category__c>(); 
        List<Result_Category__c> finalisedResultCategoryListToBeUpdated = new List<Result_Category__c>();
        map<String,List<Student_Assessment_Result__c>> StudentAssResbyCategory = new map<String,List<Student_Assessment_Result__c>>();
        for(Student_Assessment_Result__c sar:studenrtAssessmentResultMap.values()){
            if(StudentAssResbyCategory.containsKey(sar.Que_Category__c)){
                List<Student_Assessment_Result__c> newList  = StudentAssResbyCategory.get(sar.Que_Category__c);
                newList.add(sar);
                StudentAssResbyCategory.put(sar.Que_Category__c,newList);
                
            }else{
                StudentAssResbyCategory.put(sar.Que_Category__c,new List<Student_Assessment_Result__c>{sar});
            }
        }
        system.debug( StudentAssResbyCategory);
        for(String str:StudentAssResbyCategory.keyset()){
            system.debug('The list is'+StudentAssResbyCategory.get(str));
        }
        String studentTestAssId;
        for(String Str: StudentAssResbyCategory.keyset()){
            Result_Category__c resultCategory = new Result_Category__c();
            resultCategory.Name = Str;
            integer totalQuestion =0;
            decimal totalMarks=0;
            
            for(Student_Assessment_Result__c sarCategoryList :StudentAssResbyCategory.get(Str)){
                totalQuestion++;
                system.debug('Str'+Str);
                system.debug('totalMarks'+totalMarks);
                
                system.debug('sarCategoryList.Marks__c'+sarCategoryList.Marks__c);
                if(sarCategoryList.Marks__c == 1){
                    totalMarks = totalMarks + sarCategoryList.Marks__c;
                }
                studentTestAssId = sarCategoryList.Student_Test_Association__c;
            }
            resultCategory.Student_Test_Association__c = studentTestAssId;
            resultCategory.Total_Questions__c = totalQuestion;
            resultCategory.Right_Answered_Ques__c = totalMarks;
            system.debug('totalQuestion'+totalQuestion);
            system.debug('totalMarks'+totalMarks);
            resultCategoryListToBeUpdated.add(resultCategory);
        }
        system.debug('resultCategoryListToBeUpdated'+resultCategoryListToBeUpdated);
        List<Result_Category__c> resultCategoryList = [Select id,Name,Student_Test_Association__c From Result_Category__c where Student_Test_Association__c =: studentTestAssId];
        system.debug('resultCategoryList=='+resultCategoryList);
        system.debug('resultCategoryList.size()=='+resultCategoryList.size());
        system.debug('resultCategoryListToBeUpdated=='+resultCategoryListToBeUpdated);
        system.debug('resultCategoryListToBeUpdated.size()=='+resultCategoryListToBeUpdated.size());
        
        if(!resultCategoryList.isEmpty()){
            system.debug('in if');
            for(Result_Category__c listToBeUpdated: resultCategoryListToBeUpdated){
                for(Result_Category__c queriedList : resultCategoryList){
                    if(queriedList.Name == listToBeUpdated.Name && queriedList.Student_Test_Association__c == listToBeUpdated.Student_Test_Association__c){
                        Result_Category__c resultCategoryInstance = new Result_Category__c();
                        resultCategoryInstance.Id = queriedList.Id;
                        resultCategoryInstance.Name = listToBeUpdated.Name;
                        resultCategoryInstance.Total_Questions__c = listToBeUpdated.Total_Questions__c;
                        resultCategoryInstance.Right_Answered_Ques__c = listToBeUpdated.Right_Answered_Ques__c;
                        finalisedResultCategoryListToBeUpdated.add(resultCategoryInstance);
                    }
                }
            }
            system.debug('finalisedResultCategoryListToBeUpdated=='+finalisedResultCategoryListToBeUpdated);
            update finalisedResultCategoryListToBeUpdated;
            system.debug('finalisedResultCategoryListToBeUpdated=='+finalisedResultCategoryListToBeUpdated);
        }else{
            system.debug('in else');
            insert resultCategoryListToBeUpdated;
        }
        system.debug('finalisedResultCategoryListToBeUpdated=='+finalisedResultCategoryListToBeUpdated);
        system.debug('finalisedResultCategoryListToBeUpdated.size()=='+finalisedResultCategoryListToBeUpdated.size());
        Student_Test_Association__c studentTestAssociation = [Select id,status__c from Student_Test_Association__c Where Id =: studentTestAssId];
        Student_Test_Association__c stRec = new Student_Test_Association__c();
        stRec.Id = studentTestAssociation.Id;
        stRec.Status__c = 'Completed';
        upsert stRec;
    }
    
}