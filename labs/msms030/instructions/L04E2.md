# Module 4 - Lab 4 - Exercise 2 - Perform Directory Synchronization 

In this exercise, you will enable synchronization between Adatum’s on-premises Active Directory and Azure Active Directory. Azure AD Connect will then continue to synchronize any delta changes every 30 minutes. You will then make some group updates and then manually force an immediate synchronization rather than waiting for Azure AD Connect to automatically synchronize the updates. You will then verify whether the updates were synchronized.  

‎**Important:** When you start this exercise, you should perform the first three tasks without any delay between them so that Azure AD Connect does not automatically synchronize the changes that you make to the identity objects.

### Task 1 - Install Azure AD Connect and Initiate Synchronization

In this task, you will run the Azure AD Connect setup wizard to enable synchronization between Adatum’s on-premises Active Directory and Azure Active Directory. Once the configuration is complete, the synchronization process will automatically start. 

‎1. You should still be logged into **LON-DC1** as the **Administrator** from the prior task. 

2. In the **Installation - Microsoft - IdFix** tab in **Edge**, navigate to: **https://admin.microsoft.com**.

3. In the **Sign in** dialog box, copy and paste in (or enter) the username of **Holly Dickson** (**holly@M365xZZZZZZ.onmicrosoft.com**, where ZZZZZZ is your unique tenant suffix ID provided by your lab hosting provider) and then select **Next**.

4. In the **Enter password** dialog box, enter **Pa55w.rd** and then select **Sign in**.

5. On the **Stay signed in?** dialog box, select the **Don’t show this again** check box and then select **Yes.**

6. In the left-hand navigation pane, select **Users**, and then select **Active Users**.

7. In the **Active users** window, on the menu bar, select the **ellipsis** icon (on the right-hand side), and then in the drop-down menu, select **Directory synchronization**. 

8. In the **Azure Active Directory preparation** window, select **Go to the Download center to get the Azure AD Connect tool**. This opens a new tab in your browser and takes you to the Microsoft Download Center.

9. In the **Microsoft Download Center**, scroll down to the **Microsoft Azure Active Directory Connect** section and select **Download**. 

10. In the notification bar in the upper right-hand corner of the screen, once the **AzureADConnect.msi** file has finished downloading, select **Open file**.

11. In the **Do you want to run this file?** dialog box, select **Run**.

12. This initiates the installation of the Microsoft Azure Active Directory Connect Tool. If the **Welcome to Azure AD Connect** window does not appear on the desktop, find the icon for it on the taskbar (it will be the final icon on the right) and select it. 

	On the **Welcome to Azure AD Connect** window in the setup wizard, select the **I agree to the license terms and privacy notice** check box and then select **Continue**.

13. On the **Express Settings** page, read the instruction regarding a single Windows Server AD forest and then select **Use express settings**.

14. On the **Connect to Azure AD** window, enter **Holly@M365xZZZZZZ.onmicrosoft.com** (where zzzzzz is the tenant ID provided by your lab hosting provider) in the **USERNAME** field, enter **Pa55w.rd** in the **PASSWORD** field, and then select **Next** (you may have to select **Next** twice; once to enable it and again to proceed). 

15. On the **Connect to AD DS** page, enter **ADATUM\Administrator** in the **USERNAME** field, enter **Pa55w.rd** in the **PASSWORD** field, and then select **Next** (you may have to select **Next** twice; once to enable it and again to proceed). 

16. In the **Azure AD sign-in configuration** window, select the **Continue without matching all UPN suffixes to verified domains** check box at the bottom of the page, and then select **Next**.

17. On the **Ready to configure** screen, select the check box for **Start the synchronization process when configuration completes** if it’s not already selected, and then select **Install**.

18. Wait for the configuration to complete (This may take a few minutes) and then select **Exit**.

