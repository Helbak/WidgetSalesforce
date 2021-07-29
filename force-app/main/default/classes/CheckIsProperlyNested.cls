// From the Developer Console
// CheckIsProperlyNested checker = new CheckIsProperlyNested();
// String sch = '0 55 * * * ?'; 
// String jobID = system.schedule('RunCheckIsProperlyNested', sch, checker);



public with sharing class CheckIsProperlyNested implements Schedulable {


    public void execute(SchedulableContext ctx) {

        List<Widget__c> widgets = [SELECT Id, Value__c, Is_Properly_Nested__c, Is_checked__c 
            FROM Widget__c 
            WHERE Is_checked__c = false
            LIMIT 100];

            for (Widget__c wdt : widgets) {
                if(checkString(wdt.Value__c)) {
                    wdt.Is_checked__c = true;
                }
            }

            try {
                update widgets;
            } catch (DmlException e) {
                System.debug('CheckIsProperlyNested dml update ERROR ');
            }
    }

    private static Boolean checkString (String value) {
        if(value == null) {
            return false;
        }
        return true;
    }

}
