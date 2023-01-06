# Cohesity Create or Update ServiceNow Incident
## Summary
This playbook creates a ticket in ServiceNow. It can be also used for updating ticket information or closing it. For example, an automation rule can be created to close the ServiceNow ticket by running this playbook when the corresponding Sentinel ticket is closed.

## Prerequisites
1. Create an account for [ServiceNow](https://signon.service-now.com/x_snc_sso_auth.do).

## Deployment instructions
1. Deploy the playbook by clicking on the "Deploy to Azure" button. This will take you to deploying an ARM Template wizard.
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcohesity%2FAzure-Sentinel%2FCohesitySecurity.internal%2FSolutions%2FCohesitySecurity%2FPlaybooks%2FCohesity_CreateOrUpdate_ServiceNow_Incident%2Fazuredeploy.json)
2. Fill in the required parameters:
* __Playbook Name:__ Enter the playbook name here.

## Post-Deployment instructions
1. Enter and authorize ServiceNow credentials in the playbook (read more about editing connections [here](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/understanding-api-connections-for-your-microsoft-sentinel/ba-p/2593973))
* Go to _Logic Apps_.
* Choose your app (playbook).
* Select _Development Tools\API Connections_.
* Select a connection you'd like to authorize.
* Click on General\Edit API Connection.
* Enter path to your instance, e.g. dev12345
* Enter username.
* Enter password.
* Click Save.

**Note:** You can get the credentials at your ServiceNow instance by going to _My account\Instance Action\Manage instance password_.

Alternatively, you can follow these steps to achieve the same goal. This would be especially useful if the previous steps didn’t work for you.
* Go to _Logic Apps_.
* Click on the playbook and press _Edit_.
* Choose _ServiceNow_ block.
* Click on _Change Connection_.
* Click on the "!" icon to enter ServiceNow credentials or choose a different, previously authorized, connection with the correct credentials.
* Press _Save_ button to save changes in your playbook. 
* If it doesn't work, repeat the steps but either choose a different connection or fix possible authorization errors, e.g. wrong user/password or incorrect path to the instance, for the chosen one.

2. For the playbook to run, there is a need to assign the Microsoft Sentinel Responder role to the playbook's managed identity.
* Under the _Subscriptions_ tab from the _Home_ page, choose your subscription name.
* Choose the _Access Control (IAM)_ option from the left pane.
* Click on _Add > Add Role Assignment_ and add _Microsoft Sentinel Responder_ managed identity role to the playbook.

3. (Recommendation) You can create an automation rule to close the corresponding ServiceNow ticket when the corresponding Sentinel ticket is closed.
* In _Microsoft Sentinel | Automation_ press _+Create\Automation Rule_.
* Enter an automation rule name of your choice.
* Set the following conditions
  * _Analytic rule name_ contains **All**.
  * _Tag_ contains **SNOW System ID**.
  * _Status_ changed to **Closed**.
* In _Actions_ choose to run this playbook.
* Click _Apply_.

#  References
 - [Cohesity support documentation](https://docs.cohesity.com/ui/login?redirectPath=%2FHomePage%2FContent%2FTechGuides%2FTechnicalGuides.htm)