# Module 2 - Lab 2 - Exercise 1 - Managing Microsoft 365 users with the Microsoft 365 admin center

Holly Dickson is Adatum’s Enterprise Administrator. Since she doesn’t have a personal Microsoft 365 user account set up for herself, Holly initially signed into Microsoft 365 as the default Microsoft 365 MOD Administrator account. In this task, she will create a Microsoft 365 user account for herself, and she will assign her user account the Microsoft 365 Global Administrator role, which gives her the ability to perform all administrative functions within Microsoft 365.

‎In your role as Holly Dickson, you will then create several additional user accounts in the Microsoft 365 admin center, each of which you will later add to new security groups that you’ll also create. While Enterprise Admins typically do not add user accounts, this is a one-time task that you need to perform to prepare Adatum’s test environment for future lab exercises in this course.

**Important:** As a best practice in your real-world deployments, you should always write down the first global admin account’s credentials (in this lab, the MOD Administrator) and store it away for security reasons. This account is a non-personalized identity that owns the highest privileges possible in a tenant. It is **not** MFA activated (because it is not personalized) and the password for this account is typically shared among several users. Therefore, this first global admin is a perfect target for attacks, so it’s always recommended to create personalized service admins and keep as few global admins as possible. For those global admins that you do create, they should each be mapped to a single identity (just as you're doing in this task for Holly), and they should each have MFA enforced. For the purpose of this lab environment, you will turn on MFA for Holly in the next lab exercise, which focuses on setting password policies. 


### Task 1 - Create Microsoft 365 users

In this task, you will take on the persona of Holly Dickson, Adatum's Microsoft 365 Enterprise Administrator. Now that she has provisioned Adatum's Microsoft 365 tenant in the prior lab, Holly is ready to begin adding user accounts for her pilot project. She will begin by adding a personalized account for herself, and then she will add user accounts for additional users who will be part of the pilot. 

1. You should still be logged into the **LON-CL1** VM as the **Administrator** from the prior lab. The **Microsoft 365 admin center** should still be open in the Edge browser, and you should be signed into Microsoft 365 as the **MOD Administrator**. 

2. In the **Microsoft 365 admin center**, in the left-hand navigation pane, expand **Users** and then select **Active users**. <br>

	In the **Active users** list, you will see the list of existing user accounts that were created for Adatum by your lab hosting provider. Since you’re taking on the role of Holly Dickson in this lab scenario, you will create a user account for yourself, and you will assign yourself the Microsoft 365 role of Global Administrator, which gives Holly global access to all management features and data across Microsoft online services.

3. In the **Active Users** window, select **Add a user**.

4. In the **Set up the basics** window, enter the following information:

	- First name: **Holly**

	- Last name: **Dickson** 

	- Display name: When you tab into this field, **Holly Dickson** will appear.

	- Username: **Holly** <br/>
	
		‎**IMPORTANT:** To the right of the **Username** field is the domain field. It will be prefilled with whatever domain is identified as the **Default domain** for the organization. For Adatum, this will be the **xxxUPNxxx.xxxCustomDomainxxx.xx** domain that was created for this MS-030 lab environment by your lab hosting provider and which you finished provisioning in Lab 1. <br>

		However, for the purposes of future lab exercises concerining directory synchronization, you should set the domain for each new user that you create in this task to the original **M365xZZZZZZ.onmicrosoft.com** cloud domain (where ZZZZZZ is your tenant ID provided by your lab hosting provider). <br>

		Therefore, you must select the drop-down arrow in this domain field and select **M365xZZZZZZ.onmicrosoft.com**.  <br/>
	
		After configuring this field, Holly’s username should appear as:<br/>

		**Holly@M365xZZZZZZ.onmicrosoft.com**  
	
	- Password settings: uncheck **Automatically create a password** option

	- Password: **Pa55w.rd** 

	- Uncheck the **Require this user to change their password when they first sign in** checkbox 

5. Select **Next**.

6. In the **Assign product licenses** window, enter the following information:

	- Select location: **United States**

	- Licenses: Verify the **Assign user a product license** option is selected and then select the **Enterprise Mobility + Security E5** check box **and** the **Office 365 E5** check box 

7. Select **Next.**

8. In the **Optional settings** window, select the drop-down arrow to the right of **Roles (User: no administration access).** 

9. In the **Roles** information that appears, select the **Admin center access** option. This displays a list of the most commonly assigned administrator roles. 


	**Note** If the role you are assigning is not in this list, then you can select the **Show all by category** drop-down arrow to display all the available roles (sorted by category). However, in this case, Holly wants to assign herself the Global Administrator role. She can do this since she is logged in as the MOD Administrator, which is also a Global admin. Only a Global admin can assign another user the Global Administrator role. <br>

10. Select **Global Administrator** and then select **Next**.

11. On the **Review and finish** window, review your selections. If anything needs to be changed, select the appropriate **Edit** link and make the necessary changes. Otherwise, if everything is correct, select **Finish adding**. 

12. On the **Holly Dickson added to active users** page, as a final verification, select **Show** that appears next to the **Password** to verify you entered **Pa55w.rd** correctly. Select **Close**. 

13. Repeat steps 3-12 to add the following users and data: <br/>

	**Username domain:** When you enter the **Username** for each of these users, make sure that you select the **M365xZZZZZZ.onmicrosoft.com** domain in the domain field, just as you did when you created Holly's username.  <br>

	**Password:** Assign each user the **Pa55w.rd** password, and just like with Holly's account, do NOT require they change the password at their first login. <br>

	**Licenses:** Assign **Alan Yoo** the **Office 365 E5** license. For all other users, select the **Create user without product license (not recommended)** option. <br> 

	**Roles:** By default, a user is assigned the **User role (no administration access)**; this will be sufficient for these users for now. In Lab 2, Exercise 5, you will assign roles to the users. So when you reach the **Optional settings** window, select **Next** to bypass assigning a role. <br>

	- **Alan Yoo** with username **Alan**; assign an **Office 365 E5** license but no role  

	- **Ada Russell** with username **Ada**; do not assign a license or role

	- **Adam Hobbs** with username **Adam**; do not assign a license or role

	- **Libby Hayward** with username **Libby**; do not assign a license or role

    - **Laura Atkins** with username **Laura**; do not assign a license or role 

14. Review the list of **Active users**. Verify that each user you added has **M365xZZZZZZ.onmicrosoft.com** as the domain portion of their username. <br>

	If any of the users has **xxxUPNxxx.xxxCustomDomainxxx.xx** as the domain portion of their username, select the user's **Display name** (so that the check mark appears to the left of the **Display name**), select the **ellipsis** icon on the menu bar above the list of users, and in the drop-down menu, select **Edit username**. Then in the **Manage username** window, select the **M365xZZZZZZ.onmicrosoft.com** domain and then select **Save changes**. 

15. Remain logged into LON-CL1 with the Microsoft 365 admin center open in your browser for the next task.


### Task 2 - Edit Microsoft 365 users

In this task, you will perform a number of the more common editing features applied towards user accounts. You will begin by updating Alan Yoo's contact information, and then you will block him from being able to sign in. 

Blocking a user from signing in is a best practice when you feel the user's password or username have been compromised. This prevents the user from signing in and it automatically signs them out from all Microsoft services within 60 minutes. 

You will then assign a product license to Ada Russell's account. Finally, you will delete Libby Hayward's account, and then you will restore it.

1. You should still be logged into the **LON-CL1** VM as the **Administrator** from the prior task. The **Microsoft 365 admin center** should still be open in the Edge browser, and you should be signed into Microsoft 365 as the **MOD Administrator**. 

2. In the **Microsoft 365 admin center** tab, the **Active users** list should still be displayed from the prior task. Select the row for **Alan Yoo** so that the check mark appears in the circle to the left of his name. **Note** The easiest way to do this is to hover your mouse pointer to the left of the name.

3. In the menu bar above the list of users, select the **ellipsis** icon (**More actions**). In the drop-down menu that appears, select **Manage contact information**.

4. In the **Manage contact information** pane that appears for Alan Yoo, enter **Accounts Receivable** in the **Department** field and then select **Save changes**. This will save the information and display a **Contact information updated** message at the top of the pane. Select the X in the upper right corner to close the **Manage contact information** pane.

5. Alan Yoo's account should still be selected in the **Active Users** list. In the menu bar above the list of users, select the **ellipsis** icon again, and this time select **Edit sign-in status** in the drop-down menu.

6. In the **Block sign-in** pane, select the **Block this user from signing in** check box and then select **Save changes**. Note the message that appears at the top of the pane indicating that Alan is now blocked from signing in, and that he will automatically be signed out of all Microsoft services within 60 minutes. Select the X in the upper right corner to close the **Block sign-in** pane.

7. In the **Active users** list, clear the check mark to the left of **Alan Yoo** to unselect his account, and then select **Ada Russell**.

8. For Ada, you want to learn how to assign a new license to an existing user. In the menu bar above the list of users, select **Manage product licenses**.

9. In the **Ada Russell** pane, the **Licenses and apps** tab is displayed by default (since you selected the **Manage product licenses** option). Under the list of licenses, select the **Office 365 E5** license and then select **Save changes**. Select the X in the upper right corner to close the **Ada Russell** pane.

10. In the **Active users** list, note that **Ada Russell** is now assigned an Office 365 E5 license. Select **Ada Russell** to unselect her account, and then select **Libby Hayward**.

11. To the right of Libby Hayward's **Display Name**, select the vertical ellipsis icon. In the drop-down menu that appears, note the options that are available are similar to the options from the ellipsis icon that you select in the menu bar for Alan and Ada, although there are less options to choose from. However, this menu has less choices. 

12. In this task, you are going to practice deleting Libby's account and then restore it. You can delete a user by selecting the **Delete user** option on the menu bar, or this option from the vertical ellipsis icon. Since you have selected the vertical ellipsis icon, select **Delete user** from the drop-down menu.

13. On the **Delete this user?** pane, select the **Delete user** button that appears at the bottom of the pane.

14. On the **Libby Hayward has been deleted** pane, select the **Close** button.

15. Verify that **Libby Hayward** no longer appears in the list of **Active users**.  

16. Now verify that Libby appears in the list of deleted users. In the **Microsoft 365 admin center**, in the left-hand navigation pane under **Users**, select **Deleted users**.

17. In the **Deleted users** page, verify that **Libby Hayward** appears in the list of deleted users.

18. Deleting a user performs a soft-delete on the account; this allows organizations to restore deleted users for up to 30 days following their deletion. You should now restore Libby's account to an active user. In the **Deleted users** list, select **Libby Hayward**. 

19. On the menu bar, select **Restore user**.

20. In the **Restore Libby Hayward** pane, you have the option of assigning Libby a new password yourself or auto-generating a new password. **A good practice is to auto generate the password and then make the restored user change their password upon first sign in.**

	Since the **Auto-generate password** option is selected by default as well as the **Make this user change their password when they first sign in** option, simply select the **Restore** button at the bottom of the pane. 

21. In the **Libby Hayward has been restored** window, it confirms that Libby's account has been restored and that her password has been reset. You also have the option to send the password to Libby in an email. <br>

	Select the **Send password in email** check box, and then in the **Email the new password to the following recipients** field, it displays the MOD Administrator's email. After this email address, enter a semicolon followed by Libby's email of **libby@M365xZZZZZZ.onmicrosoft.com** (replace ZZZZZZ with the tenant ID). When you have finished entering Libby's email, select the **Send email and close** button. 

22. Libby's account should no longer appear in the **Deleted users** list. In the **Microsoft 365 admin center**, in the left navigation pane, select **Active users**.

23. Verify that **Libby Hayward** appears in the list.

24. Leave the Edge browser session open as well as all the open browser tabs. 


### Task 3 - Verifying user settings

In this task, you will verify several of the changes you made to user accounts in the prior task. You will sign into Microsoft 365 as Libby Hayward, which will require that you enter the new temporary password assigned to her account. You will then attempt to sign into Microsoft 365 as Alan Yoo, and you will validate whether his blocked account can sign in. 

1. You should still be logged into the **LON-CL1** VM as the **Administrator** from the prior task. The **Microsoft 365 admin center** should still be open in the Edge browser, and you should be signed into Microsoft 365 as the **MOD Administrator**. 

2. You must now retrieve the temporary password that was assigned to Libby Hayward's account when you restored her account in the prior task. At the time you restored her account, you selected the option to send an email to Libby's mailbox as well as the MOD Administrator's mailbox that contained the temporary password. <br>

	In this task, you will sign into the MOD Administrator's Outlook mailbox and retrieve the temporary password. You will then switch to a new client machine and attempt to log into Microsoft 365 as Libby using the new password. Since you also selected the option that forces Libby to create a new password at her first log in, you will have to change the password at that time. <br>

	In your web browser, select the **Microsoft Office Home** tab. In the **Microsoft Office Home** page, select the **Outlook** icon. This will open Outlook for the MOD Administrator's mailbox. 

3. If the **Welcome** window appears for Outlook, select the X in the upper right-hand corner to close it. 

4. In the MOD Administrator's **Inbox** in Outlook, select the email message in which the **From** account is **Microsoft on behalf of your organization** and the Subject line is **Account information for new or modified users**. <br>

	This email should display the temporary password that was assigned to Libby Hayward's account at the time her deleted account was restored. Write down the temporary password.

5. You must now log out of Microsoft 365 as the MOD Administrator and log back in as Libby Hayward. To log out of the MOD Administrator account, select the circle in the upper right portion of the Edge browser that contains the **MA** initials. In the drop-down menu that appears, select **Sign out**.

6. Once the dialog box appears indicating your are signed out of your account, it is a best practice to close all other tabs the MOD Administrator had open. This eliminates the chance that you will select a tab for the old account (MOD Administrator) when you sign in as a new account (Libby Hayward). <br>

	Therefore, close the **Microsoft Office Home** tab, the **Microsoft 365 admin center** tab, and any other tab that is open. Only the **Sign out** tab should remain open.

7. In the **Sign out** tab, enter the following URL in the address bar: **https://portal.office.com**

8. In the **Pick an account** dialog box, select **Use another account**.

9. In the **Sign in** window, enter **Libby@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ should be replace with your tenant ID). Select **Next**.

