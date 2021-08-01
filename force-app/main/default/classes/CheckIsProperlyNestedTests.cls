@isTest
public with sharing class CheckIsProperlyNestedTests {

    @IsTest
    private static void testSchedulExecute() {        

        Widget__c widget = new Widget__c(Value__c = '([Nested String])');
        insert widget;
        
        Test.starttest();
        
        CheckIsProperlyNested checker = new CheckIsProperlyNested();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second());
        String sch = ss + ' ' + min + ' ' + hour + ' * * ?';

        system.schedule('RunCheckIsProperlyNested', sch, checker);

        List<List<Widget__c>> wdt = [FIND '([Nested String])'
            IN ALL FIELDS 
            RETURNING Widget__c (Id, Value__c, Is_Properly_Nested__c, Is_checked__c) 
            LIMIT 1];

        Test.stopTest();

        // System.assert(wdt[0][0].Is_Properly_Nested__c, 'CheckIsProperlyNested Test Properly Nested String');
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