19. Select the **Windows (Start)** icon in the lower left corner of the taskbar. In the **Start** menu that appears, select **Azure AD Connect** to expand the group, and then select **Synchronization Service** to start this desktop application. 

	**Note:** If you selected **Azure AD Connect** in the **Start** menu and it expanded and you were able to select **Synchronization Service**, then proceed to the next step. However, if **Azure AD Connect** did not expand when you selected it in the **Start** menu, then you will need to close all applications and then log out of LON-DC1. The remaining instruction in this step is what to do if you needed to log out of LON-DC1. 

	Once you have logged off, follow the instructions from your lab hosting provider to select **Ctrl+Alt+Delete**. This will display the log on screen for LON-DC1.

	Log in as **Adatum\Administrator** with a password of **Pa55w.rd**. Minimize **Server Manager** after it opens, and then open **Edge** and navigate to **htps://admin.microsoft.com**. Log in as **Holly@M365xZZZZZZ.onmicrosoft.com** with a Password of **Pa55w.rd**.

	Then select the **Windows (Start)** icon in the lower left corner of the taskbar. In the **Start** menu that appears, select **Azure AD Connect** to expand the group (this time it should expand), and then select **Synchronization Service**.  

20. In the **Synchronization Service Manager** window, the **Operations** tab at the top of the screen is displayed by default so that you can monitor the synchronization process. 

21. Wait for the **Export** profile to complete for **M365xZZZZZZ.onmicrosoft.com**; when it finishes, its **Status** should be **completed-export-errors**. Once it's complete and you see this status, select this row.  

22. In the bottom portion of the screen, a detail pane appears showing the detailed information for this operation. 

	- In the **Export Statistics** section, note the number of users that were added and the number that were updated. 
	- In the **Export Errors** section, note the errors that appear. If you recall back in the prior lab exercise when you ran the IdFix tool, there were two users with validation errors that you purposely did not fix (**Ngoc Bich Tran** and **An Dung Dao**). Select the links under the **Export Errors** column with the **Data Validation Failed** and you will see that these are the two users that were not synchronized by the Azure AD Connect tool due to these data validation errors.   

	‎**Note:** Because a synchronization had not been performed prior to this, the initial synchronization was a **Full Synchronization** (see the **Profile Name** column). Because the synchronization process will continue to run automatically every 30 minutes, any subsequent synchronizations will display **Delta Synchronization** as its **Profile Name**. If you leave the **Synchronization Service Manager** window open, after 30 minutes you will see that it attempts to synchronize the two users who were not synchronized during the initial synchronization. These will display as a **Delta Synchronization**.

23. Now that you have seen Azure AD Connect complete a Full Synchronization, in the next task you will make some updates and manually force an immediate synchronization rather than waiting for it to synchronize updates every 30 minutes. Close the **Synchronization Service Manager**. 

24. In your browser, close all tabs except for the **Microsoft 365 admin center** tab. 

25. Leave LON-DC1 open as it will be used in the next exercise.



### Task 2 - Create Group Accounts to Test Synchronization  

To test the manual, forced synchronization process, you will also set up several group scenarios to verify whether the forced synchronization function is working in Azure AD Connect. You will create a new security group, and you will update the group members in an existing, built-in security group, all within Adatum’s on-premises environment. 

Each group will be assigned several members. After the forced synchronization, you will validate that you can see the new security group in Microsoft 365 and that its members were synced up from the on-premises group to the cloud group. You will also validate that you can NOT see the built-in security group in Microsoft 365, even though you added members to it in Adatum's on-premises environment. Built-in groups are predefined security groups that are located under the Builtin container in Active Directory Users and Computers. They are created automatically when you create an Active Directory domain, and you can use these groups to control access to shared resources and delegate specific domain-wide administrative roles. However, they are not synchronized to Microsoft 365, even after adding members to them within their on-premises AD group. You will validate this functionality in this task.

1. You should still be logged into **LON-DC1** as the **Administrator** from the prior task. 

2. If **Server Manager** is closed, then re-open it now; otherwise, select the **Server Manager** icon on the taskbar. 

3. In **Server Manager**, select **Tools** at the top right side of the screen, and then in the drop-down menu select **Active Directory Users and Computers.**

4. You will begin by adding members to one of the built-in security groups. In the **Active Directory Users and Computers** console tree, under **Adatum.com**, select the **Builtin** folder. This will display all the built-in security group folders that were automatically created at the time the **Adatum.com** domain was created.

5. In the detail pane on the right, double-click the **Print Operators** security group.

6. In the **Print Operators Properties** window, select the **Members** tab and then select the **Add** button.

7. In the **Select Users, Contacts, Computers, Service Accounts, or Groups** window, in the **Enter the object names to select** field, type the following names (type all three at once with a semi-colon separating them), and then select **Check Names**:  

	- **Ashlee Pickett** 

	- **Juanita Cook** 

	- **Morgan Brooks**  

