/**
 * Created by Baird on 1/17/2019.
 */

@IsTest
private class Formatted_DateTime_ControllerTEST{


static testMethod void noTimeGiven(){
    Formatted_DateTime_Controller FDTC = new Formatted_DateTime_Controller();
    FDTC.date_time = null;
    FDTC.defined_format = 'EEE MMM d yyyy  h:mm a';
    String result = FDTC.getFormattedDatetime();
    System.assertEquals('',result);
}

    static testMethod void CurrentTimeNow(){
        Formatted_DateTime_Controller FDTC = new Formatted_DateTime_Controller();
        FDTC.date_time = system.now();
        FDTC.defined_format = 'EEE MMM d yyyy  h:mm a';
        String result = FDTC.getFormattedDatetime();
        // Somewhere in the datetime string must be the year, which begins with '20'
        system.assert(result.contains('20'));
    }

    static testMethod void noFormatGiven(){
        Formatted_DateTime_Controller FDTC = new Formatted_DateTime_Controller();
        FDTC.date_time = system.now();
        FDTC.defined_format = '';
        String result = FDTC.getFormattedDatetime();
        system.debug('result is ' + result);
        system.assert(result.contains('20'));
    }

}