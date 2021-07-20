import { LightningElement,wire,api,track } from 'lwc';
import getEnrollmentCourse from '@salesforce/apex/SearchController.courseEnrollmentDetails';
export default class CustomLookup extends LightningElement {
    fields = ["Name","Active__c","Description__c"];
    displayFields = 'Name, Active__c, Description__c'

    @track courseRecId = '';
    @api enrollmentList = [];
    @api mentorStatusList = [];
    @api studentStatusList = [];

    mentorTrack = 0;
    studentTrack = 0;
    enableCourseAssignment = false;
    handleLookup(event){
        debugger;
        console.log( JSON.stringify ( event.detail) );
        this.courseRecId = event.detail.data.record.Id
        console.log('courseDetail::'+this.courseRecId);
        if(this.courseRecId != undefined)
            this.enrollmentCourse();
    }

    /*@wire(getEnrollmentCourse,{ courseId: '$courseRecId'})
    wiredCallback({error,data}){
        if(data){
            debugger;
            console.log('data::'+JSON.stringify ( data));
            this.enableCourseAssignment = true;
            for (let index = 0; index < data.length; index++) {
                if(data[index].Applied_by__c == 'Mentor'){
                    this.mentorStatusList.push(data[index]);
                    console.log('mentorStatusList::'+this.mentorStatusList);
                }
                if(data[index].Applied_by__c == 'Student'){
                    this.studentStatusList.push(data[index]);
                    console.log('studentStatus::'+ this.studentStatusList);
                }
                
            }
            this.mentorTrack = this.mentorStatusList.length;
            this.studentTrack = this.studentStatusList.length;
        }else if(error){
            debugger;
            console.log('error::'+error);
        }
    }*/

    enrollmentCourse(){
        debugger;
        getEnrollmentCourse({courseId: this.courseRecId})
        .then(data => {
            debugger;
            this.mentorTrack = 0;
            this.studentTrack = 0;
            this.mentorStatusList = [];
            this.studentStatusList = [];
            console.log('data::'+JSON.stringify ( data));
            this.enableCourseAssignment = true;
            for (let index = 0; index < data.length; index++) {
                if(data[index].Applied_by__c == 'Mentor'){
                    this.mentorStatusList.push(data[index]);
                    console.log('mentorStatusList::'+this.mentorStatusList);
                }
                if(data[index].Applied_by__c == 'Student'){
                    this.studentStatusList.push(data[index]);
                    console.log('studentStatus::'+ this.studentStatusList);
                }
                
            }
            this.mentorTrack = this.mentorStatusList.length;
            this.studentTrack = this.studentStatusList.length;
        }).catch(err =>{
            console.log('err::'+err);
        })
    }
        
        
    
}