8. Select **OK** to return to the **Print Operators Properties** window.

9. In the **Print Operators Properties** window, select **OK** to return to the **Active Directory Users and Computers** window.

10. You will now create a new security group. In the console tree under **Adatum.com**, right-click on the **Research** OU, select **New,** and then select **Group**.  

11. In the **New Object - Group** window, enter the following information:

	- Group name: **Manufacturing**

	- Group scope: **Universal**

	- Group type: **Security**

12. Select **OK**.  

13. In the console tree under **Adatum.com**, select the **Research** OU and then double-click on the **Manufacturing** security group that you just added in the **Research** folder.  

14. In the **Manufacturing Properties** window, in the **E-mail** box, type **Manufacturing@adatum.com**.  

15. Select the **Members** tab, and then repeat steps 6-9 to add the following members to this group:  

	- **Bernardo Rutter**

	- **Charlie Miller**

	- **Dawn Williamson**  

16. Leave the **Active Directory Users and Computers** window open for the next task.  

 
### Task 3 - Change Group Membership to Test Synchronization  

This task sets up another scenario for testing whether the sync process is working in Azure AD Connect. In this task you will change the members of a group to see if they are reflected in the cloud once the group is synced. 

1. This task continues from where the previous task left off in LON-DC1. In the **Active Directory Users and Computers** window, in the console tree under **Adatum.com**, the **Research** organizational unit is still selected. 

	In the detail pane on the right, double-click the **Research** security group.  

2. In the **Research Properties** window, select the **Members** tab to view the members of this group.  

3. You want to remove the following users from the group:

	- **Cai Chu**  

	- **Shannon Booth**  

	- **Tia Zecirevic**  
	
	While you can remove each user individually, the quickest way is to remove all three at one time. Select the first user, then hold the **Ctrl** key down while selecting the other two. With all three users selected, select the **Remove** button and then select **Yes** to confirm the removal. Verify the three users have been removed, and then select **OK.**

4. Close the **Active Directory Users and Computers** window.
  
5. Leave LON-DC1 open as you will continue using it in the next task. 

	‎**Important:** You should perform the next task immediately after completing this one so that Azure AD Connect doesn’t automatically synchronize the changes that you just made to the identity objects in the previous tasks.


### Task 4 - Force a manual synchronization   

In this task, you will force a sync between Adatum’s on-premises AD and Azure AD instead of waiting 30 minutes for Azure AD Connect to synchronize the identity objects. You must use PowerShell to perform a forced synchronization.

1. On LON-DC1, if the **Windows PowerShell** application is still open from the prior exercise, then **you MUST close it now**.  

	‎**Important:** The reason for this step is that if Windows PowerShell was opened BEFORE the Azure AD Connect setup, the cmdlet **Start-ADSyncSyncCycle** that is used in step 3 will not be available and you will receive an error indicating that the cmdlet is not recognized when you attempt to run it. Therefore, it’s recommended that at this step, you close Windows PowerShell if it’s open and then restart it.  

2. At this point, Windows PowerShell should NOT be open. To open it, select the **magnifying glass (Search)** icon in the taskbar, type **PowerShell** in the Search box, and then in the menu, right-click on **Windows PowerShell** (not Windows PowerShell ISE) and select **Run as administrator**.  

3. In **Windows PowerShell**, run the following command to manually run a sync cycle between Adatum’s on-premises AD and Azure AD. The **Delta** switch is used here so that only the updates are synchronized.   

		Start-ADSyncSyncCycle -PolicyType Delta
	
	‎**Note:** If for any reason the Domain Controller VM was restarted after the original full synchronization run, the Microsoft Azure AD Sync service may not have restarted. If this occurred, you’ll receive an error when you try to perform the forced sync above. If this occurs, you’ll need to start the Microsoft Azure AD Sync service first and then perform the forced synchronization. 

4. Once the synchronization process has successfully completed, minimize your PowerShell window (do not close it) and proceed to the next task. You will use PowerShell in the next task to validate some of the results of the directory synchronization.

5. Remain in LON-DC1 and proceed to the next task.
  

### Task 5 - Validate the Results of Directory Synchronization   

