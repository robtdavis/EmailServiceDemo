public class EmailHandlerAI implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // Callout to ChatGPT to classify email
        String emailType = EmailClassifier.classifyEmail(email.subject, email.plainTextBody);
        System.Debug('emailType = ' + emailType);
        if(emailType == 'Product Inquiry'){
            SalesforceRecordCreator.createCase(email, 'Product Inquiry:');
        }
        else if(emailType == 'Sales Order'){
            SalesforceRecordCreator.createOpportunity(email);
        }
        else if(emailType == 'Warranty'){
            SalesforceRecordCreator.createCase(email, 'Warranty:');
        }
        else if(emailType == 'Request for More Information'){
            SalesforceRecordCreator.createCase(email, 'Request for More Information:');
        } else{
            SalesforceRecordCreator.createCase(email, 'Unable to Determine Email Type:');
        }
        
        result.success = true;
        return result;
    }
}