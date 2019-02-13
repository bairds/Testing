public class convertListStringToMultiPicklist {
    
    public static string convert(List<string> LS){
        String selectedConcat = '';
        for(String s : LS) {
         if (selectedConcat == '') 
           selectedConcat += s;
         else selectedConcat += ';' + s;
        }       
         return selectedConcat;
    }

}