In this task, you will validate whether the changes you made earlier were synchronized from Adatum’s on-premises AD to Azure AD. You will validate the changes using the Microsoft 365 admin center, and then you’ll perform the same validations using Windows PowerShell. This gives you experience in validating synchronization using both the Microsoft 365 admin center GUI and PowerShell.

1. Switch to the **LON-CL1** client VM. 

2. Log into LON-CL1 as the **Administrator** with the password **Pa55w.rd**.


3. Now let’s examine the synchronization results for the groups that you updated in the previous tasks. In your **Edge** browser, if a tab exists for the **Microsoft 365 admin center**, then proceed to the next step. 


	Otherwise, enter **https://admin.microsoft.com/** in the address bar to open the **Microsoft 365 admin center** page, log in as **holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) with a password of **Pa55w.rd**. 

4. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Groups**, and then select **Active groups**. 

5. In the **Active groups** window, verify that the **Manufacturing** group appears in the list, and that the **Print Operators** group does NOT appear. As mentioned previously, built-in groups such as the **Print Operators** security group are not synced from the on-premises environment to Microsoft 365, even when you add members to the group as you did in the earlier task. 

	**Note:** You may need to wait up to 10 minutes before the **Manufacturing** group appears. Continue to refresh the list until you see the group.  

6.	In the **Active groups** list, locate the **Manufacturing** group. 

	In the **Group email** column, verify the group email address was changed during directory synchronization from **manufacturing@adatum.com** to **manufacturing@M365xZZZZZZ.onmicrosoft.com**, which is the mailbox in Exchange Online. 

	Look further to the right and verify the value in the **Sync status** indicates that it was **Synced from on-premises**. You can do this by holding your mouse over the icon that appears in the **Sync status** column to display to icon name.

7. Select the **Manufacturing** group to open the **Manufacturing** group window. 


8. In the **Manufacturing** group window, note up under the Manufacturing title that it’s a mail-enabled security group that contains three members. Also note the message indicating that you can only manage this group in your on-premises environment using either Active Directory users and groups (i.e. Users and Computers) or the on-premises Exchange admin center. 

	The window currently displays the **General** tab. Select the **Members** tab. Note that the group has no owner (the system did not automatically assign Holly Dickson as the group owner). Verify that the three users that you added as members of the on-premises group have been synced up and are members of this cloud-based group as well. Close the **Manufacturing** group window.

9. Now let’s examine this group using Windows PowerShell. If **Windows PowerShell** is already open on the taskbar, then select the PowerShell icon and proceed to the next step; otherwise, type **PowerShell** in the **Search** field on the taskbar and then right-click on the **Windows PowerShell** application and select **Run as administrator**. 


10. You should begin by running the following command that connects your PowerShell session to the Microsoft Online Service:  


		Connect-MsolService

11. In the **Sign in** dialog box, log in as **holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) with a password of **Pa55w.rd**.   


12. Run the following command that displays a list of all the Microsoft 365 groups:   



	‎	Get-MsolGroup

13. In the list of groups that’s displayed, you should verify that you can see the **Research** and **Manufacturing** groups, and that you do not see the  **Print Operators** group (this is the built-in group that did not synchronize from on-premises to Microsoft 365).


14. To verify that the group membership changes that you made in your on-premises Active Directory were synced to the **Research** group in Microsoft 365, you should copy the **ObjectID** for the **Research** group to your clipboard by dragging your mouse over the ObjectId string and then pressing **Ctrl-C**.   


	‎Then run the following command to display the members of this group. In the command, replace **<ObjectId>** with the value that you copied in the prior step by pressing **Ctrl-V** to paste in the value. 
	
		Get-MsolGroupMember -GroupObjectId <ObjectID>

15. Verify the membership of the Research group does **NOT** contain the following users that you earlier removed from the group in AD DS:  

	- Cai Chu 

	- Shannon Booth  

	- Tai Zecirevic  

16. Repeat steps 13-14 for the **Manufacturing** security group. In the **Manufacturing** group, you added the following members in AD DS, each of which you should see in the list of group members:  

	- Bernardo Rutter

	- Charlie Miller

	- Dawn Williamson

17. Once you have completed the validation steps, minimize your PowerShell window (do not close it) and proceed to the next Lab. 
 

# Proceed to Lab 4 - Exercise 2

 