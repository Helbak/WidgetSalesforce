public with sharing class UserDetails {
    
    @AuraEnabled(cacheable=true)
    public static user getUserInfo(String userId) {
        return [SELECT ID, Name, Profile.Name From User WHERE ID =: userId LIMIT 1];
    }

}
