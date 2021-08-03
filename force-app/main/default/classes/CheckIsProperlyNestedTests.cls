@isTest
public with sharing class CheckIsProperlyNestedTests {

    @IsTest
    private static void testSendEmails() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserhd77@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserhd77@testorg.com');

        System.runAs(u) {
            Widget__c widget = new Widget__c(Value__c = '(Not Nested String]', Name='Not Nested');
            insert widget;
        }

        Test.starttest();
        List<Widget__c> widgets = [SELECT Id, Value__c, Is_Properly_Nested__c, Is_checked__c, Owner.Profile.Name, Owner.Email
            FROM Widget__c 
            WHERE Name = 'Not Nested'
            LIMIT 1];

        CheckIsProperlyNested.sendEmails(widgets);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
    
        system.assertEquals(1, invocations, 'An email should be sent');

    }

    @IsTest
    private static void testSchedulExecuteNotNested() {

        Widget__c widget = new Widget__c(Value__c = '(Not Nested String]', Name='Not Nested');
        insert widget;

        Test.starttest();

        CheckIsProperlyNested checker = new CheckIsProperlyNested();
        checker.execute(null);

        List<Widget__c> wdt = [SELECT Id, Is_Properly_Nested__c, Is_checked__c, Name 
            FROM Widget__c 
            WHERE Name LIKE 'Not Nested' 
            LIMIT 1];
        Test.stopTest();

        System.assert(wdt[0].Is_checked__c, 'CheckIsProperlyNested TestNot Nested String');
        System.assert(!wdt[0].Is_Properly_Nested__c, 'CheckIsProperlyNested Test Not Nested String');

    }

    @IsTest
    private static void testSchedulExecuteNested() {

        Widget__c widget = new Widget__c(Value__c = '([Nested String])', Name='Test Name');
        insert widget;

        Test.starttest();

        CheckIsProperlyNested checker = new CheckIsProperlyNested();
        checker.execute(null);

        List<Widget__c> wdt = [SELECT Id, Is_Properly_Nested__c, Is_checked__c, Name 
            FROM Widget__c 
            WHERE Name LIKE 'Test Name' 
            LIMIT 1];
        Test.stopTest();

        System.assert(wdt[0].Is_checked__c, 'CheckIsProperlyNested Test Properly Nested String');
        System.assert(wdt[0].Is_Properly_Nested__c, 'CheckIsProperlyNested Test Properly Nested String');

    }

    @IsTest
    private static void testSchedulTemporaryPlug() {        

        Test.starttest();
        
        CheckIsProperlyNested checker = new CheckIsProperlyNested();
        String sch = '0 55 * * * ?';

        system.schedule('RunCheckIsProperlyNested', sch, checker);

        Test.stopTest();

   }

    @IsTest
    private static void testCheckWrongString() {

        String wrong = '(}wrong)}';
        String wrongTwo = '{wrong}string]';
        String wrongThree = 'wrong]';

        Test.startTest();

        Boolean isNested = CheckIsProperlyNested.checkString(wrong);
        Boolean isNestedTwo = CheckIsProperlyNested.checkString(wrongTwo);
        Boolean isNestedThree = CheckIsProperlyNested.checkString(wrongThree);

        Test.stopTest();

        System.assert(!isNested, 'Wrong String is not Nested');
        System.assert(!isNestedTwo, 'Wrong String is not Nested');
        System.assert(!isNestedThree, 'Wrong String is not Nested');

    }

    @IsTest
    private static void testCheckRightString() {

        String right = '{([Right])}';

        Test.startTest();

        Boolean isNested = CheckIsProperlyNested.checkString(right);

        Test.stopTest();

        System.assert(isNested, 'Right String is Nested');

    }
    
    @IsTest
    private static void testCheckExtraSizeString() {

        String hundred = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean m';
        String extra = '';
        for(Integer i=0; i<1320; i++) {
            extra = extra + hundred;
        }

        Test.startTest();

        Boolean isNested = CheckIsProperlyNested.checkString(extra);

        Test.stopTest();

        System.assert(!isNested, 'String more 131072 characters is not Nested');

    }
}
