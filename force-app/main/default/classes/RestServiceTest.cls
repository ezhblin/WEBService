/**
 * Created by Doom on 03.10.2021.
 */

@IsTest
private class RestServiceTest {
    @IsTest
    static void getGuestTest() {
        RestRequest request = new RestRequest();
        request.requestURI = 'https://mindful-raccoon-ly79nw-dev-ed.lightning.force.com/services/fycer/guest';
        request.httpMethod = 'GET';
        request.params.put('Name', 'Corban');
        RestContext.request = request;

        fycer__Guest__c[] guests = RestService.getGuests();
        System.assertEquals('Corban', guests[0].fycer__Contact__r.FirstName);

        RestRequest requestNotInvited = new RestRequest();
        requestNotInvited.requestURI = 'https://mindful-raccoon-ly79nw-dev-ed.lightning.force.com/services/fycer/guest';
        requestNotInvited.httpMethod = 'GET';
        requestNotInvited.params.put('IsInvited', 'Corban');
        RestContext.request = requestNotInvited;

        fycer__Guest__c[] guestsNotInvited = RestService.getGuests();
        System.assertEquals('Nocorban', guestsNotInvited[0].fycer__Contact__r.FirstName);

    }

    @IsTest
    static void getKeyTest() {
        System.assertEquals(5, RestService.getKey('321').length());
    }

    @IsTest
    static void putGuestsTest() {
        List<fycer__Guest__c> newbie = new List<fycer__Guest__c>();
        newbie = RestService.putGuests(new String[]{'notGuest', 'notContact'});
        System.assertEquals(2, newbie.size());
    }

    @IsTest
    static void patchGuestTest() {
        System.assertEquals('Success', RestService.patchGuest('Nocorban', false));
    }

    @IsTest
    static void deleteGuestTest(){
        RestRequest request = new RestRequest();
        request.requestURI = 'https://mindful-raccoon-ly79nw-dev-ed.lightning.force.com/services/fycer/guest';
        request.httpMethod = 'DELETE';

        fycer__Guest__c guestForDelete = [
                SELECT Id, fycer__Contact__r.FirstName
                FROM fycer__Guest__c
                WHERE fycer__Contact__r.FirstName ='Nocorban'
        ];


        request.params.put('Id', guestForDelete.Id);
        RestContext.request = request;

        System.assertEquals('Success', RestService.deleteGuest());
    }

    @TestSetup
    static void fillData() {
        Contact[] forInvite = new Contact[]{};
        Contact corban = new Contact(FirstName = 'Corban', LastName = 'badass');
        forInvite.add(corban);
        Contact noCorban = new Contact(FirstName = 'Nocorban', LastName = 'fake');
        forInvite.add(noCorban);
        Contact notGuest = new Contact(FirstName = 'notGuest', LastName = 'test');
        forInvite.add(notGuest);


        insert forInvite;

        fycer__Guest__c[] testGuest = new fycer__Guest__c[]{
                new fycer__Guest__c(fycer__Contact__c = corban.Id, fycer__IsInvited__c = true),
                new fycer__Guest__c(fycer__Contact__c = noCorban.Id, fycer__IsInvited__c = false)
        };

        insert testGuest;

        fycer__Passage__c pass = new fycer__Passage__c(
                fycer__UserId__c = UserInfo.getUserId(),
                fycer__Password__c = '321',
                fycer__Key__c = 'test'
        );

        insert pass;

    }
}