import { api, LightningElement ,track} from 'lwc';
import getEnrollmentCourse from '@salesforce/apex/CourseAssignmentController.getAssignmentStats';
import assignMentorToStudent from '@salesforce/apex/CourseAssignmentController.assignMentorToStudent';
export default class CourseAssignment extends LightningElement {
    @api unassignedStudent;
    @api unassignedMentor;
    @api studentList;
    @api mentorList;
    @track courseDetails = [];
    @track testData = [];
    @api courseRecId;
    @api enrollementListTobeinsert = [];
    @track enableStudentTable = false;
    columns = [
        {label: 'Student Name', fieldName: 'studentName',variant : 'brand'},
        {label: 'Student Email', fieldName: 'studentEmail'},
        {label: 'Mentor name', fieldName: 'mentorName'},
        {label: 'Mentor Email', fieldName: 'mentorEmail'},
        {label: 'Assign' , type: "button",onclick:{onclick},typeAttributes: {
            label: 'Assign',
            name: 'Assign',
            title: 'Assign',
            disabled: false,
            value: 'Assign',
            iconPosition: 'left',
            variant : 'brand'
        }}
    ]
    handleRowAction(event){
        debugger;
        console.log('inside button action');
        console.log('this.enrollementListTobeinsert::'+this.enrollementListTobeinsert);

        if(event.detail.action.name == 'Assign')
            this.assign();
        //event.detail.action.name
    }
    callRowAction(event){
        debugger;
        console.log('inside row selection');
        this.enrollementListTobeinsert =   event.detail.selectedRows;
        console.log('recId::'+this.enrollementListTobeinsert);
    }
    onclick(){
        debugger;
        console.log('studentList::'+this.studentList);
        console.log('mentorList::'+this.mentorList);
        getEnrollmentCourse({studentRecords : this.studentList,mentorRecords : this.mentorList,subQuery : ''})
        .then(data => {
            this.enableStudentTable = true;
            console.log('data::'+data);
            this.courseDetails = data;
            console.log('this.courseDetails::'+this.courseDetails);
        }).catch(err =>{
            console.log('err::'+err);
        })
    }

    locationWiseList(){
        getEnrollmentCourse({studentRecords : this.studentList,mentorRecords : this.mentorList,subQuery : 'Location'})
        .then(data => {
            console.log('data::'+data);
            this.courseDetails = data;
            console.log('this.courseDetails::'+this.courseDetails);
        }).catch(err =>{
            console.log('err::'+err);
        })
    }

    assign(){
        debugger;
        console.log('thisenrollementListTobeinsert::'+this.enrollementListTobeinsert);
        for (let index = 0; index < this.enrollementListTobeinsert.length; index++) {
            this.testData.push(this.enrollementListTobeinsert[index]);
            
        }
        console.log('this.testData::'+this.testData);
        assignMentorToStudent({courseAssignmentString : JSON.stringify(this.enrollementListTobeinsert),name : 'kishan'})
        .then(res =>{
            console.log('res::'+res);
            //this.courseDetails = this.courseDetails.splice(1, 1)
        }).catch(err => {
            console.log('err::'+err);
        })
    }
}