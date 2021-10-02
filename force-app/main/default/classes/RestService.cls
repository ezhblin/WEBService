/**
 * Created by eshemetov on 30/09/2021.
 */
@RestResource(UrlMapping = '/guest/*')
global with sharing class RestService {

    @HttpGet
    global static String getGuests() {
        String nameForGet = RestContext.request.params.get('Name');
        String invitedForGet = RestContext.request.params.get('IsInvited');
        String connectedUser = UserInfo.getName();

//        if (nameForGet != null) {
//            return [
//                    SELECT fycer__Contact__c, fycer__IsInvited__c
//                    FROM  fycer__Guest__c
//                    WHERE fycer__Contact__r.FirstName = : nameForGet
//            ];
//        }
//
//        if (invitedForGet != null) {
//            return [
//                    SELECT fycer__Contact__c, fycer__IsInvited__c
//                    FROM  fycer__Guest__c
//                    WHERE fycer__IsInvited__c = FALSE
//            ];
//        }
//
//        return [SELECT fycer__Contact__c, fycer__IsInvited__c FROM  fycer__Guest__c];
        return connectedUser;
    }

    @HttpPut
    global static List<fycer__Guest__c> putGuests(String[] listToInvite) {

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
        String idForDelete = RestContext.request.params.get('Id');
        try {
            delete [SELECT Name FROM fycer__Guest__c WHERE Id = :idForDelete];
            return 'Success';
        } catch (DmlException e) {
            return e.getMessage();
        }
    }

}