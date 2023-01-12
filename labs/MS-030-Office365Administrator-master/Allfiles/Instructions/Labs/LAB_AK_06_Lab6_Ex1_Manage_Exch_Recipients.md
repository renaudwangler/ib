# Module 6 - Lab 6 - Exercise 1 - Managing Exchange Online recipients

As part of its Microsoft 365 deployment, Adatum wants to implement Exchange Online. As part of Adatum's pilot project, Holly Dickson, Adatum's Enterprise Admin, wants to investigate three key features related to mail flow recipients within Exchange Online - user mailboxes, groups, and contacts. 

Holly will begin by creating user accounts and mailboxes in Exchange Online. She will then create two types of groups within Exchange Online. The first will be a distribution list of email recipients, which is used to create a one-stop email list for contacting users simultaneously rather than having to email each recipient individually. The second type of group is a Microsoft 365 group.

One of the key features of Exchange Online is the ability to maintain different types of contacts in the Exchange Admin Center. Holly will complete this exercise by implementing mail contacts and mail users.

### Task 1 – Manage Recipients

As you continue in your role as Holly Dickson, you are ready to review the steps involved in creating and managing mail flow recipients in Exchange Online.

1. Switch to LON-CL1, where you should still be logged in as the **ADATUM\Administrator** with a password of **Pa55w.rd**.

2. You should still have **Microsoft Edge** open and the **Microsoft 365 admin center** open from the prior lab. If so, proceed to the next step; otherwise, open **Edge**, navigate to **https://admin.microsoft.com/**, log in as **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) and **Pa55w.rd**.

3. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Show all** (if necessary), then scroll down to **Admin centers** and select **Exchange**. This will open the **Exchange admin center** for Exchange Online.

4. In the **Exchange admin center,** in the **Receipients** group, select **Mailboxes** in the left-hand navigation pane.

5. In the **Mailboxes** view, the mailboxes that appear include all the user accounts that were pre-created in your tenant by the lab hosting provider, along with mailboxes for users that you created in Lab 2 that were assigned an Office 365 license (Holly, Ada Russell, Alan Yoo, Catherine Richard, and Tameka Reed). Note the users that you created in the earlier lab that were not assigned a license (such as Adam Hobbs) do not have an Exchange Online mailbox.

	Select the mailbox for **Joni Sherman** by selecting on her **DISPLAY NAME.** This will open the **User Mailbox** window with Joni’s data prefilled. 

6.  The **Mailbox** tab is displayed by default. 

7. Under **More actions**, select the **Custom attributes**. 

8. This opens the **Custom attributes** window for Joni. You can enter up to 15 attributes. You will not be entering any attributes in this lab exercise, but it’s important that you know this feature is available. Select **Cancel**.   <br/>

	‎**Note:** Custom attributes are properties your company can use for specific mailbox identification, such as a cost center number for the mailbox or other information such as an HR personnel number.

9. In addition to the **Custom attributes**, the **User Mailbox** window includes several other links you can follow to make changes to a mailbox. While you will not enter any of this optional information for the purposes of this lab, take a few minutes now and select the following links to see what can be configured:

	- **Manage mail flow settings** This enables you to configure forwarding, size, and delivery restrictions.

	- **Manage mailbox policies** This enables you to configure retention, sharing, and address book policies.

	- **Manage mailbox archive** This enables you to toggle the mailbox archive.
	
10. Under **Mailbox permissions**, select **Manage mailbox delegation.** This option allows the admin to assign a user to this mailbox’s Send As, Send on Behalf, or Read and Manage (Full Access) permissions. This option is commonly used if you want another user to be able to send messages from this mailbox.

	To the right of **Read and manage**, select **Edit**. 

11. In the **Manage mailbox delegation** window select **+ Add permissions**, select **Holly Dickson**, and then select **Save**.

	‎**Note:** After about an hour Holly Dickson will be able to access Joni’s mailbox without needing a password.

