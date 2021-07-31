// From the Developer Console
// CheckIsProperlyNested checker = new CheckIsProperlyNested();
// String sch = '0 55 * * * ?'; 
// String jobID = system.schedule('RunCheckIsProperlyNested', sch, checker);

// Stop Execution
// System.abortJob(Id);
// Select c.TimesTriggered, c.TimeZoneSidKey, c.State, c.StartTime, c.PreviousFireTime, c.OwnerId, c.NextFireTime, c.LastModifiedById, c.Id, c.EndTime, c.CronExpression, c.CreatedDate, c.CreatedBy.Name From CronTrigger c
// for (CronTrigger ct : [SELECT Id FROM CronTrigger]) {
//     System.abortJob(ct.Id);
// }





public with sharing class CheckIsProperlyNested implements Schedulable {


    public void execute(SchedulableContext ctx) {

        List<Widget__c> widgets = [SELECT Id, Value__c, Is_Properly_Nested__c, Is_checked__c, Owner.Profile.Name 
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

        List<String> listValues = value.split('');
        List<String>  openBrackets = new List<String> {'[','{','('};
        List<String>  closedBrackets = new List<String> {']','}',')'};
        List <String> stringAllBrackets = new List<String>();

        if(listValues.size()>131072 ) {
            return false;
        }

        for(String val : listValues) {
            if(openBrackets.contains(val)) {
                stringAllBrackets.add(val);
            }
            if(closedBrackets.contains(val)) {
                if(stringAllBrackets.size()<1) {
                    return false;
                }
                    String lastChar = stringAllBrackets.get(stringAllBrackets.size()-1);
                    if(closedBrackets.indexOf(val) != openBrackets.indexOf(lastChar)) {
                        return false;
                    }
                    stringAllBrackets.remove(stringAllBrackets.size()-1);
            }
        }
        return true;
    }

}
