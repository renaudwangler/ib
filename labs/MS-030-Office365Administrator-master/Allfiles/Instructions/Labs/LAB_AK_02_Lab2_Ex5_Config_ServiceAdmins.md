# Module 2 - Lab 2 - Exercise 5 - Configuring service administrators

In this exercise, you will continue in your role as Holly Dickson, Adatum's Enterprise Administrator. As part of Adatum's Microsoft 365 pilot project, you will manage administration delegation by assigning Microsoft 365 administrator roles to several of your users. You will assign these roles using both the Microsoft 365 admin center and Windows PowerShell; this will give you experience using PowerShell to perform these administrative functions. Once you have assigned Microsoft 365 admin roles to several of the existing user accounts, you will then test those assignments by verifying the users have the permissions to act in accordance with their roles. 

### Task 1 - Assign Delegated Administrators in the Microsoft 365 Admin Center

As Holly Dickson, Adatum’s Enterprise Administrator (and Microsoft 365 Global Admin), you will use the Microsoft 365 Admin Center to assign administrator rights to several users. 

1. If you’re not logged into the Client 1 VM (LON-CL1) as **ADATUM\Administrator** and password **Pa55w.rd**, then please do so now.

2. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Users** and then **Active Users**. 

3. In the **Active users** list, select **Diego Siciliani**. 

4. In Diego Siciliani’s properties window, the **Account** tab is displayed by default. Scroll down to the **Roles** section and select **Manage roles**. 

5. In the **Manage roles** window, the **User (no admin center access)** option is currently selected be default. Now that you want to assign Diego an administrator role, select the **Admin center access** option. This enables the admin roles for selection. 

6. Diego has been promoted to Billing administrator, but since the Billing admin role does not appear in the list of commonly used roles, scroll down and select **Show all by category**. 

7. In the list of roles that appear by category, scroll down to the **Other** category, select **Billing admin**, and then select **Save changes**. 

8. On the **Manage admin roles** window, select the **X** in the upper-right corner of the screen to close it. This returns you to the **Active users** list. 

9. Repeat steps 3-8 for **Lynne Robbins.** Assign Lynne to the **User Administrator** role (the role is in the list of commonly used admin roles that appear under the **Admin center access** option; you do not have to select **Show all by category**). 

10. Remain logged into the Microsoft 365 admin center as Holly Dickson.


### Task 2 - Assign Delegated Administrators with Windows PowerShell  

This task is similar to the prior one in that you will assign administrator rights to users; however, in this case, you will use Windows PowerShell to perform this function rather than the Office 365 Admin Center. This will give you experience performing this management function in PowerShell, since some administrators prefer performing maintenance such as this using PowerShell. In addition, PowerShell enables you to display all the users assigned to a specific role, which can be very important when auditing your Office 365 deployment. In this task, you will learn how to use PowerShell to display all the users assigned to a specific role. 

1. You should still be logged into **LON-CL1** from the prior task. Navigate to the Windows PowerShell window that you left open from the previous lab. If you closed the PowerShell window, then open an elevated instance of it using the same instruction as before. 

2. You should begin by running the following command that connects your PowerShell session to the Microsoft Online Service:  <br/>

		Connect-MsolService
	
3. In the **Sign in** dialog box that appears, log in as **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider) with password **Pa55w.rd**. 

4. The "official" name of all roles within Microsoft 365 includes the complete spelling of the word "administrator"; whereas, in the Office 365 admin center, "administrator" is abbreviated to "admin" for a number of roles simply for display purposes. When using PowerShell to perform role-related commands in the following steps, you must spell out the entire word "administrator". If you enter "admin" instead of "administrator", the command will return an error indicating that it cannot find the role.

	To view all the available roles in Microsoft 365, enter the following command in the Windows PowerShell window and then press Enter:
	
		Get-MsolRole |Select-Object -Property Name,Description |Out-GridView

5. Holly now wants to assign **Patti Fernandez** to the **Service support admin** role. In the Windows PowerShell window, at the command prompt, type the following command, and then press Enter:

		Add-MsolRoleMember -RoleName "Service support administrator” –RoleMemberEmailAddress PattiF@M365xZZZZZZ.onmicrosoft.com
	(where ZZZZZZ is your unique tenant ID provided by your lab hosting provider)

6. You now want to verify which users have been assigned to certain roles. Displaying the users assigned to a role is a two-step process in PowerShell.

	‎**Important:** Do NOT perform the following commands just yet – this is an informational step whose purpose is to describe what you will be doing in the remaining steps in this task.
	
	- You will begin by running a command that creates a variable ($role) that states that anytime $role is used in a cmdlet, it should retrieve all users assigned to whichever role name you are validating.
		
			$role = Get-MsolRole -RoleName "enter name of role here"
	- After creating the variable in the prior step, you will then run the following command that directs PowerShell to display all object IDs for the users who have been assigned to the name of the role that you invoked in the previous $role variable.
	
			Get-MsolRoleMember -RoleObjectId $role.ObjectId
			
