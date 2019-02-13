public class AvoidRecursiveContactTrigger {
  // Static variables to avoid recursion on contact trigger operation

  private static boolean working = false;

  public static boolean isWorking() {
      return working;
  }

  // Set variable to true to mark record as working

  public static void setWorking() {
      working = true;
  }

  public static void setClosed() {
      working = false;
  }

}