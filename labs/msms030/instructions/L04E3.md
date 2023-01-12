# Module 4 - Lab 4 - Exercise 3 - Enable Hybrid Domain Join

In this exercise, you will run Azure AD Connect to configure Hybrid Azure AD join. Hybrid Azure AD join enables automatic account configuration and Single-Sign-On to cloud services for devices joined to Adatum's on-premises Active Directory. You will verify the device sync and verify the Hybrid Azure AD Join on LON-CL1 by using dsregcmd and the Windows 10 Mail app.

### Task 1 - Configure Hybrid Azure AD join

In this task, you will run the Azure AD Connect setup wizard to enable Hybrid Azure AD join of devices joined to Adatum’s on-premises Active Directory. 

‎1. You should still be logged into **LON-DC1** as the **Administrator** from the prior exercise.

2. Start **Azure AD Connect** by double-clicking the icon on the Desktop.

3. In **Microsoft Azure Active Directory Connect**, click **Configure**.

4. In **Additional tasks**, select **Configure device options**, and then select **Next**.

5. In **Overview**, select **Next**.

6. In **Connect to Azure AD** window, enter **Holly@M365xZZZZZZ.onmicrosoft.com** (where zzzzzz is the tenant ID provided by your lab hosting provider) in the **USERNAME** field, enter **Pa55w.rd** in the **PASSWORD** field, and then select **Next**. 

7. In **Device options**, select **Configure Hybrid Azure AD join**, and then select **Next**.

8. In **Device operating systems**, select **Windows 10 or later domain-joined devices**, and then select **Next**.

9. In SCP configuration, select the checkbox to the left of **Adatum.com**, and under **Authentication Service** select **Azure Active Directory**, and select **Add**.

10. In the **Enterprise Admin Credentials** window, enter **ADATUM\Administrator** in the **USERNAME** field, enter **Pa55w.rd** in the **PASSWORD** field, and then select **OK**. 

11. Back in **SCP configuration**, select **Next**.

12. **In Ready to configure**, select **Configure**.

13. In **Configuration complete**, select **Exit**.

14. Switch to **LON-CL1** and if necessary, close any open applications and then select the **Start button**, select the icon for **Administrator** and then select sign out.

15. On the log-in screen, click **Other user** and sign-in as **Beth@xxxUPNxxx.xxxCustomDomainxxx.xxx** (where xxxUPNxxx was the unique UPN name assigned to your tenant, and xxxCustomDomainxxx.xxx was the name your lab hosting provider assigned to the custom domain) account with a password of **Pa55w.rd**.

### Task 2 - Assign licenses

In this task, you assign product licenses to a synced user.

‎1. Switch to **LON-DC1** and log in as **Administrator** with a password of **Pa55w.rd**.

2. After finishing the previous lab exercise, you should still be logged into Microsoft 365 in your Edge browser as Holly Dickson.  

3. In your **Edge** browser, select the **Microsoft 365 admin center** tab, and then in the left-hand navigation pane, expand **Users**, and then select **Active Users**.

4. In **Active users**, in **Search active users list** enter **holly** and press Enter.

5. Select the entry for **Holly Dickson** that has the **Office 365 E5, Enterprise Mobility + Security E5** licenses.

6. In the menu bar above the list of users, select **Manage product licenses**. If you do not see this button, select the **ellipsis** icon (**More actions**). In the drop-down menu that appears, select **Manage product liceneses**.

7. In the **Licenses and apps** pane that appears for Holly Dickson, clear the checkbox next to **Office 365 E5**, and click **Save changes**, then close the pane by clicking the **X** in the upper right-hand corner.

8. In **Search active users list** enter **beth** and press Enter.

9. Select **Beth Burke**.

10. In the menu bar above the list of users, select **Manage product licenses**. If you do not see this button, select the **ellipsis** icon (**More actions**). In the drop-down menu that appears, select **Manage product liceneses**.

11. In the **Licenses and apps** pane that appears for Beth Burke, select **Office 365 E5** and **Enterprise Mobility + Security E5**, and click **Save changes**, then close the pane by clicking the **X** in the upper right-hand corner.


### Task 3 - Verify device sync

In this task, you will start another sync cycle and verify that computer accounts from Adatum's on-premises Active Directory are synced as devices to Azure Active Directory.

