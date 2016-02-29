package dmitool;

public class DMIException extends Exception {
    String[] desc = null;
    int line = 0;
    public DMIException(String[] descriptor, int line, String what) {
        super(what);
        desc = descriptor;
        this.line = line;
    }
    public DMIException(String what) {
        super(what);
    }
    public DMIException(String what, Exception cause) {
        super(what, cause);
    }

    @Override public String getMessage() {
        if(desc != null)
            return "\"" + desc[line] + "\" - " + super.getMessage();
        
        return super.getMessage();
    }
}