# Module 5 - Lab 5 - Exercise 2 - Deploying Microsoft 365 apps for enterprise using Mobile Device Management

You have taken on the persona of Holly Dickson, Adatum's Enterprise Administrator, and you have Microsoft 365 deployed in a virtualized lab environment. In this exercise, you will perform the tasks necessary to manage a Microsoft 365 Apps for enterprise installation using Mobile Device Management. 

Starting in Windows 10, version 1709, you can use a Group Policy to trigger auto-enrollment to MDM for Active Directory (AD) domain-joined devices.

The enrollment into Intune is triggered by a group policy created on your local AD and happens without any user interaction. This means you can automatically mass-enroll a large number of domain-joined corporate devices into Microsoft Intune. The enrollment process starts in the background once you sign in to the device with your Azure AD account.

In the first task, Holly adds Microsoft 365 apps for enterprise as a managed app.

In tasks 2 and 3 in this exercise, Holly extends the Hybrid Azure AD domain-join setup to enroll devices for cloud-based Mobile Device and Mobile Application Management (MDM and MAM).

In the final task, you will verify the installation of Microsoft 365 apps for enterprise.

### Lab Setup

For this lab, Windows 10 1803 is the minimum requirement. Therefore, the clients need to be updated. You will update one of the clients to demonstrate the feature.

1. Switch to **LON-CL3**.

2. Log into LON-CL3 as the **Adatum\Administrator** with the password **Pa55w.rd**.

3. Select the **Windows (Start)** icon in the lower left corner of the taskbar, and start to type **Services**. When the **Services** app is found, select it.

4. In **Services**, double-click **Windows Update**.

5. In **Windows Update Properties (Local Computer)**, beside **Startup type**, select **Automatic**, then select **Apply**.

6. Select **Start**, wait for the service to start, then select **OK**.

7. Close **Services**.

8. Select the **Windows (Start)** icon in the lower left corner of the taskbar, then select **Settings**.

9. Select **Update & security**.

10. In **Windows Update**, select **Advanced options**. Clear the Checkbox **Defer feature updates** and select the back button.

11. Under **Update status**, select **Check for updates**. This will install the 1803 update among others.

12. Restart if required and wait for the update to complete. This can take some time again.


### Task 1 - Add Microsoft 365 apps to Windows 10 devices with Microsoft Intune

Holly wants to add Microsoft 365 apps automatically to managed devices. To manage devices using Microsoft 365, Adatum has purchased Enterprise Security + Mobility E5 licenses. In this task, Holly assigns on of these licenes to a user. Then, she add Microsoft 365 apps to managed devices and verifies the installation.

1. Switch to the **LON-CL1** client VM. 

2. Log into LON-CL1 as the **Adatum\Administrator** with the password **Pa55w.rd**. 

3. On the taskbar at the bottom of the page, select the **Microsoft Edge** icon. Maximize your browser window when it opens.

4. In your browser go to the **Microsoft Office Home** page by entering the following URL in the address bar: **https://portal.office.com/** 

5. In the **Sign in** window, enter **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ should be replace with your tenant ID). Select **Next**.

7. In the **Enter password** dialog box, enter **Pa55w.rd** and then select **Sign in**.

8. In the **Office 365 Home** page, select **Admin**.

9. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Show all...**, then select **Endpoint Manager**.

10. In **Microsoft Endpoint Manager admin center**, in the left-hand navigation pane, select **Apps**.

11. In the **Apps** blade, select **All apps**.

12. In **Apps | All apps**, select **+ Add**.

13. In the **Select app type pane**, under **App type**, select the drop-down. Under **Microsoft 365 Apps**, select **Windows 10**, then select **Select**.

14. In the **App suite information** page, confirm the default values and select **Next**.

15. In the **Configure app suite** page, beside **Select Office apps**, select the drop-down. Confirm, that all apps are selected, except **Skype for business**. Select the drop-down again to close it.

16. Beside **Select other Office apps (license required)**, select the drop-down, select **Project Online Desktop client** and **Visio Online Plan 2**, and select the drop-down again to close it.

17. Beside **Update channel**, in the drop-down, select **Semi-Annual Enterprise Channel**.

18. Beside **Accept the Microsoft Software License Terms on behalf of users**, select **Yes**.

19. Select **Next**.

20. In the **Assignments** page, under **Required**, select **Add all users**, then select **Next**.

21. In the **Review + create** page, select **Create**.


### Task 2 - Verify auto-enrollment requirements

To ensure that the auto-enrollment feature is working as expected, you must verify that various requirements and settings are configured correctly. The following steps demonstrate required settings using the Intune service:

1. From the previous task, you should still be logged into the **Microsoft Endpoint Manager admin center** as Holly.

2. In the **Microsoft Endpoint Manager admin center**, in the left-hand navigation pane, select **Devices**.

3. In the **Devices** blade, under **Device enrollment**, select **Enroll devices**.

4. In the **Enroll devices** blade, verify that **Windows enrollment** is selected, and select **Automatic enrollment**.

5. In **Configure Microsoft Intune**, beside **MDM user scope**, select **All**. Beside **MAM user cope**, select **All**. Select **Save**.


### Task 3 - Configure the auto-enrollment Group Policy for a single PC

Holly wants to show how the new auto-enrollment policy works. This is not recommended for the production environment in the enterprise. For bulk deployment, you should deploy the same setting using an Active Directory domain group policy object.

**Note:** Continue with this task only, after you finished the steps under **Lab setup**. If the update process takes, is not finished yet, you may return to this exercise at a later point in the course.

1. Switch to **LON-CL3**.

2. You should still be logged into LON-CL3 as **Adatum\Administrator**. 

3. Select the **Windows (Start)** icon in the lower left corner of the taskbar, and type **gpedit**.

4. Under **Best match**, select **Edit group policy** to launch it.

5. In **Local Computer Policy**, select **Administrative Templates** > **Windows Components** > **MDM**.

6. ‎Double-click **Enable automatic MDM enrollment using default Azure AD credentials**. 

7. In **Enable automatic MDM enrollment using default Azure AD credentials**, select **Enabled**.

8. From the dropdown **Select Credential Type to Use**, select **User**.

   **Note:** In Windows 10, version 1903, the MDM.admx file was updated to include an option to select which credential is used to enroll the device. **Device Credential** is a new option that will only have an effect on clients that have installed Windows 10, version 1903 or later. The default behavior for older releases is to revert to **User Credential**. **Device Credential** is not supported for enrollment type when you have a ConfigMgr Agent on your device.

9. Close **Local Group Policy Editor** and sign out from LON-CL3.

### Task 4 - Verify successful enrollment and app deployment

In this task, Beth Burke verifies, that the computer is enrolled for Mobile Device Management and that the Microsoft 365 apps are installed.

**Note:** It may take 5 minutes or more, until the device registration finishes.

1. Log in to **LON-CL3** as **Beth@xxxUPNxxx.xxxCustomDomainxxx.xxx** (where xxxUPNxxx was the unique UPN name assigned to your tenant, and xxxCustomDomainxxx.xxx was the name your lab hosting provider assigned to the custom domain) account with a password of **Pa55w.rd**.

2. Select the **Windows (Start)** icon in the lower left corner of the taskbar, select **Settings**.

3. Select **Accounts** and **Access work or school**.

4. Select Beth's domain account.

5. Select **Info** to see the MDM enrollment information.

6. Wait a few minutes and verify, that the Microsoft 365 apps were installed on LON-CL3.


# End of Lab 5
