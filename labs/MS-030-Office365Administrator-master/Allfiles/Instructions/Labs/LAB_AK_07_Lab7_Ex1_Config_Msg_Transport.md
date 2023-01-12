# Module 7 - Lab 7 - Exercise 1 - Configuring message transport settings

In this exercise, you will take on the persona of Holly Dickson, Adatum’s Enterprise Administrator. As part of her pilot project for Adatum’s Exchange deployment, Holly wants to begin by creating custom send and receive connectors in her Exchange Online deployment using the Microsoft 365 Exchange admin center. Exchange uses connectors to enable incoming and outgoing mail flow in Exchange Online and between services in the transport pipeline.

You will then create a series of mail flow rules that are designed to protect Adatum’s messaging environment. You will first create a mail flow rule that adds a disclaimer message to each received email; the message will indicate that you must delete the message if you are not the intended recipient. You will then create a second rule in which any email received that was intended for Megan Bowen must be forwarded automatically to the MOD Administrator for approval first. Finally, if the Development teams sends or receives email, then journal reports will be sent to a specific web address.


### Task 1 - Create a custom send and receive connector to enforce TLS

In this task you will create two connectors to enforce Transport Layer Security (TLS) with Trey Research, one of Adatum's most important partners who deals in top-secret government information that must be encrypted within email messages. One connector will be a send (outbound) connector from Adatum to Trey Research. The second connector will be a receive (inbound) connector from Trey Research to Adatum.

**Important:** Connectors help control the flow of email messages to and from your Microsoft 365 organization. While most organizations do not require connectors, there are certain scenarios that require them. For Adatum, it frequently exchanges top-secret  information with Trey Research. As such, Adatum wants to apply security restrictions by using TLS to encrypt sensitive information.  

1. You should still be logged into **LON-CL1** as the **Administrator** account with a password of **Pa55w.rd**.

2. Your Edge browser should be open from the prior lab, with tabs open for the **Microsoft Office Home** page, the **Microsoft 365 admin center**, and the **Exchange admin center**. You should still be signed into Microsoft 365 as Holly Dickson. 

	If you closed the Exchange admin center tab after the prior lab exercise, then in the **Microsoft 365 Admin center**, under **Admin Centers** in the left-hand navigation pane, select **Exchange**.

3. In the **Exchange admin center**, in the left-hand navigation pane, expand **Mail flow**. 

4. Under **Mail flow** , select **Connectors**.

5. On the **Connectors** page, you want to add a new send connector. Select **+ Add a connector** that appears on the menu bar above the list of connectors.

6. On the **New connector** page, select **Office 365** under **Connection from**. 

	Under **Connection to**, select **Partner organization**, and then Select **Next**.

7. On the **Connector name** page, enter **Trey Research Outgoing** in the **Name** box and then select **Next**.

8. On the **Use of connector** page, select the **Only when email messages are sent to these domains** option.

	In the textbox, enter **treyresearch.net** and then select the **+**.

9. On the **Use of connector** page, select **Next**.

10. On the **Routing** page, select the  **Use the MX record associated with the partner’s domain** option and then select **Next**.

11. On the **Security restrictions** page, select the **Always use Transport Layer Security (TLS) to secure the connection** check box, select the **Issued by a trusted certificate authority (CA)** option, and then select **Next.**

12. On the **Validation email** page, in the textbox, enter **postmaster@treyresearch.net** and then select the **+**.

13. On the **Validation email** page, select **Validate**. 

	Wait while validation completes and then select **Close**. 

14. On the **Validation email** page, select **Next**. Note the status of the **Send test email** task is **Failed**.

15. On the **Validation email** page, select **Yes** to still save the connector even though the validation failed, and then select **Next** once the connector is successfully saved. 

	**Note:** Validation of mail flow to this connector will fail because the connector is for a fictitious organization that does not exist. This is expected behavior for this lab.

16. On the **Validation email** page, select **Create connector**.

17. On the **Connector created** page, select **Done**.

