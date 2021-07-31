@isTest
public with sharing class CheckIsProperlyNestedTests {
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
