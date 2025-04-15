public class EmailClassifier {
    public static AI_Integration_Config__mdt config;

    public static String classifyEmail(String subject, String body) {
        // Initialize configuration - get the values for config
        initializeConfig();
        
        // Prepare and send request
        HttpResponse response = sendClassificationRequest(subject, body);
        
        // Log the response
        logResponse(response);
        
        // Process the response
        return processResponse(response);
    }
    
    // Get Values from Custom metadata
    private static void initializeConfig() {
        config = AI_Integration_Config__mdt.getInstance('EmailService');
    }
    
    // Make the callout
    private static HttpResponse sendClassificationRequest(String subject, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-goog-api-key', config.APIKey__c);
        
        String payload = buildRequestPayload(subject, body);
        req.setBody(payload);
        
        Http http = new Http();
        return http.send(req);
    }
    
    private static String buildRequestPayload(String subject, String body) {
        String prompt = 'Classify this email as Product Inquiry, Sales Order, Warranty, Order Status, or Request for More Information, The response should be surrounded by double brackets like {{Sales Order}}. The response should only contain the four categories: Subject:' + subject + ' Body:' + body;
        return '{"contents": [{"parts": [{"text": "' + String.escapeSingleQuotes(prompt) + '"}]}]}';
    }
    
    private static void logResponse(HttpResponse response) {
        String statusMessage = 'Gemini Response Status: ' + response.getStatusCode();
        String bodyMessage = 'Gemini Response Body: ' + response.getBody();
        Logger.info(statusMessage);
        Logger.info(bodyMessage);
        Logger.saveLog();
    }
    
    private static String processResponse(HttpResponse response) {
        if (response.getStatusCode() == 200) {
            return extractClassificationFromResponse(response.getBody());
        } else {
            String errorMsg = 'Gemini: Error calling API: ' + response.getStatusCode() + ' - ' + response.getBody();
            System.debug(errorMsg);
            Logger.error(errorMsg);
            Logger.saveLog();
            return 'Error: API call failed.';
        }
    }
    
    private static String extractClassificationFromResponse(String responseBody) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
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