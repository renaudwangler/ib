# Module 12 - Lab 12 - Exercise 2 - Troubleshooting Mail Flow Issues

The logical conclusion to monitoring Microsoft 365 service health is the ability to troubleshoot errors that occur in the system. For Holly Dickson, this means monitoring mail-related issues, which have been a nagging issue for Adatum in the past. Holly plans to take advantage of Microsoft's Exchange Remote Connectivity Analyzer tool to troubleshoot mail-flow issues. The tool is web-based and is designed to help IT Administrators troubleshoot connectivity issues that affect their Microsoft Exchange deployments. The tool simulates several client log-on and mail flow scenarios. When a test fails, many of the errors have troubleshooting tips to assist the IT Administrator to correct the problem.

Holly plans to test this tool by sending email to a non-existent domain and to a non-existent user and then use the tool to troubleshoot the errors that occur. She will then test message tracing to help troubleshoot mail-flow issues. Message tracing in the Security and Compliance Center follows email messages as they travel through an Exchange Online organization. Holly will use message tracing to determine if a message was received, rejected, deferred, or delivered by the service. She will also use it to show what actions were taken on the message before it reached its final status.

### Task 1 - Send an email to a non-existent domain

1. On **LON-CL1** you should still be logged in as the **Administrator** from the prior lab exercise. 

2. Your Edge browser should still be open, and you should be logged into Microsoft 365 as Holly Dickson. You should have tabs open for the **Microsoft Office Home** page and the **Microsoft 365 admin center**.

3. Select the **Microsoft Office Home** tab, and in the Office portal, select **Outlook**.

4. In **Outlook on the web**, select **New message**.

5. In the message form, type **user@alt.none** in the **To** box.

6. Enter a subject and some body text and then select **Send**.

7. Wait for the delivery failure message to appear.

8. Once the delivery failure message arrives, select the delivery failure message. Note the reason for the failure: **The Domain Name System (DNS) reported that the recipient's domain does not exist.**

9. Scroll down in the text portion of the message to the **Diagnostic information for administrators** section. Select all the text in this section (starting with **Generating server** down to the end of this diagnostic data), and then press **Ctrl+C** to copy it to the clipboard. 

10. In Microsoft Edge, open a new tab and enter the following URL in the address bar: **https://testconnectivity.microsoft.com**

11. This opens the **Microsoft Remote Connectivity Analyzer** page. In the left-hand navigation pane, select the **Message Analyzer** tab.

12. In the **Message Header Analyzer** page, in the section that displays **Paste headers here**, press **Ctrl-V** to paste in the header data that you copied to the clipboard, and then select **Analyze headers**.

13. Review the diagnostic information and the time taken for the message to be rejected.

14. Select **Clear** to reset the Message Header Analyzer.

15. Leave the Edge browser and all tabs open and proceed to the next task.



### Task 2 - Send an email to a non-existent user

1. In the **Edge** browser, select the **Outlook** tab for Holly Dickson.

2. In **Outlook on the web**, select **New message**.

3. In the message form, type **ynotknirf082760@outlook.com** in the **To** box.

4. Enter a subject and some body text and then select **Send**.

5. Wait for the delivery failure message to appear. 

6. Once the delivery failure message arrives, select the delivery failure message. Note the reason for the failure: **Requested action not taken: mailbox unavailable**

7. Scroll down in the text portion of the message to the **Diagnostic information for administrators** section. Select all the text in this section (starting with **Generating server** down to the end of this diagnostic data), and then press **Ctrl+C** to copy it to the clipboard. 

8. In Microsoft Edge, select the **Message Analyzer** tab.

9. In the **Message Header Analyzer** page, in the section that displays **Paste headers here**, press **Ctrl-V** to paste in the header data that you copied to the clipboard, and then select **Analyze headers**.

10. Review the diagnostic information and the time taken for the message to be rejected.

11. Select **Clear** to reset the Message Header Analyzer.

12. In the **Edge** browser, close all tabs except for the **Microsoft Office Home** tab. 

### Task 3 - Analyze mail flow

In this task, you will conduct a message trace to monitor message flow. Note that the original Message Trace feature was provided through the Exchange Online admin center. However, a new and improved Message Trace feature has been added to the Security and Compliance Center, which is the message trace feature that will be used in this lab.

1. In the **Edge** browser on **LON-CL1**, the **Microsoft Office Home** tab should still be open from the prior task. In this tab, select **Admin**. 

2. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Show all**, and then under **Admin centers** select **Security**.

3. In the **Office 365 Security and Compliance** center, in the left-hand navigation pane, select **Mail flow** and then select **Message trace**.

4. In **Message trace** page, note the existing queries that you can use. However, in this case, you will create a custom message trace. Select **+Start a trace**.

5. In the **New message trace** window, select the **By these people** field. In the list of users that appears, select **Holly Dickson**.

6. In the **Within this time range** chart, move the slider to **1 day** (this will show the past 24 hours).

7. Select **More search options**, and then in the **Delivery status** field, select **Failed**.

8. Select **Search**. 

9. On the **Message trace search results** page, note the two messages that appear. Double-click the message for the non-existent user. This opens the **Message trace details** pane, which displays the detailed information for the message, including the sender, recipient, message size, ID, and IP address information. <br/>

	Select the **Message events** and **More information** sections to expand them. As you review the information, pay special note to the following data: Receive, Submit, Span. Diagnostics, and Faild.  Close the pane when you are finished.

10. Repeat the prior step for the non-existent domain message. 

11. Close the Message Trace window.

# End of Lab 12