18. You just added a send (outbound) connector from Adatum to Trey Research. You will now create a receive (inbound) connector from Trey Research to Adatum. In the **Exchange admin center**, on the **Connectors** page, select the **+ Add a connector** icon on the menu bar to add another connector.

19. On the **New connector** page, under the **Connection from** box, select **Partner organization**. 

	Note that the **Connection to** is automatically set to **Office 365**. Select **Next**.

20. In he **Connector name** page, enter **Trey Research Incoming** in the **Name** field and then select **Next**.

21. In the **Authenticating sent email** page, select the **By verifying that the sender domain matches one of the following domains**.

22. In the textbox, enter **treyresearch.net**, then select the **+**.

23. On the **Authenticating sent email** page, select **Next**.

24. On the **Security restrictions** page, select the **Reject email messages if they aren’t sent over TLS** check box and then select **Next**.

25. On the **Review connector** page, select **Create connector**, and then select **Done** once the information is successfully saved.

26. On the **Connectors** page, you should now see the send (outbound) and receive (inbound) connectors that you just created.  

26. Leave your browser and all tabs open for the next task.

### Task 2: Create transport rules

In the next few tasks, you will create a series of mail flow rules that are designed to protect Adatum’s messaging environment. In this task, you will create a mail flow rule that adds a disclaimer message to each received email; the message will indicate that you must delete the message if you are not the intended recipient. You will then create a second rule in which any email received that was intended for Megan Bowen must be forwarded automatically to the MOD Administrator for approval first. 

1. You should still be logged into **LON-CL1** as the **Administrator** account with a password of **Pa55w.rd**.

2. Your Edge browser should be open from the prior task, with tabs open for the **Microsoft Office Home** page, the **Microsoft 365 admin center**, and the **Exchange admin center**. You should still be signed into Microsoft 365 as Holly Dickson. 

3. In the **Exchange admin center**, the **Mail flow** section in the left-hand navigation pane should still be expanded from the prior task, and on this page, the **Connectors** page should be displayed. Since you want to create a message transport rule, select **Rules** in the left-hand navigation pane.

4. You will begin by creating a rule that adds a disclaimer message to each received email. On the **Rules** page, select the **plus (+) sign** icon on the menu bar. In the menu that appears, select **Apply disclaimers**.

5. In the **new rule** window, enter the following information: 

	- In the **Name** field, enter **A. Datum Disclaimer**
	- In the **Apply this rule if** box, select **The recipient is located**. This opens a **Select sender location** window. Select **Inside the organization** and then Select **OK**.
	- To the right of the **Do the following** field, select the **Enter text** hyperlink. In the **specify disclaimer text** window, enter the following message in the text field and then select **OK**: **If you are not the intended recipient of this message, you must delete it.**
	- To the right of the **Do the following** field and below the disclaimer that you just entered, select the **Select one** hyperlink. On the **specity fallback action** window, you must select an action to be performed if the disclaimer cannot be inserted. In this case, select **Wrap** and then Select **OK**.
	- Under **Properties of this rule**, verify the **Audit this rule with severity level** check box is selected. In the corresponding field, select the drop-down arrow and then select a severity level of **Medium**.
	- In the **Choose a mode for this rule** option, select **Enforce**.

6. In the **new rule** window, select **Save**.

7. If the **Warning** window appears, select **Yes**.

8. You will now create a second mail flow rule that automatically forwards to the MOD Administrator any email intended for Megan Bowen; the MOD Administrator must approve the email before it can be forwarded to Megan. 

	On the **rules** tab, select the **plus (+) sign** icon on the menu bar. In the menu that appears, select **Send messages to a moderator**.