12. On the **Mailbox permissions added** window, select **Close**, and then select the **X** in the upper right-hand corner **three** times to return to the list of mailboxes.

13. Leave your browser and all the tabs open for the next task.

 
### Task 2 – Manage Groups 

In this task you will create two types of groups within Exchange Online. The first is a distribution list of email recipients, which is used to create a one-stop email list for contacting users simultaneously rather than having to email each recipient individually. The second type of group is an Office 365 group.

1. You should still be in LON-CL1 and your browser should still be open to the **Exchange admin center** from the prior task, where it should still be displaying **Mailboxes**. In the prior task, you worked with user accounts using **Mailboxes**. In this task, you will be creating groups, so select **Groups** under the **Recipients** group.

	**Note:** If you select the **Mail-enabled security** tab, you should see the Manufacturing group that you created in an earlier lab.

2.	From any of the four tabs, select **Add a group**.

3. In the **Choose a group type** window, select **Distribution**, and select **Next**.

4. In the **Set up the basics** window, enter the following information and then select **Next**:

	- Name: **Sales Department**

	- Description: **Sales department users**

5. In the **Edit settings** window, enter **salesdept** for the **Group email address**, leave all other settings with their default values, and select **Next**.

6. In the **Review and finish adding group** wndow, select **Create group**, and then on the **Sales Department is created** window, select **Close**.

7. From the **Distribution list** tab, select the **Sales Department** group, and then select **Members**.

8. Since you are logged into the EAC using Holly Dickson, her account is displayed as the default Owner. However, Holly wants Alex Wilber to co-own the group, so select the **View all and manage owners**, select **+Add owners** window, select **Alex Wilber**, select the **Add (1)** button, and then select the left-arrow **<-** in the upper left-hand corner.

9. To add members, select **View all and manage members**, and in the **Members** window, select **+Add members**

10. Select **Allan Deyoung**. Then hold down the **Ctrl** key and select **Diego Siciliani** and **Lynne Robbins**. This will select all three users at once, at which point you should select the **Add (3)** button and then select **OK**. 

11. Close the **Members** window by selecting the **X** in the upper right-hand corner.

12. From any of the four tabs, select **Add a group**. Ensure **Microsoft 365 (recommended)** is selected and select **Next**.

13. In the **Set up the basics** window that appears, enter the following information and then select **Next**:

	- Name: **Dynamics CRM Project Team**

	- Description: **Group of all company employees working on the Microsoft Dynamics CRM project.**

14. In the **Assign owners** window, select **+ Assign owners**.

15.	Select the **Holly Dickson** with the Holly@M365xZZZZZZ **.onmicrosoft.com** email address, and then select **Add (1)** and select **Next**.

16. In the **Add members** window, select **+ Add members**.

17. Select **Isaiah Langer**. Then hold down the **Ctrl** key and select **Joni Sherman**, and **Patti Fernandez**. This process will select all three users. Select the **Add (3)** button and then select **Next** 

18. In the **Edit settings** window, enter **DynCRM** for the **Group email address**, and then select **Create group**.

19. In the **Dynamics CRM Project Team is created** window, select **Edit group settings**.

20. In the **Dynamics CRM Project Team** window that opens, select the **Settings** tab and then select **Send copies of group conversations and events to group members**.

21. Select **Save**, and once saved, close the window by selecting the **X** in the upper right-hand corner.


### Task 3 – Manage Resources

A room mailbox is a resource mailbox that is assigned to a physical location, such as a conference room, an auditorium, or a training room. Users can easily reserve these rooms by including room mailboxes in their meeting requests. Adatum’s CTO wants to test this feature using the company’s most popular conference room, and he has asked Holly to configure this resource.

1. You should still be in LON-CL1 and your browser should still be open to the **Exchange admin center** from the prior task, where it should still be displaying **Groups** from the left-hand navigation pane. In the prior tasks you managed mailbox and group recipients; in this task, you will manage resource recipients.

	Under the **Recipients** group, select **Resources**.

