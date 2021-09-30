/**
 * Created by eshemetov on 30/09/2021.
 */
@RestResource(UrlMapping = '/guest/*')
global with sharing class RestService {

    @HttpGet
    global static List<fycer__Guest__c> getGuests() {
        return [SELECT fycer__Contact__c, fycer__IsInvited__c FROM  fycer__Guest__c];
    }

    @HttpPut
    global static List<fycer__Guest__c> putGuests(List<String> listToInvite) {

        List<String> guestToPut = listToInvite.clone();

        List<fycer__Guest__c> guests = new  List<fycer__Guest__c>();

        for (Contact contactItem : [SELECT Id FROM Contact WHERE FirstName IN :listToInvite]) {
//            guestToPut(contactItem.Name);
            guests.add(new fycer__Guest__c(fycer__Contact__c = contactItem.Id, fycer__IsInvited__c = true));
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