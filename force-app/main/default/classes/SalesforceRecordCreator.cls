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

    public static void createOpportunity(Messaging.InboundEmail email){
        Contact con = findContactByEmail(email);
        Id newAcctId;

        if (con == null) {
            newAcctId = createAccount(email); // 👈 Method #1
        } else {
            newAcctId = con.AccountId;
        }

        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity from Email: ' + email.subject;
        opp.AccountId = newAcctId;
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today().addDays(30);
        insert opp;

        attachEmailAndFiles(opp.Id, email);

        relateOrderIfPresent(email, opp);
    }

    private static void attachEmailAndFiles(Id parentId, Messaging.InboundEmail email){
    
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = email.fromAddress;
        emailMsg.Incoming = true;
        emailMsg.Subject = email.subject;
        emailMsg.TextBody = email.plainTextBody;
        insert emailMsg;
    
        Task emailTask = new Task(
        Subject = 'Email: ' + email.subject,
        Description = email.plainTextBody,
        WhatId = parentId,
        Status = 'Completed',
        Priority = 'Normal',
        ActivityDate = Date.today());
        insert emailTask;
 
        saveAttachments(email, parentId);
        
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

    private static Id createAccount(Messaging.InboundEmail email) {
        Account acct = new Account(
            Name = 'AutoCreated - ' + email.fromName
        );
        insert acct;
        return acct.Id;
    }

    private static Contact createContact(Messaging.InboundEmail email, Id accountId) {
        Contact c = new Contact(
            LastName = 'AutoCreated',
            Email = email.fromAddress,
            AccountId = accountId
        );
        insert c;
        return c;
    }

    private static Contact findContactByEmail(Messaging.InboundEmail email) {
        List<Contact> matches = [
            SELECT Id, AccountId FROM Contact WHERE Email = :email.fromAddress LIMIT 1
        ];
        return matches.isEmpty() ? null : matches[0];
    }

    private static void saveAttachments(Messaging.InboundEmail email, Id parentId) {
        if (parentId == null) {
            return;
        }
        
        if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
            List<ContentVersion> cvList = new List<ContentVersion>();
            for(Messaging.InboundEmail.BinaryAttachment emailAttachment : email.binaryAttachments){
                ContentVersion cv = new ContentVersion();
                cv.VersionData = emailAttachment.body;  // Using the actual file content
                cv.Title = emailAttachment.fileName;    // Using the actual file name 
                cv.PathOnClient = emailAttachment.fileName;  // Required field
                cv.ContentLocation = 'S'; // S for Salesforce storage
                cvList.add(cv);                
            }
            if(!cvList.isEmpty()){
                insert cvList;
                
                // Link ContentVersion to the parent record
                List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvList]){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = parentId;
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.ShareType = 'V'; // V for Viewer
                    cdLinks.add(cdl);
                }
                if(!cdLinks.isEmpty()){
                    insert cdLinks;
                }
            }
        } 
    }

}