7. You should now run the following two commands as described in the previous step to verify that Patti Fernandez was assigned the Service support administrator role:

		$role = Get-MsolRole -RoleName "Service support administrator"

		Get-MsolRoleMember -RoleObjectId $role.ObjectId
	
8. Verify that **Patti Fernandez** is in the list of users who have been assigned the **Service support administrator** role. 

9. You should now run the following two commands to verify which Adatum users have been assigned to the **Billing Administrator** role.

		$role = Get-MsolRole -RoleName "Billing Administrator"

		Get-MsolRoleMember -RoleObjectId $role.ObjectId

10. Verify that **Diego Siciliani** is in the list of users who have been assigned the **Billing Administrator** role (you assigned Diego to this role in the prior task using the Microsoft 365 admin center). 
	
11. Leave your Windows PowerShell session open for future lab exercises; simply minimize it before going on to the next task.


### Task 3 - Verify Delegated Administration  

In this task, you will begin by examining the administrative properties of two users, Allan Deyoung and Lynne Robbins. You will then log into the Office 365 home page on the Client 1 VM (LON-CL1) as each user to confirm several of the changes that you made when managing their administrative delegation in the prior tasks. Finally, as Lynne Robbins, Adatum's newly assigned User Administrator, you will perform several user account maintenance tasks, such as resetting passwords and blocking a user account.

**Password Note:** When logging into Microsoft 365 as any of the existing user accounts that were created for you in the Microsoft 365 tenant (for example, Allan Deyoung, Lynne Robbins, and so on), you must use the same Tenant Password that you used in Lab 1 when you signed in using the tenant email account (admin@M365xZZZZZZ.onmicrosoft.com) to set up your organization profile. All the existing Microsoft 365 user accounts in your tenant have been assigned this same Tenant Password, which your instructor will provide for you.

1. In LON-CL1, you should still be logged into the Microsoft 365 admin center as Holly Dickson. If not, then do so now.

2. In the **Microsoft 365 admin center**, if you are not displaying the **Active users**, then navigate to there now.  

3. In the **Active users** list, select **Allan Deyoung**. 

4. In the **Allan Deyoung** properties window, the **Account** tab is displayed by default. Under the **Roles** section, it should indicate that Allan has **No administrator access**. Select the **X** in the upper right corner to close Allan's properties window.

5. In the **Active users** list, select **Lynne Robbins**. 

6. In the **Lynne Robbins** properties window, it should indicate that Lynne has been assigned the **User Administrator** role. Close Lynne's properties window.

7. In your **Edge** browser, open a new **InPrivate** window, and navigate to **https://portal.office.com**.

8. You will begin by signing into Office 365 as **Allan Deyoung**. In the **Sign-in** window, enter **AllanD@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider). In the **Enter password** window, enter the Tenant Password provided by your lab hosting provider.  

9. On the **Stay signed in?** window, select **Yes**.

10. If a **Get your work done with Office 365** window appears, select the **X** to close it.

11. In the **Microsoft Office Home** page, if an **Office 365 apps** box appears below the **Install Office** button, select **Got it!** to close the box. Note how the **Admin** option is not available.

	You have just verified that Allan cannot access the Microsoft 365 admin center since he was never assigned an administrator role.

