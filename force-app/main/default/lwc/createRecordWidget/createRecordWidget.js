import { LightningElement, wire } from 'lwc';
import getUserInfo from '@salesforce/apex/UserDetails.getUserInfo';
import Id from '@salesforce/user/Id';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WIDGET_OBJECT from '@salesforce/schema/Widget__c';
import VALUE_FIELD from '@salesforce/schema/Widget__c.Value__c';

export default class CreateRecordWidget extends LightningElement {
    widgetObject = WIDGET_OBJECT;
    valueFieldName = VALUE_FIELD;

    valueWidget;
    isNested = false;
    showInput = false;

    @wire(getUserInfo, { userId: Id }) 
    userData;

    toggleView() {
        this.showInput = !this.showInput;
     }

    handleValue(event) {
        this.valueWidget = undefined;
        this.valueWidget = event.target.value;
        this.isNested = this.checkValueHelper(this.valueWidget);
    }

    checkValueHelper(valueWidget) {
        const openBrackets = "[{(";
        const closedBrackets = "]})";
        let stringAllBrackets = "";
    
        if(valueWidget==null || valueWidget==undefined) {
            return false;
        }
    
        if(valueWidget.length>131072 || valueWidget.length<1) {
            return false;
        }
    
        for(let i=0; i<valueWidget.length; i++) {
            if(openBrackets.indexOf(valueWidget.charAt(i))>=0) {
                stringAllBrackets = stringAllBrackets + valueWidget.charAt(i);
            }
            if(closedBrackets.indexOf(valueWidget.charAt(i))>=0) {
                if(stringAllBrackets.length<1){
                    return false;
                }
                let lastChar = stringAllBrackets.charAt(stringAllBrackets.length-1)
                if(closedBrackets.indexOf(valueWidget.charAt(i)) != openBrackets.indexOf(lastChar)){
                    return false;
                }
                stringAllBrackets = stringAllBrackets.substring(0, stringAllBrackets.length-1);
            }
        }
        if(stringAllBrackets.length > 0) {
            return false;
        }
        return true;
    }

    createRequestRecord() {    

        if(this.userData.data.Profile.Name != 'System Administrator' && this.userData.data.Profile.Name != 'Widget Masters') {
            if(!this.isNested) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record. ',
                        message: 'Value should be Properly Nested',
                        variant: 'error',
                    }),
                );
                return;
            }
        }
        
        const fields ={};        
        fields[VALUE_FIELD.fieldApiName]= this.valueWidget;
        
        const recordInput = { 
            apiName: WIDGET_OBJECT.objectApiName, 
            fields 
        };
        
        createRecord(recordInput)
            .then(widget => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Widget Record created ',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
            this.valueWidget = '';
            this.isNested = false;
            this.showInput = false;
    }

}