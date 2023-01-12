# Module 3 - Lab 3 - Exercise 1 - Running the Microsoft 365 connectivity analyzer tools

The Remote Connectivity Analyzer is a web-based tool that's designed to help IT administrators troubleshoot connectivity issues with their Office 365 and Exchange Online deployments. In your role as Holly Dickson, Adatum's Enterprise Admin, you want to run the tool to determine if you have any connectivity issues that may disrupt your Microsoft 365 deployment.

### Task 1: Run the Microsoft Connectivity Analyzer tool

In this task, you will use the Remote Connectivity Analyzer tool to perform the following connectivity tests:

- You will test the external domain name settings for your verified **M365xZZZZZZ.onmicrosoft.com** domain in Office 365. The test will look for issues with mail delivery such as not receiving incoming email from the Internet and Outlook client connectivity issues that involve connecting to Outlook and Exchange Online.
- You will perform a test that walks through the steps Outlook uses to connect from the Internet. This test verifies connectivity using both the RPC over HTTP protocol and the MAPI over HTTP protocol.

This tools also includes a link to download the Microsoft Support and Recovery Assistant, which you will test in the next task.

1. You should still be logged into the **LON-CL1** VM as the **Administrator** from the prior lab exercise. 

2. At the end of your prior lab exercise, you logged out of Microsoft 365 and you closed your Microsoft Edge browser. In this task, re-open a new instance of your Edge browser by selecting the **Edge** icon on your taskbar.

3. In your Edge browser, enter the following URL in the address bar: **https://testconnectivity.microsoft.com**

4. Test #1 - You will begin by testing Office 365 connectivity.

	On the **Microsoft Remote Connectivity Analyzer** page, in the left-hand navigation pane, the **Office 365** tab is displayed by default.

5. On the **Office 365** page, select the box that says: **Exchange Online Custom Domain DNS Connectivity Test**.

6. On the **Office 365 Exchange Domain Name Server (DNS) Connectivity Test** page, enter the following information:

	- Enter **M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) in the **Domain Name** field 
	- Under **Service Selection**, select the **Office 365 (Default)** option (if it's not already selected)
	- Under **Verification**, enter the characters that you can see in the verification field and then select **Verify**. Note - The verification code is not case-sensitive.

7. If the verification test is successful, a message will be displayed below the verification field that indicates: **You are now verified for the rest of this browser session (30 minute maximum).**

8. Select **Perform Test**.

	**Note:** If you receive a message about having performed too many tests in 60 seconds, wait a couple of minutes and then repeat the test.

9. When you see **Successfully verified specified external domain name settings for your domain in Office 365**, select the 'V' arrow next to **Test Steps** (selecting on **Test Steps** itself does not work) and then review the connectivity checks that were made against the **M365xZZZZZZ.onmicrosoft.com** domain.

10. Test #2 - You will next test Exchange Server connectivity.

	On the **Microsoft Remote Connectivity Analyzer** page, in the left-hand navigation pane, select **Exchange Server**.

11. On the **Exchange Server** page, select the box that says: **Outlook Connectivity**.

12. On the **Outlook Connectivity** page, enter the following information:

	- Enter **admin@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) in **BOTH** the **Email Address** AND **Domain\User Name (or UPN)** fields
	- Copy and paste in the password of the Microsoft 365 tenant admin in the **Password** field
	- Ensure the **Use Autodiscover to detect server settings** option is selected
	- Select the check box that says: **I understand that I must use the credentials of a working account from my Exchange domain to be able to test connectivity to it remotely. I also acknowledge that I am responsible for the management and security of this account**.

13. Select **Perform Test**.

14. When you see **The Outlook connectivity test completed successfully** message, select the arrow next to **Test Steps** (selecting on **Test Steps** itself does not work) and then review the connectivity checks that were made against **Outlook**. Each step has additional **Test Steps** that you can select to displayed more detailed information about each test. 

15. Leave the **Microsoft Remote Connectivity Analyzer** window open in your Edge browser and proceed to the next task.

### Task 2 - Run the Microsoft 365 Support and Recovery Assistant

The Microsoft Support and Recovery Assistant (SARA) works by running tests to figure out what's wrong and offers the best solution for the identified problem. It can currently fix Office, Microsoft 365, and Outlook problems. If the Microsoft Support and Recovery Assistant can't fix a problem, it will suggest next steps and help you get in touch with Microsoft support.

In this task, you will download the SARA tool and then you will run it to check for authentication checks for Exchange Online. 

1. You should still be logged into the **LON-CL1** VM as the **Administrator** from the prior task. 

2. You should still have the **Microsoft Remote Connectivity Analyzer** window open in your Edge browser. In the left-hand navigation pane, select **SARA Client**. This will open a new tab in your browser that displays the **About the Microsoft Support and Recovery Assistant** page.

3. In the **About the Microsoft Support and Recovery Assistant** page, select the **Download** button in step #1. This will automatically download the **SaraSetup.exe** file. 

4. If the **SaraSetup.exe** file appears in the notification bar at the bottom of the screen, select **Open file** after the download is complete to initiate the installation wizard.

	**Note:** If the notification bar does not appear in the upper right-hand corner of the browser, then select the **File Explorer** icon on the taskbar to open **File Explorer**, select the **Downloads** folder, and then double-click on the **SaraSetup.exe** file to initiate the installation wizard.

5. In the **Microsoft Support and Recovery Assistant Setup** wizard, on the **Do you want to install this application?** page, select **Install**.

6. In the **Microsoft Support and Recovery Assistant Setup** window, once the wizard finishes downloading the application, it will display the license agreement page. Select **I agree**.

7. On the **Which app are you having problems with?** page, select **Advanced diagnostics** and then select **Next**.

8. On the **Which Advanced diagnostic would you like to run?** page, select **Exchange Online** and then select **Next**.

9. On the **Select the diagnostic you’d like to run** page, select **Perform authentication checks** and then select **Next**.

10. On the next page that asks if this is the affected machine, select **Yes** and then select **Next**.

11. On the **Let's get started fixing your problem** page, enter **Holly@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is the tenant ID provided by your lab hosting provider) and enter **Pa55w.rd** in the **Password** field. Select the **Keep me signed in** check box (is it's not already checked) and then select **Next**.

12. Once the **Microsoft 365 Support and Recovery Assistant** generates the diagnostic test results, review the details by selecting **+ View summary**. Select the down arrow to the far-right of **Office 365 readiness checks** to review the specific tests that were performed. Also note the domain registration check that was performed using Holly's account.

14. Close the **Microsoft 365 Support and Recovery assistant** window (if you select the **Next** button, it will take you to a survey page).

	**Note:** If selecting the X in the upper-right hand corner of the SARA window does not close it, right click on the SARA icon on the taskbar and  select the **Close window** option. 

13. Close your Edge browser and proceed to the next lab exercise.


# Proceed to Lab 3 - Exercise 2‎