9. In the **new rule** window, enter the following information: 

	- In the **Name** field, enter **Messages that must be moderated** 
	- In the **Apply the rule if** box, select **The recipient is**.
	- In the **Select Members** window, select **Megan Bowen**, select **add**, and then select **OK**.
	- In the **Do the following** box, select **Forward the message for approval to**.
	- In the **Select Members** window, select **MOD Administrator**, select **add**, and then select **OK**.
	- Under **Properties of this rule**, verify the **Audit this rule with severity level** check box is selected. In the corresponding field, select the drop-down arrow and then select a severity level of **Low**.
	- In the **Choose a mode for this rule** option, select **Enforce**.

10. In the **new rule** window, select **Save**.

11. Leave your browser and all tabs open for the next task.


### Task 3: Validate the new transport rules

In this task, you will test the new transport rules that you created in the prior task. You will send an email from Patti Fernandez to Megan Bowen, which should trigger the two message transport rules. You will then verify the Disclaimer message is added to the message, and that the message is forwarded to the MOD Administrator for approval. 

1. Switch to **LON-CL2**. You should still be logged in as the **Administrator**.

2. If **Microsoft Edge** is open, you should still be logged into Microsoft 365 as Alan Yoo from an earlier lab. Log out as Alan, then close all tabs except for the **Sign out** tab. Then close your Edge browser session. 

	Once Edge is closed, then the **Edge** icon on the taskbar to open a new browser session. 

3. In **Microsoft Edge**, open a new tab and then enter the following URL in the address bar: **https://Outlook.office365.com**

4. In the **Pick an account** window, select **Use another account**. In the **Sign in** window, enter **PattiF@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is then tenant ID provided by your lab hosting provider) and select **Next**. In the **Enter password** window, enter the password provided by your lab hosting provider for the tenant admin account and then select **Sign in**.

5. In **Outlook on the web**, close the **Welcome** window.

6. In **Outlook on the web**, select the **New message** button.

7. In the email form, in the **To** field, enter **Megan**. This will display a list of users whose first name starts with Megan. Select **Megan Bowen**.

8. In the **Subject** field, enter **Message transport tests**.

9. In the message body, enter **Disclaimer message test and moderator approval test** and then select **Send**.

10. You will now sign out as Patti Fernandez and then sign into Outlook on the web as the MOD Administrator. Select the picture of Patti in the upper right corner of the screen, and in the **My account** window that appears, select **Sign out**.

11. Once you are signed out of **Outlook on the web**, enter the following URL in the address bar: **https://Outlook.office365.com**

12. In the **Pick an account** window, select **Use another account**. In the **Sign in** window, enter **admin@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is then tenant ID provided by your lab hosting provider) and select **Next**. In the **Enter password** window, enter the password provided by your lab hosting provider for the tenant admin account and then select **Sign in**.

13. In **Outlook on the web**, close the **Welcome** window.

14. In **Outlook on the web**, check the MOD Administrator's **Inbox**. If you see the message from Patti to Megan, open the message and verify the disclaimer message was added to the body of the email. 

	However, if the email is not in the MOD Admin's Inbox, check the **Junk** folder. If the email is not there, then sign out of Outlook on the web as the MOD Admin, repeat steps 11-12 to sign into Outlook on the web as **Megan Bowen** (where the username will be **MeganB@M365xZZZZZZ.onmicrosoft.com** and the password provided by your lab hosting provider for the tenant admin account. <br>

	If the email from Patti is in Megan's Inbox, then verify the disclaimer message was added. However, the fact that this email is in Megan's Inbox indicates the second message transport rule that you created has not completely propagated through Microsoft 365. Sometimes it takes several hours for transport rules to fully propagate. If this is the case, switch back to LON-CL1 and verify the **Messages that must be moderated** rule is set up properly. If everything looks OK, then wait an hour or so, switch back to LON-CL2, and then repeat this task (sign in as Patti, create the email, then sign back in as the MOD Admin to verify the email).

15. On LON-CL2, sign out of Outlook as the MOD Administrator, and then close your Edge browser session.


### Task 4 - Create a journal rule for members of the Manufacturing Group

In this task, you will create a transport rule whereby, if the Manufacturing group sends or receives email, then journal reports will be sent to a specific web address.