1. You should still be logged into **LON-DC1** as the **Administrator** from the prior task.

2. In the **PowerShell** window, press the **Up arrow** key to repeat the last command:
   ```
	‎	Start-AdSyncSyncCycle -PolicyType Delta
   ```

3. After finishing the previous exercise, you should still be logged into Microsoft 365 in your Edge browser as Holly Dickson.

4. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **...Show all** to display all the navigation menu options.

5. In the left-hand navigation pane, under **Admin centers**, select **Azure Active Directory**.

6. In the **Azure Active Directory admin center**, in the left-hand navigation pane, select **Azure Active Directory**.

7. In the **Azure Active Directory** blade for Adatum Corporation, under **Manage**, select **Devices**.

8. In the **Devices | All devices** blade, look for **LON-CL1**. If you do not see the device, wait a few minutes, and above the list of devices, click **Refresh** until you see **LON-CL1**.



### Task 4 - Verify the Hybrid Azure AD Join

In this task, you will verify the Hybrid Azure AD Join by running the dsregcmd command. Moreover, you will verify Single-Sign-On and automatic account configuration in the Windows 10 Mail app.

1. Switch to **LON-CL1**.

2. You should still be logged in as **Beth** from the previous task. In order to trigger the Hybrid Join, you need to sign out as Beth.

3. On the log-in screen, you log in as **Beth@xxxUPNxxx.xxxCustomDomainxxx.xxx** (where xxxUPNxxx was the unique UPN name assigned to your tenant, and xxxCustomDomainxxx.xxx was the name your lab hosting provider assigned to the custom domain) account with a password of **Pa55w.rd**.

4. Right-click the **Windows (Start) icon** in the lower left corner of the taskbar, and select **Command Prompt**.

6. Type
   ```
   dsregcmd /status
   ```
   and press Enter.

7. In the output, beside **AzureADJoined** you should see **YES**. If not, wait a few moments and try again.

8. Close **Command Prompt**.

9. Select the **Windows (Start)** icon in the lower left corner of the taskbar, and select **Settings**.

10. In **Windows Settings**, select **Accounts**.

11. Select **Email & app accounts**. You should see Beth's Work or school account.

   **Note:** If you do not see the **Beth@xxxUPNxxx.xxxCustomDomainxxx.xxx** account listed, log off and back on again and try again from **Step 9**.

12. Close **Settings**.

13. Select the **Windows (Start)** icon in the lower left corner of the taskbar, and select **Mail**.

14. In **Mail**, click **Get started**.

15. In **Accounts**, click **+ Add account**.

16. Beth's work or school account should be offered at the top of the list. Select it.

17. The account should be configured automatically without any intervention. When the **All done!** message appears, click **Done**.

18. Back in **Accounts**, click **Ready to go**.

	**Note:** Syncing might not work yet, because the mailbox was not created. If Beth receives the first mail, syncing should work.

19. Close the **Mail** app and then Sign out as Beth.


### Task 5 - Restore licenses

1. Switch to **LON-DC1**.

2. You should still have the **Microsoft 365 admin center** open in **Edge** from Task 2.

3. In your **Edge** browser, select the **Microsoft 365 admin center** tab, and then in the left-hand navigation pane, expand **Users**, and then select **Active Users**.

4. In **Active users**, in **Search active users list** enter **beth** and press Enter.

5. Select the entry for **Beth Burke** that has the **Office 365 E5** license.

6. In the menu bar above the list of users, select **Manage product licenses**. If you do not see this button, select the **ellipsis** icon (**More actions**). In the drop-down menu that appears, select **Manage product liceneses**.

7. In the **Licenses and apps** pane that appears for **Beth Burke**, clear the checkbox next to **Office 365 E5**, and click **Save changes**, then close the pane by clicking the **X** in the upper right-hand corner.

8. In **Search active users list** enter **holly** and press Enter.

9. Select the **Holly Dickson** that has the **Enterprise Mobility + Security E5** license.

10. In the menu bar above the list of users, select **Manage product licenses**. If you do not see this button, select the **ellipsis** icon (**More actions**). In the drop-down menu that appears, select **Manage product liceneses**.

11. In the **Licenses and apps** pane that appears for **Holly Dickson**, select **Office 365 E5**, and click **Save changes**, then close the pane by clicking the **X** in the upper right-hand corner.

# End of Lab 4
 