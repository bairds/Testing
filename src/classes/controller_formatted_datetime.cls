/**
 * Created by Baird on 1/17/2019.  From https://help.salesforce.com/articleView?id=000066915&language=en_US&type=1
 */
public class controller_formatted_datetime {
    public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
    public String defined_format { get; set; } //property that reads the string value from component attribute tag
    public String getFormattedDatetime() {
        if (date_time == null)

        {
            return '';
        } else {

            if (defined_format == null) {
                return date_time.format(); //return the full date/time in user's locale and time zone
            } else {
                return date_time.format(defined_format, 'GMT');  //Specify Time zone like IST,CST
            }

        }
    }
}