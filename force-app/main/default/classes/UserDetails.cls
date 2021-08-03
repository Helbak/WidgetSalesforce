public with sharing class UserDetails {
    
    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId) {
        return [SELECT ID, Name, Profile.Name From User WHERE ID =: userId LIMIT 1];
    }

}