12. In **Microsoft Edge**, at the top right of the **Microsoft Office Home**, select the user icon for **Allan Deyoung** (the circle in the upper right-hand corner with Allan's picture in it), and in his **My account** pane, select **Sign out.** 

13. You will now sign into Office 365 as **Lynne Robbins**. In your current **Edge** browser tab, it should display a message indicating **Allan, you're signed out now**. In this window, it gives you the option of signing back in as Allan, or signing in as a different user. Select **Switch to a different account**, and in the **Email address** field that appears, enter **LynneR@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider) and then select **Sign in**. In the **Enter password** window, enter the Tenant Password provided by your lab hosting provider.

14. Select **Yes** on the **Stay signed in?** window.

15. In the **Microsoft Office Home** page, if an **Office 365 apps** box appears below the **Install Office** button, select **Got it!** to close the box. Since Lynne has been assigned to an administrator role, note how **Admin** appears in the **Microsoft Office Home** page. Select the **Admin** option.

16. On the **Microsoft 365 admin center**, select **Users** on the left-hand navigation pane and then select **Active users**.

17. As the **User admin**, Lynne has permission to change user passwords. Lynne was recently contacted by **Diego Siciliani** and **Allan Deyoung**, each of whom reported that their passwords may have been compromised. Per Adatum's company policy, Lynne must reset their passwords to a temporary value, and then force them to reset their password at their next login.

	‎In the **Active users** list, as you move your mouse from one user account to another, notice the **key (Reset a password)** icon that appears to the right of each user's name. Select the key icon that appears to the right of **Diego Siciliani's** name.

18. In the **Reset password** window for Diego, unselect the **Automatically create a password** option, and then enter **P@$$w0rd** in the **Password** field. If necessary, select the **Require this user to change their password when they first sign in** check box so that it displays a check mark.

19. Select **Reset password**.

20. You should receive an error message indicating that you cannot reset Diego’s password because he has been assigned an admin role. In Diego’s case, he was assigned to the Billing Admin role. Since only Global Admins can change another admin’s password, Lynne will need to ask Holly Dickson to make this change. Select **Close**. 

21. If a survey request window appears, close it by selecting the **X**.

22. In the **Active users** list, select the **key (Reset a password)** icon for **Allan Deyoung**.

23. In the **Reset password** window for Allan, if necessary, unselect the **Automatically create a password** option, and then enter **P@$$w0rd** in the **Password** field. If necessary, select the **Require this user to change their password when they first sign in** check box so that it displays a check mark.

24. Select **Reset password**.

25. On the **Reset password** window, you should receive a message indicating the password was successfully reset. Select the **Email the sign-in info to me** check box. This displays a **Your email** field, which displays Lynne Robbins' email address. Since you also want to email this temporary password to Allan, you should enter Allan's email address after Lynne's alland. Then select **Send email and close**.

	If you enter multiple email addresses, they must be separated by a semicolon and a space, so enter a semicolon and a space following Lynne's email address, enter Allan's email address of **AllanD@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider), and then select **Send email and close**.

26. Management has recently discovered that Alex Wilber's username may have been compromised. As a result, Lynne has been asked to block Alex's account so that no one can sign in with his username until management is able to determine the extent of the issue. In the **Active users** list, select the circle to the left of **Alex Wilber's** name (do NOT select Alex’s name itself). 

	**Note:** If any other user account is selected, you must unselect that user account before proceeding. Check Allan Deyoung's account, since you just reset his password; uncheck his account if necessary. Only Alex's account should be selected. 

27. In the menu bar at the top of the page, select the **ellipsis icon (...)** to display a drop-down menu of additional options. In the menu that appears, select **Edit sign-in status**.

28. In the **Block sign-in** window, select the **Block this user from signing in** check box, and then select **Save changes**.

29. The **Block sign-in** window should display a message indicating that Alex is now blocked from signing in (and no one can sign in with Alex's username in the event that his username was actually compromised). In addition, Alex will automatically be signed out of Microsoft services within 60 minutes. Select the **X** in the upper right-hand corner of the window to close it.

30. Lynne has just been informed that Nestor Wilke's username has also been potentially compromised. Repeat steps 30 through 33 to block Nestor from signing in (and to block anyone else from using his username to sign in). 

31. When you tried to block Nestor's sign in, you should have received an error message indicating **Changes could not be saved**. The reason that you received this error is that Nestor is a Global Admin, and Lynne is not. Only a Global Admin can block another Global Admin from being able to sign in. Lynne will need to ask Holly Dickson to make this change.

32. To verify whether Alex Wilber can sign in after you blocked his account, you will attempt to sign in as Alex. Log out of Microsoft 365 by selecting the user icon for **Lynne Robbins** (the circle with Lynne's picture in the upper right-hand corner), and in her **My account** pane, select **Sign out.** 

33. As a best practice, close all your browser tabs except for the **Sign out** tab once you have been signed out. On the **Sign out** tab, navigate to **https://portal.office.com**. 

34. In the **Pick an account** window, select **Use another account**. In the **Sign in** window, enter **AlexW@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider). In the **Enter password** window, enter the Tenant Password provided by your lab hosting provider.

	The **Pick an account** window should appear, and it should display an error message indicating **Your account has been locked. Contact your support person to unlock it, then try again.**
	
	You have just verified that Alex (or someone who has obtained Alex's username and password) cannot log in.

35. Switch back to your other **Edge** window, where you should still be logged into **Microsoft 365** as Holly Dickson. The **Active users** list should be displayed in the **Microsoft 365 admin center** from earlier in this task. 

36. Upon further investigation, Adatum's CTO has determined that Alex Wilber's account has, in fact, not been compromised; therefore, the CTO has asked Holly to remove the block on Alex's sign in. Repeat steps 30 through 33 to unblock his account. Note how the **Block sign-in** window from step 32 now displays the **Unblock sign-in** window instead.

	In the **Unblock sign-in** window, the **Block this user from signing in** check box is currently selected. Unselect this check box to clear it, select **Save changes**, and once Alex has been unblocked from signing in, close this window.
	
37. On LON-Cl1, Close all instances of **Edge**.

# End of Lab 2 


