# Module 9 - Lab 9 - Exercise 3 - Configuring and verifying external user sharing

In the last two exercises, Holly Dickson has configured SharePoint Online services and SharePoint Online site collections. She is now ready to configure SharePoint Online for external sharing as part of her overall permissions planning for SharePoint in Microsoft 365.

The external sharing features of Microsoft SharePoint let users in an organization share content with people outside the organization (such as partners, vendors, clients, or customers). External sharing can also be used to share between licensed users on multiple Microsoft 365 subscriptions if your organization has more than one subscription. 

SharePoint has external sharing settings at both the organization level and the site collection level. To allow external sharing on any Adatum site, Holly must first allow it at the organization level. She can then restrict external sharing for other sites. If a site's external sharing option and the organization-level sharing option don't match, the most restrictive value will always be applied.

Even if your organization-level setting allows external sharing, not all new sites allow it by default. The default sharing setting for Microsoft 365 group-connected team sites is "New and existing guests." The default for communication sites and classic sites is "Only people in your organization."

In this exercise, Holly will allow external sharing at the organization level and for a specific site collection. She will then verify that she can share a document as well as a site within the site collection with external users. 


## Task 1: Configure global settings for external user sharing

In this task, Holly will enable external sharing at the organization level. The sharing feature that she wants to enable is in the SharePoint classic admin center and not the new SharePoint admin center.

1. You should still be on **LON-CL1**, where you should be logged in as the **Administrator** with a password of **Pa55w.rd**.

2. You should still have Microsoft Edge open from an earlier lab, along with tabs for the **Microsoft Office Home** page, **Microsoft 365 admin center**, and **SharePoint admin center**. 

	If so, proceed to the next step; otherwise, open Microsoft Edge, navigate to **https://portal.office.com/**, log in as **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) and **Pa55w.rd**, and then in the **Microsoft Office Home** page, select **Admin**, and then in the **Microsoft 365 admin center**, select **SharePoint**.

3. On the **SharePoint admin center**, in the left-hand navigation pane, select **Policies** and then select **Sharing**.

4. On the **Sharing** page, verify the **Allow only users in specific security groups to share externally** check box is not selected, in which case you can close this **Sharing** window. If this check box is selected, then unselect it and select **Save**.

5. Leave all tabs open in your browser and proceed to the next task. 



## Task 2: Configure a site collection for external user sharing

In the prior lab exercise, you created a new Marketing site collection. In this task, you will configure it to allow external sharing.

1. You should still be on **LON-CL1**, where you should be logged in as the **Administrator** with a password of **Pa55w.rd**.

2. You should still have Microsoft Edge open from an earlier lab, along with tabs for the **Microsoft Office Home** page, **Microsoft 365 admin center**, and **SharePoint admin center**.

3. In the **SharePoint admin center**, in the left-hand navigation pane, select **Sites** and then select **Active sites**.

4. On the **Active sites** page, in the list of sites, select the **Marketing** site. 

5. In the **Marketing** pane that appears on the right side of the screen, select the **Policies** tab. 

6. In the **Policies** tab, under the **External sharing** group, select **Edit**.

7. On the **Sharing** window that appears, under the **External sharing** group, the **Anyone** option should be selected by default.

	If this option is not selected, then select it now and select **Save**. If the **Anyone** option was already selected, then close the **Sharing** window.

8. Close the **Marketing** pane.

9. You must now open an In-Private browsing session for the MOD Administrator to access the new Marketing site. Right-click on the **Edge** icon on the taskbar, and in the menu that appears, select **New InPrivate window**.

10. In your **InPrivate Browsing** session, enter the following URL in the address bar: **https://portal.office.com**.

11. In the **Sign in** window, enter **admin@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider), and then select **Next**.

12. In the **Enter password** window, enter (or copy and paste in) the tenant admin password provided by your lab hosting provider and then select **Sign in**.

13. On the **Stay signed in?** window, select **Don't show this again** and then select **Yes**. 

14. This opens the **Microsoft Office Home** tab in your Edge browser. Open a new tab in your browser and enter the following URL in the address bar: **https://M365xZZZZZZ.sharepoint.com/sites/Marketing** (where ZZZZZZ is the tenant ID provided by your lab hosting provider).

15. In the **Marketing** site, in the top-right corner, select **SHARE**.

16. In the **Share site** window, you can expand the owners, members, and groups to see that the site is currently shared with Nestor Wilke, Joni Sherman, and Patti Fernandez. 

17. On the **Share site** window, below the **Add users, Microsoft 365 Groups...** text, enter your personal email address. Your email address will appear in a list below this field; select this address now.  

	Your email addres will appear below this field, along with a message indicating it is outside of Adatum's organization. 

18. In the **Add a message** field, enter the following message: **You can now access the SharePoint site collection for Adatum's Marketing team.** 

19. Select **Share**.

20. On the **Marketing** page, in the menu-bar, select **Documents**.

21. On the **Documents** page, in the menu bar, select **+ New**, and then in the drop-down menu that appears, select **Word document**.

22. **Word Online** will open in a new tab in your browser. In the **Your privacy option** window that appears, select **Close**.

23. In the blank **Word** document, type some text, and then wait for the document to be automatically saved. Once it is saved, the word **Saved** will appear in the document title. Once the document is saved, select the drop-down arrow that appears to the right of **Saved**. In the drop-down menu that appears, in the **Location** field, the path **Marketing - Shared Documents** appears (where each is hyperlinked). Select the **Shared Documents** link. 

24. This will open the **Marketing** site and the **Documents** tab. In the **Documents** page, the document that you just created (Document.docx, since you did not name it), should appear in the documents list.

25. In the document list, select the vertical ellipsis icon to the right of the document name, and in the menu that appears, select **Share**.

26. In the **Send link** window that appears, select **Anyone with the link can edit**. 

27. In the **Link settings** window that appears, under the **Who would you like this link to work for?** section, select **Anyone with this link** and then select **Apply**.

28. In the **Send link** window, in the **Enter a name or email address**, enter your personal email address, and enter **This document is shared with you. You have edit permissions.** in the **Add a message (optional)** field. Select **Send**.

29. Close the **Link sent** window that appears.

30. Select **Close**.

31. Close the InPrivage browsing session for the **MOD Administrator**.

32. Leave all tabs open in your browser and proceed to the next task. 

## Task 3: Verify external user sharing

1. Navigate to your personal email maibox. 

2. The Inbox should include two emails from Microsoft Online Services Team. If the messages are not in the Inbox, look in the Junk folder. 

3. Open the message that has the subject: **MOD Administrator wants to share Marketing**. 

4. Select the **Marketing** link in the email.

5. Select either **Microsoft Account** or **Organizational Account** depending the email account type and verify that you can access the **Marketing** site. Select the **Documents** tab and verify you can access the shared document.

6. In your Inbox, open the second invitation email message with the subject of **MOD Administrator wants to share the document**.

7. Select the **Document** link. 

	**Note:** You are redirected directly to the Word Document. Word Online opens and displays the document.

8. Verify that you can access the Word document and then select **Edit in Browser**. 

9. Add some text in this document. Close the document and then re-open it to verify your changes appear. 

10. On the **Microsoft Office Home** page, select the user icon (the circle with Holly Dickson's **HD** initials in it) in the upper right-hand corner, and in the **My account** window that appears, select **Sign out**. Once you are signed out, close all other tabs, and then close Microsoft Edge.  


**Results**: After completing this exercise, you should have configured a new site collection for external user sharing, and you should have shared a site and a document with external users.

# End of Lab 9
 
