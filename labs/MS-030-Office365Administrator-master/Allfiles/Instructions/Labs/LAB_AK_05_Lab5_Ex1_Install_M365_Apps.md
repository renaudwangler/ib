# Module 5 - Lab 5 - Exercise 1 - Deploying Microsoft 365 apps for enterprise

You have taken on the persona of Holly Dickson, Adatum's Enterprise Administrator, and you have Microsoft 365 deployed in a virtualized lab environment. In this exercise, you will perform the tasks necessary to manage a user-driven Microsoft 365 Apps for enterprise installation. Performing a user-driven Microsoft 365 Apps for enterprise installation is a two-step process: 1) configuring the user account so the user is eligible to download and install the setup file, and 2) performing the installation. 

In the first two tasks in this exercise, you will verify the following conditions that affect whether a user can be blocked from downloading the Microsoft 365 Apps for enterprise suite: <br/>

- The user does not have an appropriate Office 365 license (which you will verify in Task 1). 
	
- An admin turns off the global Office download setting that controls the downloading of mobile and desktop apps for all users (which you will verify in Task 2).

In the final task in this exercise, you will install the Microsoft 365 Apps for enterprise suite for one of Adatum's users.

‎
### Task 1 – Verify how licensing affects installing Microsoft 365 Apps for enterprise

In this task, Holly will test whether a user who has not been assigned an appropriate Office 365 license can download Microsoft 365 Apps for enterprise. For this test, you cannot use any of the existing users that appear in the **Active Users** list in the Microsoft 365 admin center. These users only have Microsoft 365 accounts (M365xZZZZZZ.onmicrosoft.com accounts); they do not have corresponding on-premises accounts in the adatum.com domain (which has now been changed on-premises to the xxxUPNxxx.xxxCustomDomainxxx.xxx). Without an on-premises account, you cannot log into a client VM as any of these users to install Microsoft 365 Apps for enterprise on the client machine. 

Therefore, you must use one of Adatum's on-premises user accounts that has been loaded in its VM environment. For this test, you will use **Laura Atkins**. You will create an Office 365 account for Laura, but you will not assign her an Office 365 license. 

You will then use the **LON-CL2** VM for installing Microsoft 365 Apps for enterprise (it's already installed on the other client machines).


1. Switch to **LON-CL2** and log in as **ADATUM\Administrator** with a password of **Pa55w.rd**.

2. You will begin by testing whether a user without an appropriate Office 365 license can install Microsoft 365 Apps for enterprise. For this test, you will use **Laura Atkins**. You added a Microsoft 365 user account for Laura in Lab 1, but you did not assign her an Office 365 license. For this test, you will log into Microsoft 365 on LON-CL2 as Laura. <br/>

	On LON-CL2, select the **Microsoft Edge** icon on the taskbar.

3. In **Microsoft Edge**, maximize your browser, then go to the **Microsoft Office Home** page by entering the following URL in the address bar: **https://portal.office.com/**

4. In the **Sign in** window, enter **Laura@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your tenant ID provided by your lab hosting provider) and then select **Next**.

5. In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in.**

6. If a **Stay signed in?** window appears, select the **Don't show this again** check box and then select **Yes.**

7. In the **Microsoft Office Home** page for Laura, notice that no Microsoft 365 apps appear since Laura has not been assigned an Office 365 license.  

	**Note**: the message that appears at the top of page. Laura has not been assigned an Office license that includes the Office desktop apps, so she’s unable to install Microsoft 365 Apps for enterprise. 

8. Select the **Install Office** drop-down arrow, and then select **Install software**.

9. This displays the **My account** window for Laura. Under the **Apps &amp; devices** section, you may see a notice indicating Laura has not been assigned an Office license that includes the Office desktop apps.
	
	‎**Important:** You have just verified that a user cannot download Microsoft 365 Apps for enterprise if he or she has not been assigned an appropriate Office 365 license.
	
10. Leave your browser and all tabs open and proceed to the next step.


### Task 2 – Verify how the global Office download setting affects installing Microsoft 365 Apps for enterprise

