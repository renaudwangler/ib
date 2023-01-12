# Module 3 - Lab 3 - Exercise 2 - Connecting Office 2016 clients

Microsoft 365 is designed to enable customers all over the world to connect to the service using an internet connection. As the service evolves, the security, performance, and reliability of Microsoft 365 are improved based on customers using the internet to establish a connection to the service. Customers planning to use Microsoft 365 should assess their existing and forecasted internet connectivity needs as a part of the deployment project. For enterprise class deployments, reliable and appropriately sized internet connectivity is a critical part of consuming Microsoft 365 features and scenarios.

Network evaluations can be performed by many different people and organizations depending on your size and preferences. The network scope of the assessment can also vary depending on where you're at in your deployment process. Holly Dickson, Adatum's Enterprise Administrator, wants to being assessing Microsoft 365 network connectivity for Adatum. In this task, she will begin her assessment by verifying that different users can log into Outlook 2016 and connect to Exchange Online from different client PC's.


## Task 1: Verify that Outlook 2016 can connect to Microsoft 365

In this task, you will begin in LON-CL1, where you will log into Outlook 2016 as the MOD Administrator and you will verify that you are connected to Exchange Online. You will then switch to LON-CL2, where you will repeat these steps, this time logged in as Holly Dickson. 

1. On **LON-CL1**, select the Windows icon in the lower left corner of the taskbar to display the Start menu. Scroll down through and menu and select **Outlook 2016**. This initiates the Outlook 2016 setup wizard.

2. On the **Welcome to Outlook 2016** window, select **Next**.

3. On the **Add an Email Account** page, the **Do you want to set up Outlook to connect to an email account?** option is set to **Yes** by default. Accept this default setting by selecting **Next**. 

4. On the **Auto Account Setup** page, enter the following information, and then Select **Next**:

	- Your Name: **MOD Administrator**

	- E-mail Address: **admin@M365xZZZZZZ.onmicrosoft.com** (replace ZZZZZZ with the tenant ID provided by your lab hosting provider) 

	- Password: copy and paste in the tenant password provided by your lab hosting provider

	- Retype Password: copy and paste in the tenant password provided by your lab hosting provider

	- Manual setup or additional server types - do not select this option

5. Select **Next**. The wizard will begin configuring Outlook 2016. 

6. During the configuration process, Outlook will attempt to make an encrypted connection to the Exchange Online mail server using the MOD Administrator's email address. An **Enter password** dialog box will appear that asks you to enter the password for the **admin@M365xZZZZZZ.onmicrosoft.com** account. Copy and paste in the tenant password provided by your lab hosting provider and then select **Sign in**. 

7. Once the configuration is complete and a message is displayed indicating your email account was successfully configured and is ready to use, select **Finish**.

8. The **Microsoft Office Activation Wizard** will begin. Select **Close**.

9. In the **First things first** dialog box, Select **Ask me later** and then select **Accept**. 

10. Verify that you are connected to Exchange Online by creating a new email message and sending it to Holly Dickson's email account. On the ribbon at the top of the page, select **New Email**. In the new email message form, select **To**, and then in the **Global Address List** select **Holly Dickson**, select **To**, and then select **OK**. Enter **Test message** in the **Subject** line and the body of the message and then select **Send**.

11. Switch to **LON-CL2**. Log in as the **Administrator** with a password of **Pa55w.rd**.

12. If a **Networks** pane appears, select **Yes** to allow the PC to be discoverable by other PCs on this network. 

13. 2. Open **Microsoft Edge** . In your browser go to the **Microsoft Office Home** page by entering the following URL in the address bar: **https://portal.office.com/** 

14. In the **Pick an account** window, select **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your tenant ID provided by your lab hosting provider).

15. In the **Enter password** dialog box, enter **Pa55w.rd** and then select **Sign in**.

16. In the **Microsoft Office Home** page, select **Outlook**, which opens the Outlook in a new tab. 

17. Once Outlook is  open, verify in Holly's **Inbox** that she received the email from the **MOD Administrator** that you just sent to her. In turn, reply to the email by sending a Reply message back to the **MOD administrator**.

18. Close **Edge** on LON-CL2.

19. Switch back to LON-CL1.

20. Verify that Holly's reply is received into the MOD Administrator's Inbox in Outlook. By configuring Outlook for the MOD Admin's mailbox and Holly's mailbox and sending emails back and forth between the two users using two different PCs, you have verified that Outlook is connected to Exchange Online in Microsoft 365 and that an encrypted connection to your mail server is available.

21. Close Outlook on LON-CL1.


# End of Lab 3