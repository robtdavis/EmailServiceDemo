// Salesforce Record Creation Utility
public class SalesforceRecordCreator {

    public static void createCase(Messaging.InboundEmail email, String type){
        Case c = new Case();
        c.Subject = (type == 'Unable to Determine Email Type' ? 'Unable to Determine Email Type: ' : '') + Type+' '+email.subject;
        c.Description = email.plainTextBody;
        c.Origin = 'Email';
        insert c;

        attachEmailAndFiles(c.Id, email);
    }

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
        EmailMessage emailMsg = new EmailMessage(
            ParentId = parentId,
            FromAddress = email.fromAddress,
            Incoming = true,
            Subject = email.subject,
            TextBody = email.plainTextBody
        );
        insert emailMsg;
    
        List<ContentVersion> files = new List<ContentVersion>();
        if (email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) { // Check for attachments
            for(Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments){
                files.add(new ContentVersion(
                    Title = att.fileName,
                    PathOnClient = att.fileName,
                    VersionData = att.body
                ));
            }
            insert files;
        }
    }

    private static void relateOrderIfPresent(Messaging.InboundEmail email, Opportunity opp){
        Pattern orderPattern = Pattern.compile('Order\\s?#?:?\\s?(\\d+)');
        Matcher matcher = orderPattern.matcher(email.plainTextBody);
        if(matcher.find()){
            String orderNumber = matcher.group(1);
            Order order = [SELECT Id FROM Order WHERE OrderNumber = :orderNumber LIMIT 1];
            opp.Order = order.Id;
            update opp;
        }
    }
}