10. In the **Enter password** window, enter the temporary password that was assigned to Libby's restored user account and then select **Sign in**.

11. In the **Update your password** dialog box, enter Libby's temporary password in the **Current password** field, and then enter **Pa55w.rd** in the **New password** and **Confirm password** fields. Select **Sign in**.

12. If you receive an error message indicating the new password has been entered too many times before, enter **Ynot-Knirf@0827** in the **New password** and **Confirm password** fields and then select **Sign in**. 

13. Verify that you can access the Office 365 Home page. Note that no Office 365 applications appear on the home page; this is because Libby was never assigned a Microsoft 365 license.

14. You must now log out of Microsoft 365 as Libby Hayward and then log in as Alan Yoo. To log out of the Libby Hayward account, select the circle in the upper right portion of the Edge browser that contains the **LH** initials. In the drop-down menu that appears, select **Sign out**. 

15. Once you are signed out, enter the following URL in the address bar: **https://portal.office.com**

16. In the **Pick an account** dialog box, select **Use another account**.

17. In the **Sign in** window, enter **Alan@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ should be replace with your tenant ID). Select **Next**.

18. In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in**.

19. In the **Pick an account** dialog box, note the error message that indicates Alan's account has been locked. You have verified that Alan cannot log into Microsoft 365.

