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

        List<Widget__c> widgets = [SELECT Id, Value__c, Is_Properly_Nested__c, Is_checked__c, Owner.Profile.Name, Owner.Email
            FROM Widget__c 
            WHERE Is_checked__c = false
            LIMIT 100];

            if(widgets.size() < 1) {
                return;
            }
            List<Widget__c> notNested = new List<Widget__c>();

            for (Widget__c wdt : widgets) {
                wdt.Is_checked__c = true;
                if(checkString(wdt.Value__c)) {
                    wdt.Is_Properly_Nested__c = true;
                }
                if(!checkString(wdt.Value__c) && wdt.Owner.Email != null) {
                    notNested.add(wdt);
                }
            }

            try {
                update widgets;
            } catch (DmlException e) {
                System.debug('CheckIsProperlyNested dml update ERROR ');
            }

            if(notNested.size() > 0) {
                sendEmails(notNested);
            }
    }

    public static void sendEmails (List<Widget__c> widgets) {

        Set<String> toAddresses = new Set<String>();

        for (Widget__c wdt : widgets) {
            toAddresses.add(wdt.Owner.Email);
        }

        Messaging.reserveSingleEmailCapacity(toAddresses.size());
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>(toAddresses));
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('New Widget is not properly nested ');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('New Widget is not properly nested ');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public static Boolean checkString (String value) {

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