2. In the menu bar that appears over the list of resources, select **+ Add a resource**.
	
	‎**Note:** This selection is designed for administrators to set up a meeting location to be used for booking purposes. When scheduling meetings, you will be able to select the room from the Global Address List (GAL).

3. In the **Fill in the basic info** window that appears, ensure **Room** is selected and then enter the following information:

	- Name: **Conference Room 1**

	- Resource email: **Con1**

	- Email address domain: In the domain field to the right of the **Con1** alias, select the drop-down arrow and select **M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider)

	- Capacity: **15**

	- Location: The room is in Building 5, Room 2011, so enter **5/2011**

	- Phone: **425-555-2011**

4. Select **Next** twice. 

5. In the **Booking options** window, select the **Allow scheduling only during working hours** check box. 

6. In the **Booking window (days)** field, change the value from **180** days to **60** days.

	‎**Note:** The standard duration of 180 days can be too long for scheduling out most meetings. As a best practice, organizations should establish a company standard so that events do not over-book locations.

7. In the **Maximum duration (hours)** field, change the value from **24.0** hours to **120** hours (this is five days, or one work week). 

8. Select **Next**, and then select **Create**. Once the **Status** window changes to indicate resource mailbox creation was successful, select **Done**.

9. Select the **Conference Room 1** resource from the list, and in the window that opens, select **Manage delegates**, and then select **Search name or email**.

10. Type **holly** and then select the result for **Holly Dickson**, then type **nestor** and select **Nestor Wilke**.

11. Set the **Select permission types** for both users to **Full access**, and then select **Save**.

12. In the **Delegates updated window**, select **Close**.

13. Close the **Conference Room 1** window by selecting the **X** in the upper right-hand corner.

14. Leave your browser and all the tabs open for the next task.

### Task 4 – Manage Contacts

One of the key features of Exchange Online is the ability to maintain different types of contacts in the Exchange Admin Center. In this task, you will be introduced to mail contacts and mail users.

1. You should still be in LON-CL1 and your browser should still be open to the **Exchange admin center** from the prior task. Under the **Recipients** group, select **Contacts**.

2. In the menu bar that appears over the list of contacts, select **+ Add a contact**, and in the window that appears, select **Mail contact**.

	‎**Note:** This option enables external people from outside your organization to be added to your Exchange Online distribution lists.

3. Enter the following information.

	- First name: **Bao**

	- Last Name: **Chu**

	- Display Name: tab into the field and **Bao Chu** is automatically displayed

	- Email: **Hai@fabrikam.com**

4. Select **Add** and then select **Close** once the changes are successfully saved. Bao should now appear in the list of contacts as a **MailContact**.

5. In the menu bar that appears over the list of contacts, select **+ Add a contact**, and in the window that appears, select **Mail user**.

	**Note:** This option is for individuals who need to use the company domain even though they are not a full-time employee (for example: contractors, advisors, and selective temporary staff). This option will forward email to the individual’s external email when mail is sent to the contact’s internal company account.
	
	‎**WARNING**: A Mail User does not need a license to access SharePoint Online; the user simply needs to be given access to it.   
	
6. Enter the following information:

	- First name: **Albert**

	- Last Name: **Eksteen**

	- Display Name: tab into the field and **Albert Eksteen** is automatically displayed

	- Email: **Albert@fabrikam.com**

	- Alias: **Albert**

	- User ID: **v-Albert** (this is the user’s alias for his internal Adatum account)

	- User ID domain: in the domain field to the right of the User ID, select the drop-down arrow and select **M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider)

	- Password: **Pa55w.rd**

	- Confirm: **Pa55w.rd**

7. Select **Add** and then select **Close** once the changes are successfully saved. Albert should now appear in the list of contacts as a **MailUser**.

8. In your Edge browser session, leave all the tabs open, including the Exchange admin center; these will be used in the next lab exercise.

# Proceed to Lab 6 - Exercise 2
