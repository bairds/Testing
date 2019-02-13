/* 
 * Created by Baird 7/19/2018
 * requestHUCValues class calls this class to see whether it should process errors immediately
 * or instead pass them to the requestHUCBatch class to be processed later.
 */
public class avoidDMLDuringHUC {
  // Static variables to avoid recursion on trigger operation

  private static boolean CallingOut = false;
  public static List<ErrorHolder> ListEH;

  public static boolean callingOut() {
      return callingOut;
  }

  // Set variable to true to mark record as callingOut

  public static void setCallingOut() {
      callingOut = true;
  }

  public static void setDoneCallingOut() {
      callingOut = false;
      if (ListEH != null) {
      LogError LE = new LogError();
      LE.LogHUCErrors(ListEH);      
      } 
  }    
}