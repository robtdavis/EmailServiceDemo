public with sharing class AutomationEmailService implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            // Log the incoming email details using Nebula Logger
            Logger.error('Inbound Email Received');
            Logger.setField(LogEntryEvent__e.Email_Subject__c, email.subject);
            Logger.setField(LogEntryEvent__e.Email_From__c, email.fromAddress);
            Logger.setField(LogEntryEvent__e.Email_Body__c, email.plainTextBody);
            Logger.setField(LogEntryEvent__e.Email_To__c, String.join(email.toAddresses, ','));
            Logger.saveLog();
            

            result.success = true;
        } catch (Exception e) {
            Logger.error('Error handling inbound email: ' + e.getMessage()+' stack trace: '+e.getStackTraceString());
            Logger.saveLog();

            result.success = false;
            result.message = 'Error: ' + e.getMessage();
        }

        return result;
    }
}