Holly is now going to test whether licensed users can be prohibited from downloading Microsoft 365 Apps for enterprise if an admin such as herself turns off the global Office download setting that controls the downloading of mobile and desktop apps for all users.

1. Switch to **LON-DC1**, where you should still be logged in as the **Administrator**. You should also have your **Edge** browser open, and you should be signed into Microsoft 365 as Holly Dickson. Your browser should have tabs open for the **Microsoft Office Home** page and **Microsoft 365 admin center**.  

2. To turn off the global Office download setting, select the **Microsoft 365 admin center** tab in your browser, and then if necessary, select **...Show all** in the left-hand navigation pane. Select **Settings**, and then within the group, select **Org Settings**. 

3. In the **Settings** window, the **Services** tab is displayed by default. Scroll down through the list of services and select **Office installation options**

4. In the **Office installation options** window, scroll down to the **Apps for Windows and mobile devices** section, where the **Office (includes Skype for Business)** check box is currently selected. Unselect this check box so that it’s blank, which turns this feature **Off**. 

5. Select **Save**.

	**Important:** Leave the **Office installation options** window open as you will come back to it in a later step in this task.

6. You should now test whether turning off this global download setting affects a **licensed** user from installing Microsoft 365 Apps for enterprise. In this case, you are going to use **Alan Yoo**, who you also added in Lab 1; however, unlike Laura Atkins, you assigned Alan an Office 365 E5 license. 
	
7. Switch  to **LON-CL2**.

8. In LON-CL2, you should still be logged in to the Microsoft 365 portal as Laura Atkins from the prior task. You must first log out of Microsoft Office as Laura, so select the circle with the **LA** initials in the upper right-hand corner of the screen. In the **My accounts** window, select **Sign out**.
	
	**Important**: As a best practice to avoid any confusion when logging out as one user and logging in as another, close all other tabs that are open in your Edge browser except for this **Sign out** tab.

9. In the **Sign out** tab, go to the **Microsoft Office Home** page by entering the following URL in the address bar: **https://portal.office.com/**

10. You are now going to sign into Microsoft 365 as **Alan Yoo**. In the **Pick an account** window, select **Use another account**. In the **Sign in** window, enter **Alan@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your tenant ID provided by your lab hosting provider) and then select **Next**.

11. In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in.**

12. If a **Get your work done with Office 365** window appears, select the X in the upper right hand corner to close it.

13. In the **Microsoft Office Home** page for Alan, notice that the Microsoft 365 apps now appear because Alan has been assigned an Office 365 license. If an **Install software** box appears, select the **Got it!** button.

14. Select the **Install Office** drop-down arrow, and then in the drop-down menu, select **Other install options**.
	
15. In the **My account** window, under the **Office apps &amp; devices** section, select **View apps &amp; devices**. 

16. In the **Apps &amp; devices** window, under the **Office** section at the top of the page, a message is displayed indicating the "Your admin has turned off office installs".
	
	‎**Important:** You have just verified that a licensed user is unable to download Microsoft 365 Apps for enterprise if the global Office download setting has been turned Off.

17. At this point Holly wants to turn the global Office download setting back On so that Alan can download Microsoft 365 Apps for enterprise.

	To do this, you must switch back to **LON-DC1**. The **Office installation options** window should still be open in your browser from when you earlier turned Off the Global Office download option.

	In the **Office installation options** window, under the **Apps for Windows and mobile devices** section, the **Office (includes Skype for Business)** check box is currently blank. Select this check box so that it displays a check mark, which now turns this feature back On.

18. Select **Save**.

19. Once you receive a message indicating the changes are saved, select the **X** in the upper-right corner of this window to close it. 

20. Now that this global Office download option is turned back On, you should see if it affects Alan’s ability to download Microsoft 365 Apps for enterprise.

	To do this, you must switch back to **LON-CL2**.