1. Switch to **LON-CL1**, where you should still be logged in as the **Administrator**.

2. The Edge browser should be open from the prior lab, with tabs open for the **Microsoft Office Home** page, the **Microsoft 365 admin center**, and the **Exchange admin center**. You should still be signed into Microsoft 365 as Holly Dickson. 

	If you closed the Exchange admin center tab after the prior lab exercise, then in the **Microsoft 365 Admin center**, under **Admin Centers** in the left-hand navigation pane, select **Exchange**.

3. In the **Exchange admin center**, scroll down the left-hand navigation menu and open **Classic Exchange admin center** in a new tab. Then in the classic **Exchange admin center**, in the left-hand navigation pane, select **compliance management**. 

4. On the **compliance management** page, the **In-place eDiscovery & Hold** tab is displayed by default. In the list of tabs across the top of the page, select **journal rules**.

5. On the **journal rules** page, the following line appears above the menu bar: **Send undeliverable journal reports to Select address**. The **Select address** portion of this message is hyper-linked. Select **Select address**.

6. In the **non-delivery reports** window that appears, select **Browse**. In the list of users that appears, select **MOD Administrator**, select **OK**, and then back on the **non-delivery reports** window, select **Save**.

7. In the **Warning** window, select **OK**.

8. On the **journal rules** page, select the **plus (+) sign** icon on the menu bar to add a new journal rule.

9. In the **new journal rule** window, in the **Send journal reports to** field, enter **journal@treyresearch.net**.

10. In the **Name** field, enter **Manufacturing Group Messages**.

11. In the **If the message is sent to or received from** field, select **A specific user or group**, and then in the list users and groups that appears, select **Manufacturing**, select **add**, and then select **OK**.

12. In the **Journal the following messages** field, select **All messages**, and then select **Save**.

13. Leave your browser and all tabs open for the next task.


### Task 5 - Track internal and external message delivery

1. You should still be logged into LON-CL1 as the **Administrator**.

2. The Edge browser should be open from the prior task, with tabs open for the **Microsoft Office Home** page, the **Microsoft 365 admin center**, and the **Exchange admin center**. You should still be signed into Microsoft 365 as Holly Dickson. 

	If you closed the Exchange admin center tab after the prior lab exercise, then in the **Microsoft 365 Admin center**, under **Admin Centers** in the left-hand navigation pane, select **Exchange**.

3. In the **Exchange admin center**, in the left-hand navigation pane, select **mail flow**. 

4. On the **mail flow** page, the **rules** tab is displayed by default. In the list of tabs across the top of the page, select **message trace**.

5. On the **message trace** page, note the banner at the top of the page indicating that a new and improved Message Trace has been added in the Security & Compliance center. Select **Go to the new Message Trace now**. This will open a new tab in your Edge browser for the **Security & Compliance Center**. 

6. In the **Security & Compliance Center**, in the left-hand navigation pane, select **Mail flow** and then select **Message trace**.

7. In the **message trace** window, note how it provides categories for existing search queries. Select each group to expand it to view the pre-defined queries for that group. 

8. Once you have finished reviewing the pre-defined queries, select the **+Start a trace** button.

9. In the **New message trace** window, review the search options and then select **Search**.

10. In the **Message trace search results** window, select the message sent from Patti Fernandez to Megan Bowen.

11. In the **Message trace details** window, review the information in the message. Select the arrow in the **Message events** section to expand it. In the **Event** column, note the **Transport rule** event, which applied the disclaimer transport rule.

12. If the **Message transport tests** transport rule was applied, note the event that sent the message to the MOD Administrator. 

13. Select **Close**.

14. In the **Message trace search results** window, select **Close**.

15. Close the **New message trace** window.

16. Close the **Message trace - Security & Compliance Center** tab in your browser. Leave the remaining tabs open for the next lab exercise.

 
**Results**: After completing the exercise, you will have configured message-transport settings.

# Proceed to Lab 7 - Exercise 2
