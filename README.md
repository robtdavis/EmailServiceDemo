# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)


# Resources

- [Nebula Logger Article from Salesforce Ben](https://www.salesforceben.com/easily-debug-salesforce-using-nebula-logger/)
    - [Package Links](https://github.com/jongpie/NebulaLogger/)
- [Connecting with ChatGPT from Salesforce Ben](https://www.salesforceben.com/integrating-openais-chatgpt-with-the-salesforce-appexchange/)
- [Gemini's Pricing Tiers](https://ai.google.dev/gemini-api/docs/pricing)


- [Bob Buzzard Blog about Keeping Your Agentforce DEv Org Alive and Kicking](https://bobbuzzard.blogspot.com/2025/03/keep-your-agentforce-dev-org-alive-and.html)

- Flow that will cause Error is : [Generate Contact Error](https://orgfarm-6e403d0beb-dev-ed.develop.lightning.force.com/builder_platform_interaction/flowBuilder.app?flowDefId=300gL000000s2Pq&retUrl=/lightning/r/FlowRecord/2aFgL000000OsiPUAS/view)
  - Create a new contact that starts with a J and attempts to insert long screen and will generate an error that can then be used to send to the logging Email to simulate forwarding by Outlook.


Inbound Email Service:

- Product Inquiry:
   Subject: Question about the ZX3000 Product Line

Body:
Hello,

I’m interested in learning more about the ZX3000 model—specifically the available features and pricing tiers. Could you please send over a product brochure or spec sheet?

Thanks,  
Taylor Morgan
-----------------------------------------------------------------------------------------------------------------------------------------
- Sales Order:
   Subject: New Sales Order for 15 Units of XYZ Toolkits

Body:
Hi,

We’d like to place an order for 15 units of the XYZ Toolkit, model 456T. Please let us know the next steps for invoicing and delivery.  
PO# 8723-A

Regards,  
Jordan Lee

--------------------------------------------------------------------------------------------------------------------------------------------
- Warranty:
Subject: Warranty Claim for Model QRT-100

Body:
Hello,

I’m submitting a warranty request for the QRT-100 device purchased last September. It stopped powering on last week.  
The serial number is SN-88217, and I have attached a copy of the purchase invoice.

Thank you,  
Avery Thompson

--------------------------------------------------------------------------------------------------------------------------------------------
- Need More Details on Installation Options

Subject: Need More Details on Installation Options

Body:
Hi team,

Could you provide more information about the installation services you offer for enterprise clients?  
I’m specifically looking for support in the Midwest region.

Best,  
Jamie Alvarez
--------------------------------------------------------------------------------------------------------------------------------------------
- Unable to Determine Email Type

Subject: Just Checking In

Body:
Hey folks,

Just checking in to see if you received my last message. Looking forward to hearing from you.

Best,  
Sam