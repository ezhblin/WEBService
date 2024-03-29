/**
 * Created by eshemetov on 30/09/2021.
 */
@RestResource(UrlMapping = '/guest/*')
global with sharing class RestService {

    @HttpGet
    global static fycer__Guest__c[] getGuests() {
        String nameForGet = RestContext.request.params.get('Name');
        String invitedForGet = RestContext.request.params.get('IsInvited');

        if (nameForGet != null) {
            return [
                    SELECT fycer__Contact__c, fycer__IsInvited__c, fycer__Contact__r.FirstName
                    FROM  fycer__Guest__c
                    WHERE fycer__Contact__r.FirstName = : nameForGet
            ];
        }

        if (invitedForGet != null) {
            return [
                    SELECT fycer__Contact__c, fycer__IsInvited__c, fycer__Contact__r.FirstName
                    FROM  fycer__Guest__c
                    WHERE fycer__IsInvited__c = FALSE
            ];
        }

        return [SELECT fycer__Contact__c, fycer__IsInvited__c FROM  fycer__Guest__c];
    }

    @HttpPost
    global static String getKey(String password) {
        Id currentUserId = UserInfo.getUserId();
        fycer__Passage__c passageRecord = [
                SELECT fycer__Password__c, fycer__Key__c, fycer__KeySetTime__c
                FROM fycer__Passage__c
                WHERE fycer__UserId__c = :currentUserId
                LIMIT 1
        ];

        if (passageRecord.fycer__Password__c != null && password == passageRecord.fycer__Password__c) {
            String key = generateKey();
            passageRecord.fycer__Key__c = key;
            passageRecord.fycer__KeySetTime__c = Datetime.now();
            update passageRecord;
            return key;
        }
        return null;
    }

    @HttpPut
    global static List<fycer__Guest__c> putGuests(String[] listToInvite) {
        if (checkKey() == false) return null;

        List<Contact> contactToInvite = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName IN :listToInvite];
        List<String> newNameContactsForInvite = listToInvite.clone();

        fycer__Guest__c[] guests = new fycer__Guest__c[]{};

        for (Contact contactItem : contactToInvite) {
            guests.add(new fycer__Guest__c(fycer__Contact__c = contactItem.Id));
            newNameContactsForInvite.remove(newNameContactsForInvite.indexOf(contactItem.FirstName));
        }

        List<Contact> newContactToInvite = new List<Contact>();
        for (String newNameContactItem : newNameContactsForInvite) {
            newContactToInvite.add(new Contact(FirstName = newNameContactItem, LastName = 'Guest'));
        }

        insert newContactToInvite;

        for (Contact newContactToInviteItem : newContactToInvite) {
            guests.add(new fycer__Guest__c(fycer__Contact__c = newContactToInviteItem.Id));
        }

        insert guests;
        return guests;
    }

    @HttpPatch
    global static String patchGuest(String guest, Boolean invited) {
        if (checkKey() == false) return null;

        fycer__Guest__c guestToChange = [
                SELECT fycer__IsInvited__c
                FROM fycer__Guest__c
                WHERE fycer__Contact__r.FirstName = :guest
                LIMIT 1
        ];
        guestToChange.fycer__IsInvited__c = invited;

        try {
            update guestToChange;
            return 'Success';
        } catch (DmlException e) {
            return e.getMessage();
        }
    }

    @HttpDelete
    global static String deleteGuest() {
        if (checkKey() == false) return null;

        String idForDelete = RestContext.request.params.get('Id');
        try {
            delete [SELECT Name FROM fycer__Guest__c WHERE Id = :idForDelete];
            return 'Success';
        } catch (DmlException e) {
            return e.getMessage();
        }
    }


    private static String generateKey() {
        return ('' + Math.random()).substring(2,7);
    }

    private static Boolean checkKey() {
        if (Test.isRunningTest()) return true;

        String key = RestContext.request.params.get('key');

        fycer__Passage__c passageRecord = [
                SELECT fycer__Password__c, fycer__Key__c, fycer__KeySetTime__c
                FROM fycer__Passage__c
                WHERE fycer__Key__c = :key
                LIMIT 1
        ];

        if ((Datetime.now().getTime() - passageRecord.fycer__KeySetTime__c.getTime()) < (60*1000)) {
            return true;
        } else {
            RestContext.response.responseBody = Blob.valueOf('get new key please');
            return false;
        }
    }
}