21. In LON-CL2, Alan's Edge browser should still be open, and the **Apps and devices** page should be displayed along with the error message that indicated your admin has turned off Office installs. Since you just turned this option back On, you need to refresh this page to see how it affects Alan’s ability to download Microsoft 365 Apps for enterprise.

	Select the **Refresh icon** that appears to the left of the address bar at the top of your browser. 

22. Select **My account** in the left pane of the window, under the **Office apps &amp; devices** section, the **Install Office** button now appears along with a message indicating you can install Office on up to 5 PCs or Macs, 5 tablets, and 5 smartphones. 
	
	‎**Important:** You have just verified that a user with an Office license is able to download Microsoft 365 Apps for enterprise if the global Office download setting is turned On.

23. Leave this page open on LON-CL2 and continue to the next task to perform the user-driven installation for Alan Yoo.


### Task 3 – Perform a User-Driven Installation of Microsoft 365 Apps for enterprise 

In the prior task, you logged into Alan Yoo’s client PC, and you verified that a licensed user could download Microsoft 365 Apps for enterprise if he or she was assigned an Office 365 license and the global Office download setting was turned On. In this task, you will continue the process by having Alan Yoo perform a user-driven installation of the Microsoft 365 Apps for enterprise suite from the Microsoft 365 portal.  

1. On LON-CL2, you should still be logged in as Alan Yoo. 

2. You should still be in Alan’s **My account** window since this is where you left off at the end of the prior task. Under the **Office apps &amp; devices** section, the **Install Office** button now appears since Alan is assigned an Office 365 E5 license and the global Office download setting is turned On.

	‎**Important:** Selecting this **Install Office** button will install the 64 bit, English version of Microsoft 365 Apps for enterprise. However, if you want to install a different language or version, then select **View apps &amp; devices**, which opens the **Apps &amp; devices** page; this enables you to select a different language and version of Microsoft 365 Apps for enterprise to install.

	Since Alan wants to install the 64-bit English version of Microsoft 365 Apps for enterprise, select the **Install Office** button.
		
3. In the **Just a few more steps** window that appears, select **Close**. This will initiate the downloading of the 64-bit Microsoft 365 Apps for enterprise installation wizard (**OfficeSetup.exe**).

4.  In the notification bar that appears in the upper right-hand corner of the page, once the **OfficeSetup.exe** file is downloaded, select **Open file**. This will initiate the installation wizard.

5. If a **Do you want to allow this app to make changes to your device?** dialog box that appears, select **Yes**. If you are prompted to enter a username and password, enter **ADATUM\administrator** in the **username** box and **Pa55w.rd** in the **Password** box. 

6. You may receive a dialog box that displays a warning message indicating that it may be expensive to continue downloading. Select **OK.** <br/>

	‎**Important:** This window may appear behind the Office window that displays the message: **We’re getting things ready.** If so, move the Office window to the side so that you can respond to the warning message. The Office install will NOT proceed until you select **OK** on the warning message (the Office window will just keep displaying the **We’re getting things ready** message, but it won’t actually do anything).

7. The installation may take several minutes to complete. The installation window will close once the installation is complete. 

8. To verify Alan Yoo's Microsoft 365 Apps for enterprise installation, select the **Start** icon in the lower-left corner of the taskbar. Below the **Recently added** section (at the top of the **Start** menu) select **Expand** to display all the Microsoft 365 Apps for enterprise that were just installed. This should include Word, PowerPoint, OneNote, Outlook, Publisher, Access, Skype for Business, and Excel.

9. In the **Start** menu, select **Word**.

10. Select **Sign-in** and in the **Sign in** window, enter **Alan@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your tenant ID provided by your lab hosting provider) and then select **Next**.

11. In the **Enter password** window, enter **Pa55w.rd** and then select **Sign in.**

12. In the **Accept the license agreement** window, select **Accept**.

13. On the **Your privacy option** window, select **Close**.

14. Verify that Word is functioning properly by opening a blank Word document, entering some text, and saving the document to the **Documents** folder. 

15. Close Word.

16. Leave your browser open and proceed to the next lab.


# Proceed to Lab 5 - Exercise 2
