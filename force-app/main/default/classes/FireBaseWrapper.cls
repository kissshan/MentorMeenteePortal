public class FireBaseWrapper {
    
    public class Fields {
        public Message message;
        public ElapsedTime ElapsedTime;
    }
    
    public Fields fields;
    public String createTime;
    
    public class Message {
        public String stringValue;
    }
    
    public class ElapsedTime {
        public String integerValue;
    }
    
    public static FireBaseWrapper parse(String json) {
        return (FireBaseWrapper) System.JSON.deserialize(json, FireBaseWrapper.class);
    }
}