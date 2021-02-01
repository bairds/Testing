/* 
 * Created by Baird 7/19/2018
 * requestHUCValues class calls this class to see whether it should process errors immediately
 * or instead pass them to the requestHUCBatch class to be processed later.
 */
public class EmailUpdateError {
  // Static variables to avoid recursion on trigger operation

  private static boolean EmailUpdateError = false;

  public static boolean getemailUpdateError() {
      return EmailUpdateError;
  }

  // Set variable to true if error occurs on update

  public static void setEmailUpdateError() {
      EmailUpdateError = true;
  }

  public static void unsetEmailUpdateError() {
      EmailUpdateError = false;
      } 
  }