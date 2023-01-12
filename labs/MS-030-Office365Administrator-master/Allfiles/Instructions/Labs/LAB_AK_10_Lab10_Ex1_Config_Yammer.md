# Module 10 - Lab 10 - Exercise 1 - Configuring Yammer Enterprise

Because Yammer Enterprise brings the rich social experiences of Yammer to Microsoft Teams, SharePoint Online, and other Microsoft 365 apps, Holly Dickson is interested in implementing Microsoft Yammer in Adatum's Microsoft 365 pilot project. This will enable Adatum users to share, create, and edit files directly from Yammer conversations with Office for the web.

In this exercise Holly will configure the Yammer organizational settings for Adatum. She will also configure Yammer to enforce Microsoft 365 identity, which enables single sign-on (SSO) capabilities in Yammer. Holly will complete her Yammer preparation by configuring the Yammer user experience. 

### Task 1 - Configure a Yammer organization setting

1. On **LON-CL1**, you should still be logged in as the **Administrator** with a password of **Pa55w.rd**.

2. Please close all browser sessions you currently have open. This will enable you to start with a fresh browsing session. 

	With Edge closed, select the **Edge** icon on the taskbar to open a new session. 

3. In Edge, enter the following URL in the address bar: **https://portal.office.com**.

4. In the **Pick an account** window, select Holly Dickson's account (**Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider)). In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in**.

5. On the **Stay signed in?** window, select **Don't show this again** and then select **Yes**.

6. On the **Microsoft Office Home** page, select **Yammer**.

	- If the **Welcome to the new Yammer** window appears, close it by selecting the **X** in the upper right-hand corner.

7. On the **Yammer** home page, on the right-side of the title bar at the top of the page, select the **gear (Settings)** icon.

8. In the **Settings** pane that appears, under the **Yammer** section, select **Edit network admin settings**. This opens the **Yammer admin center**.

9. In the **Yammer admin center**, in the left-hand navigation pane, under the **Network** group, select **Usage Policy**.

10. In the **Usage Policy** window, update the following settings: 

	- Select the **Require users to accept policy during sign up and after any changes are made to the policy** check box.
	- Select the **Display policy reminder in sidebar** check box.
	- In the **Custom Policy Title** field, enter **M365x Acceptable Use Policy**.
	- In the **Enter your policy in the textbox below** field, copy and paste in the following text: **Welcome to Yammer! Our goal is to provide a collaborative environment to connect with colleagues and bridge various departments and geographic locations to share meaningful information.**

11. Select **Save**.

12. In the **M365x Acceptable Use Policy** window that appears, select **I Accept**. 

13. If the **Welcome to the new Yammer!** window appears again, select the **X** in the upper right-hand corner to close it.

14. On the **Yammer** home page, on the right-side of the title bar at the top of the page, select the **gear (Settings)** icon.

15. In the **Settings** pane that appears, under the **Yammer** section, select **Edit network admin settings**. This opens the **Yammer admin center**.

16. In the **Yammer admin center**, in the left-hand navigation pane, under the **Network** group, select **Configuration**.

17. On the **Configuration** page, in the **Email Settings** section, select the **Require all users in your network to confirm their messages posted via email before posting** check box.

18. In the **Enabled Features** section, remove the check mark from **3rd Party Applications** to disable this feature.

19. Select **Save**.

20. In the **Yammer admin center**, in the left-hand navigation pane, under the **Content and Security** group, select **Data Retention**.

21. In the **Data Retention Policy** page, read the description of available options and select **Archive** (if it's not already selected) and then Select **Save**.

22. In the **Yammer admin center**, in the left-hand navigation pane, under the **Content and Security** group, select **Monitor Keywords**.

23. In the **Monitor Keywords** page, enter **admin@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) in the **Email Address** field.

24. In the text box below the **Email Address**  field, enter the following words, one in each line: **gambling**, **erotic**, **warez**.

25. Select **Save**. 

26. In the **Yammer admin center**, in the left-hand navigation pane, under the **Content and Security** section, select **Security Settings**.

27. Under the **Office 365 Identity Enforcement** section, verify the **Enforce Office 365  identity** check box is selected by default and then select **Save**.

28. In your Edge browser, close the **Yammer admin center** tab and proceed to the next task.


### Task 2 - Configure the Yammer user experience

1. On **LON-CL1**, you should still be logged in as the **Administrator** with a password of **Pa55w.rd**.

2. At the end of the prior task, you were instructed to close the **Yammer admin center** tab. If you did not do it, then please do so now. 

3. In your Edge browser, you will re-open Yammer to start a fresh session with the updated configuration settings from the prior task. On the **Microsoft Office Home** page, select **Yammer**.

4. On the **Yammer** home page, on the right-side of the title bar at the top of the page, select the **gear (Settings)** icon.

5. In the **Settings** pane that appears, under the **Yammer** section, select **Edit settings**. This opens the **Account Settings** page.

6. the **Account Settings** page, select the **Notifications** tab at the top of the page.

7. In the list of notifications, all the check boxes in the **Email me when...** section are selected. Unselect all the check boxes except for these three: 

	- **I receive a message in my inbox**
	- **I log in from somewhere new**
	- **I post a message via email (This will send a confirmation email)**

	Verfify that only these three check boxes are selected and all other check boxes are now blank.

8. Select **Save**.

9. Leave your Edge browsing session open, but close the **Yammer: Notifications** tab and proceed to the next task.


### Task 3 - Using Yammer

In this task, you will log into Yammer as Nestor Wilke and verify that you receive the Acceptable Use Policy statement that Holly configured in the earlier task.

1. Switch to **LON-CL2**. The last time you used LON-CL2, you were logged into Outlook on the web as the MOD Administrator. You were then instructed to log out of Outlook and close your Edge browsing session at the end of the lab. If your Edge browser is still open, then close it now. 

2. Select the **Microsoft Edge** icon on the taskbar to open a new Edge browsing session, and then enter the following URL in the address bar: **https://portal.office.com**.

3. In the **Pick an account** window, if Nestor Wilke's **NestorW@M365xZZZZZZ.onmicrosoft.com** account appears in the list, then select it now; otherwise, select **Use another account**, sign in as **NestorW@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider), and enter (or copy and paste in) the tenant admin password provided by your lab hosting provider. 

4. On the **Microsoft Office Home** page, select **Yammer**.

5. If a **Welcome to the new Yammer!** window appears, then close it.

6. A **M365x Acceptable Use Policy** dialog box should appear that displays the Welcome message that Holly configured in the earlier task. Select **I accept**. 

	You have now verified that a user who is signing into Yammer for the first time receives the Acceptable Use Policy statment. If Nestor were to sign out of Yammer and then sign back in, the **M365x Acceptable Use Policy** dialog box would not appear, since he already accepted it. 


**Results**: After completing this exercise, you should have enabled Yammer Enterprise for ADatum Corporation.

# Proceed to Lab 10 - Exercise 2