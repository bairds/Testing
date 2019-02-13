public class testAdjustTZ {

    public DateTime LastEventDateTime { get; set; }
    public String LastEventDateTimeMyTZ { get; set; }
    public String NextEventDateTimeMyTZ { get; set; }
    public DateTime NextEventDateTime { get; set; }
    public boolean AcceptWaiver { get; set; }
    public boolean DeclineWaiver { get; set; }
    public boolean LastAccepted { get; set;}

public testAdjustTZ(){
NextEventDateTime = Datetime.newinstance(2018,02,15,9,0,0);
LastEventDateTime = NextEventDateTime.addmonths(6);
TimeZone tz = UserInfo.getTimeZone();
system.debug('User timezone is ' + tz);
System.debug('Offset: ' + tz.getOffset(NextEventDateTime));
integer CurrentOffset = integer.valueOf(tz.getOffset(NextEventDateTime));
System.debug('Offset: ' + CurrentOffset);
Integer HalfYearOffset = integer.valueOf(tz.getOffset(LastEventDateTime));
System.debug('Offset: ' + tz.getOffset(LastEventDateTime));
Integer DSTAdjustment = CurrentOffset - HalfYearOffset;
System.debug('DSTAdjustment: ' + DSTAdjustment);
System.debug('Event was set for 9 AM in the future.  Its time is ' + NextEventDateTime + ' in UTC.');
NextEventDateTimeMyTZ = NextEventDateTime.format('yyyy.MM.dd G HH:mm:ss z');
System.debug('In my timezone that is ' + NextEventDateTime.format('yyyy.MM.dd G HH:mm:ss z')); //
System.debug('Event was set for 6 months and 9 hours in the future.  Its time is ' + LastEventDateTime + ' in UTC.');
LastEventDateTimeMyTZ = LastEventDateTime.format('yyyy.MM.dd G HH:mm:ss z');
System.debug('In my timezone that is ' + LastEventDateTime.format('yyyy.MM.dd G HH:mm:ss z')); //
System.debug('To see the last event in Daylight Savings or STandard Time, we need to add the offset.');
DateTime LastEventDateTimeAdjusted = LastEventDateTime.addSeconds(DSTAdjustment/1000);
System.debug('Adjusted time is ' + LastEventDateTimeAdjusted.format('yyyy.MM.dd G HH:mm:ss z'));
}

public PageReference toggleAccept() {
    if (AcceptWaiver==true && LastAccepted!=true) {
    DeclineWaiver=false;
    LastAccepted=true;
    } else {
    if (DeclineWaiver==true){   
    AcceptWaiver=false;
    LastAccepted=false;
    } else {
    AcceptWaiver=false;
    DeclineWaiver=true;
    }
    }
    return null;
    }
    
}