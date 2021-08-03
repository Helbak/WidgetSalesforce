@isTest
public with sharing class UserDetailsTest {
    
    @IsTest
    private static void testSchedulExecuteNested() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User tUser = new User(Alias = 'standt', Email='standarduserhd77@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserhd77@testorg.com');

        insert tUser;

        Test.starttest();

        User usr = UserDetails.getUserInfo(tUser.Id);

        Test.stopTest();

        System.AssertEquals(usr.Profile.Name, 'Standard User', 'Check UserDetails get Profile');

    }

}
