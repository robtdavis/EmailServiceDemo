// Salesforce Record Creation Utility
public class SalesforceRecordCreator {

    public static void createCase(Messaging.InboundEmail email, String type){
        Contact cont = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email = :email.fromAddress 
            LIMIT 1
        ];

        Case c = new Case();
        c.Subject = (type == 'Unable to Determine Email Type' ? 'Unable to Determine Email Type: ' : '') + Type+' '+email.subject;
        c.Description = email.plainTextBody;
        c.ContactId = cont.Id;
        c.AccountId = cont.AccountId;
        c.Origin = 'Email';
        insert c;

        attachEmailAndFiles(c.Id, email);
    }

    // To Do what if there is not record found?
    public static void createOpportunity(Messaging.InboundEmail email){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = :email.fromAddress LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity from Email: ' + email.subject;
        opp.AccountId = con.AccountId;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;

        attachEmailAndFiles(opp.Id, email);

        relateOrderIfPresent(email, opp);
    }

    private static void attachEmailAndFiles(Id parentId, Messaging.InboundEmail email){
           // Determine the object type from the ID prefix
    String sobjectType = parentId.getSObjectType().getDescribe().getName();
    
    EmailMessage emailMsg = new EmailMessage();
    emailMsg.FromAddress = email.fromAddress;
    emailMsg.Incoming = true;
    emailMsg.Subject = email.subject;
    emailMsg.TextBody = email.plainTextBody;
    
    // Handle different parent object types appropriately
    if (sobjectType == 'Case') {
        emailMsg.ParentId = parentId;
    } else if (sobjectType == 'Opportunity') {
        // For Opportunity, we need to relate via a different field or create a Task instead
        // Option 1: Create a Task with WhatId as the Opportunity
        Task emailTask = new Task(
            Subject = 'Email: ' + email.subject,
            Description = email.plainTextBody,
            WhatId = parentId,
            Status = 'Completed',
            Priority = 'Normal',
            ActivityDate = Date.today()
        );
        insert emailTask;
        
        // If you still want to store the EmailMessage, you may need to create a Case
        // to link it to, or store it differently depending on your requirements
        return; // Skip EmailMessage creation for Opportunity
        }
    }

    private static void relateOrderIfPresent(Messaging.InboundEmail email, Opportunity opp){
        Pattern orderPattern = Pattern.compile('Order\\s?#?:?\\s?(\\d+)');
        Matcher matcher = orderPattern.matcher(email.plainTextBody);
        if(matcher.find()){
            String orderNumber = matcher.group(1);
            Order order = [SELECT Id FROM Order WHERE OrderNumber = :orderNumber LIMIT 1];
            // opp.Order = order.Id;
            update opp;
        }
    }
}