20. You will now log back into Microsoft 365 as Holly Dickson using the personal account that she previously set up for herself. In the **Pick an account** dialog box, select **Use another account**.

21. In the **Sign in** window, enter **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ should be replace with your tenant ID). Select **Next**.

22. In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in**.

23. If a **Get your work done with Office 365** dialog box appears, select the X in the upper right corner to close it. 

24. In the **Office 365 Home** page, select **Admin**.

25. In the **Microsoft 365 admin center**, in the left-hand navigation pane, expand **Users** and then select **Active users**.

26. In the **Active users** list, select **Alan Yoo**.

27. In the menu bar that appears above the list of users, select the **ellipsis** (**More actions**) icon, and then in the drop-down menu that appears, select **Edit sign-in status**.

28. On the **Unblock sign-in** pane, the **Block this user from signing in** check box is selected. Unselect this check box and then select **Save changes**.

29. Once a message appears at the top of the pane indicating that Alan Yoo is now unblocked from signing in, select the X in the upper right corner of the **Unblock sign in** pane to close it.
	Note the message that it may take up to 15 minutes before Alan can sign in again.

30. Remain signed into Microsoft 365 on LON-CL1 as Holly Dickson, and leave your browser and all tabs open for the next lab exercise.   
 


**Results**: After completing this exercise, you should have created and managed user accounts and licenses according to Adatum's business needs.


# Proceed to Lab 2 - Exercise 2
