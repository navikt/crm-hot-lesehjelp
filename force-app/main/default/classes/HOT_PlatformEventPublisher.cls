public with sharing class HOT_PlatformEventPublisher {
    
    @InvocableMethod(
    label='Publish Platform Event with Callback'
    description='Publishes a platform event and logs async success/failure'
    )
    public static List<Result> publish(List<Request> requests) {
        List<Result> results = new List<Result>(); 
        PublishCallbackHandler callbackHandler = new PublishCallbackHandler();

        for (Request req : requests) {
            SObject event = req.eventRecord;
            Database.SaveResult sr = EventBus.publish(event, callbackHandler);
            
            Result result = new Result();
            result.isSuccess = sr.isSuccess();
            if (!sr.isSuccess()) {
                List<String> messages = new List<String>();
                for (Database.Error err : sr.getErrors()) {
                    messages.add(err.getStatusCode() + ': ' + err.getMessage());
                }
                result.errors = String.join(messages, '; ');
            }
            results.add(result);
        }
        return results;

    }

    public class Request {
        @InvocableVariable(label='Platform Event Record' required=true)
        public SObject eventRecord;
    }

    public class Result {
    @InvocableVariable(label='Is Success')
    public Boolean isSuccess;
    @InvocableVariable(label='Errors')
    public String errors;
    }

    public class PublishCallbackHandler implements EventBus.EventPublishFailureCallback {

        public void onFailure(EventBus.FailureResult result) {
            List<String> eventUUIDs = result.getEventUuids();
            
            // Publish errors in a slack channel. More information on slack publishing can be found in crm-platform-base repository.
            LoggerUtility logger = new LoggerUtility();
            for (String uuid : eventUUIDs) {
                logger.error(
                    'Platform event publish failed for event UUID: ' + uuid,
                    null, // no sObject reference
                    CRM_ApplicationDomain.Domain.HOT,
                    uuid  // overwrites auto-generated UUID with the platform's own event UUID for traceability
                );
            }
            logger.publish();
        }
    }
}     
