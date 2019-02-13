public class Counter 
{      
    public Integer processed;
    public Integer failed;
    public Integer succeeded;
    public Integer remaining;
    
    public Counter()
    {
    }
    
    public static Counter resetRequest()
    {
        Counter c = new Counter();
        c.processed = 0;
        c.failed = 0;
        c.succeeded = 0;
        c.remaining = 0;
        
        return c;
    }
}