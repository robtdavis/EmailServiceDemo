public class EmailClassifier {
    public static ChatGPTIntegration__mdt config; // Assuming you have a custom metadata type for Gemini

    public static String classifyEmail(String subject, String body) {
        HttpRequest req = new HttpRequest();

        config = ChatGPTIntegration__mdt.getInstance('EmailService'); // Replace 'EmailService' with your instance name

        req.setEndpoint(config.Endpoint__c); // Use the endpoint from your custom metadata
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-goog-api-key', config.APIKey__c); // Set the API key in the header

        String prompt = 'Classify this email as Product Inquiry, Sales Order, Warranty, Order Status, or Request for More Information, The response should be surrounded by double brackets like {{Sales Order}}. The response should only contain the four categories: Subject:' + subject + ' Body:' + body;

        String payload = '{"contents": [{"parts": [{"text": "' + String.escapeSingleQuotes(prompt) + '"}]}]}'; // Correctly escape single quotes

        req.setBody(payload);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        String msg = 'Gemini Response Status: ' + res.getStatusCode();
        String msg2 = 'Gemini Response Body: ' + res.getBody();
        Logger.info(msg);
        Logger.info(msg2);
        Logger.saveLog();

        if (res.getStatusCode() == 200) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> candidates = (List<Object>) responseMap.get('candidates');

                if (candidates != null && !candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = (Map<String, Object>) candidates[0];
                    List<Object> contentParts = (List<Object>) ((Map<String,Object>)((Map<String,Object>)firstCandidate).get('content')).get('parts');

                    if (contentParts != null && !contentParts.isEmpty()) {
                        String classificationBody = (String) ((Map<String, Object>) contentParts[0]).get('text');
                        return extractClassification(classificationBody);
                    } else {
                        System.debug('Gemini: No text parts found in response.');
                        return 'Error: No classification found.';
                    }
                } else {
                    System.debug('Gemini: No candidates found in response.');
                    return 'Error: No classification found.';
                }
            } catch (Exception e) {
                System.debug('Gemini: Error parsing response: ' + e.getMessage());
                return 'Error: Could not parse response.';
            }

        } else {
            msg = 'Gemini: Error calling API: ' + res.getStatusCode() + ' - ' + res.getBody();
            System.debug(msg);
            Logger.error(msg);
            Logger.saveLog();
            return 'Error: API call failed.';
        }
        
    }

    private static String extractClassification(String responseBody){
        if(responseBody == null){
            return 'Request for More Information';
        }

        Pattern p = Pattern.compile('\\{\\{(.*?)\\}\\}');
        Matcher m = p.matcher(responseBody);

        if (m.find()) {
            return m.group(1);
        } else {
            return 'Request for More Information';
        }
    }

}