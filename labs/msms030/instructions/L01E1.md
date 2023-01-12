# Module 1 - Lab 1 - Initialize your Microsoft 365 Tenant

Adatum Corporation runs their legacy applications (such as Microsoft Exchange) in an on-premises deployment. However, they recently subscribed to Microsoft 365, thereby creating a hybrid deployment in which they must synchronize their on-premises and cloud deployments. 

Throughout the labs in this course, you will take on the persona of Holly Dickson, Adatum's Enterprise Administrator. You have been tasked with deploying Microsoft 365 using a virtualized lab environment. Adatum's project team has decided to implement Microsoft 365 in a pilot project that will not only provide them with experience using the product, but also enable them to match their business requirements with the Microsoft 365 feature set. In this exercise, you will begin implementing Microsoft 365 within the pilot project by setting up Adatum's Microsoft 365 trial tenant. 

Your instructor will provide guidance on how to obtain your Microsoft 365 credentials in your lab-hosted environment. You will use these credentials throughout the remaining labs in this course. 

In your lab environment, your lab hosting provider has already:

- Deployed the trial tenant
- Created a default tenant administrator account (known as the MOD Administrator)
- Created 9 additional user accounts
- Created a custom domain in Microsoft Azure (not on-premises)
- Created the DNS records in Microsoft Azure that are required to support the custom domain and the selected Microsoft 365 services
 
In this lab, you will complete the following exercises:

- Exercise 1 - Provision Adatum's Microsoft 365 tenant
- Exercise 2 - Complete the custom domain setup process
- Exercise 3 - Explore the Microsoft 365 administrator interfaces

## Exercise 1 - Provision Adatum's Microsoft 365 Tenant

In this exercise, you will update Adatum's Microsoft 365 organizational profile, and you will verify the provisioning of Adatum's Microsoft 365 tenant, as well as the tenant's service health. 

### Task 1 - Obtain Your Microsoft 365 Credentials

Once you launch the lab, a free trial tenant will be automatically created for you to access Azure in the Microsoft Virtual Lab environment. This tenant will be automatically assigned a unique Microsoft 365 administrator account and password. You must retrieve this username and password so that you can sign into Azure within the Microsoft Virtual Lab environment. 

1. Because this course can be offered by learning partners using any one of several authorized lab hosting providers, the actual steps involved to retrieve the UPN name, network IP address, and tenant ID associated with your tenant may vary by lab hosting provider. Therefore, your instructor will provide you with the necessary instructions on how to retrieve this information for your course. <br/>

	You should write down the following information (provided by your instructor) for later use:

	- **Tenant suffix ID.** This ID is for the onmicrosoft.com accounts that you will use to sign into Microsoft 365 throughout the labs. This is in the format of **{username}@M365xZZZZZZ.onmicrosoft.com**, where ZZZZZZ is your unique tenant suffix ID provided by your lab hosting provider. Record this ZZZZZZ value for later use. When any of the lab steps direct you to sign into the Office 365 or Microsoft 365 portals, you must enter the ZZZZZZ value that you obtained here.
	- **Tenant password.** This is the password for the admin account provided by your lab hosting provider.
	

### Task 2- Set up the Organization Profile

In your role as Holly Dickson, Adatum’s Enterprise Administrator, you have been tasked with setting up the company’s profile for its Microsoft 365 trial tenant. In this task, you will configure the required options for Adatum’s tenant. Since Holly has yet to create a personal Microsoft 365 user account (you will do this in Lab 2), she will initially sign into Microsoft 365 as the default Microsoft 365 MOD Administrator account using the Tenant admin's username and password that was assigned to it by your lab hosting provider.

1. When you open your lab hosting provider's Virtual Machine environment, you need to begin with the Domain Controller VM (LON-DC1). If your VM environment opens with one of the other virtual machines, such as LON-CL1, then switch to the **LON-DC1** VM.

2. Log into LON-DC1 as the **Administrator** with the password **Pa55w.rd**. 

3. If you receive a **Networks** warning message asking if you want this PC to be discoverable by other PCs and devices on this network, select **Yes.**

4. **Server Manager** will automatically start. Leave it open but minimize the window for now.

5. On the taskbar at the bottom of the page, select the **Microsoft Edge** icon. Maximize your browser window when it opens.

6. In your browser go to the **Microsoft Office Home** page by entering the following URL in the address bar: **https://portal.office.com/** 

7. In the **Sign in** dialog box, copy and paste in (or enter) the username of the Microsoft 365 Tenant administrator account provided by your lab hosting provider (**admin@M365xZZZZZZ.onmicrosoft.com**, where ZZZZZZ is your unique tenant suffix ID provided by your lab hosting provider) and then select **Next**.

8. In the **Enter password** dialog box, copy and paste in the **Tenant Password** provided by your lab hosting provider and then select **Sign in**.

9. On the **Stay signed in?** dialog box, select the **Don’t show this again** check box and then select **Yes.**

10. If a **Get your work done with Office 365** window appears, then close it now. 

11. In the **Microsoft Office Home** page, you are now signed in as the **MOD Administrator** account (note the **MA** initials in the circle that appears in the upper right-hand corner of the screen). The MOD Administrator is a pre-defined user created in Microsoft 365 by your lab hosting provider. Since this user has been assigned a Microsoft 365 administrator role (in this case, the Global Admin role), the Microsoft 365 admin center is available on the home page along with all the other Office apps. 

	On the **Office 365 Home** page, the list of available apps is displayed. If an **Office 365 apps** box appears on the screen, select the **Got it!** button to close the box, since it covers up several of the apps. Select the **Admin** app, which opens the **Microsoft 365 admin center**.

12. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **...Show all** to display all the navigation menu options.

13. In the left-hand navigation pane, select **Settings**, and then in the **Settings** group, select **Org Settings**. 

14. In the **Settings** window, the **Services** tab is displayed by default at the top of the screen. Since you want to update the organization profile, select the **Organization profile** tab, and then in the list of organization settings, select **Organization information**.

15. In the **Organization information** window that appears, enter the following information:

	- Name: Replace **Contoso** with **Adatum Corporation** 
	
	**Note:** The Contoso organization name was explained in the Introduction section at the start of this lab. For the purposes of this lab, you will change it to Adatum Corporation.

	- Street address: **123 Main Street**

	- City: **Redmond**

	- State or province: **Washington**

	- ZIP or postal code: **98052**
	
	- Country or region: **United States**

	- Phone: **425-555-1234**

	- Technical contact: **admin@M365xZZZZZZ.onmicrosoft.com** (where ZZZZZZ is your unique tenant ID provided by your lab hosting provider)

	- Preferred language: **English**

16. Select **Save**.

17. Once the changes have been saved, a **Saved** message will appear at the top of the **Organization information** window. Select the **X** in the upper right-hand corner of the window to close it.

18. This will return you to the **Organization profile** tab of the **Org settings** window. In the organization profile list, select **Release preferences**.

19. In the **Release preferences** window, select **Targeted release for select users** and then select **Save**.  <br/>

    ‎**Note:** One of the benefits of Microsoft 365 is the ability to have the latest features and updates applied to your environment automatically, which can reduce maintenance costs and overhead for an organization. By setting up your Release preferences, you can control how and when your Microsoft 365 tenant receives these updates.

    The **Targeted release for select users** option enables you to create a control group of users who will preview updates so that you can prepare the updates for your entire organization. The **Targeted release for everyone** option is more commonly used in development environments, where you can get updates early for your entire organization. In non-development environments, such as Adatum, targeted release to select people is the more typical preference as it enables an organization to control when it wants to make updates available to everyone once the updates have been reviewed by the control group.

20. Under the **Targeted release for select users** setting are options to **Select users** and **Upload users** (from a CSV file). Select the **Select users** option.  

21. In the **Choose users for targeted release** window, select the **Who should receive targeted releases?** field. This will display the list of existing Microsoft 365 user accounts that were created in your Microsoft 365 tenant by your lab hosting provider.

22. In the list of users, scroll down and select the **MOD Administrator** account and then select **Save**.

23. On the **Release preferences** window, select the **X** in the upper right-hand corner to close the window.

24. On the **Organization profile** tab of the **Org settings** window, select **Custom themes**.

25. In the **Custom themes** window, scroll though the page and review the various theme and branding options that are available for you to update. For the purpose of this lab, you can change any of the options or leave the default values as is. For example, you can add the logo of your company and set the background image as the default for all your users. Along with these options you can change the colors for your navigation pane, text color, icon color, and accent color. Go ahead and explore the different options for your tenant and make any changes that you wish. <br/>

    **Note:** Some color patterns aesthetically distract users. If you do change any of the colors, it is recommended that you avoid using high contrasting colors together, such as neon colors and high-resolution colors like bright pink and white.

26. If you made any changes in the **Custom themes** window, select **Save** when you are done. When you are finished with the **Custom themes**, select the **X** in the upper right-hand corner to close the window.

27. Remain logged into the LON-DC1 VM and leave all the tabs open in your browser for the remaining tasks in this lab exercise. 



### Task 3: Confirm Microsoft 365 Tenant provisioning

While your lab hosting provider created Adatum's Microsoft 365 tenant, Adatum must still configure and provision it. In your role as Holly Dickson, Adatum's Enterprise Administrator, you will complete the provisioning process in this task so that you can proceed with your Microsoft 365 pilot project.

1. After completing the previous task, you should still be logged into **LON-DC1** as the **Administrator** account, and you should be signed into the **Microsoft 365 admin center** as the **MOD Administrator** account. 

2. In the **Microsoft 365 admin center**, in the left-hand navigation pane, select **Users**, and then in the **Users** group, select **Active users**. 

3. In the **Active users** list, you will see the list of existing Microsoft 365 user accounts that were created by your lab hosting provider. <br>

	Review the **Username** column. Note that each user's username is assigned to the **M365xZZZZZZ.onmicrosoft.com** domain (where ZZZZZZ is tenant ID assigned to your Microsoft 365 tenant). <br>

	To confirm that these users have been licensed, review the **Licenses** column. Each user should be assigned an **Office 365 E5** license and an **Enterprise Mobility+Security E5** license. The MOD Administrator account should also be assigned a **Windows 10 Enterprise E3** license.

4. In the left-hand navigation pane, under the **Admin centers** section, select **Exchange**.

5. A new tab will open in your browser displaying the **Exchange admin center**. In the left-hand navigation pane, under **Recipients**, select **Mailboxes**.

6. The same users who were displayed in the **Active users** list in the **Microsoft 365 admin center** should be displayed on this  **Mailboxes** page. <br>
	
	If you see the same list of users, this confirms the fact that your Microsoft 365 tenant had been properly provisioned and does not have any issues at this time.

7. In your browser, close this **Exchange admin center** tab but leave the **Microsoft Office Home** tab and the **Microsoft 365 admin center** tab open and proceed to the next task. 


### Task 4: Verify Microsoft 365 service health

In this task, you will determine the service health of your Microsoft 365 tenant.

1. After completing the previous task, you should still be logged into **LON-DC1** as the **Administrator** account, and you should be signed into the **Microsoft 365 admin center** as the **MOD Administrator** account. <br> 

2. In the **Microsoft admin center**, in the left-hand navigation pane, select **Health**, and then select **Service health**. This will display the **Service health** dashboard.

3. On the **Service health** page, the **All services** tab at the top of the page is displayed by default. This tab displays all the Microsoft 365 services that are available with your current subscriptions. <br>

	Review the **Status** column for each service. If any service has a status other than **Healthy**, select the **Health** for that service (the Health value is hyperlinked, whereas the service name itself is not). 

4. Selecting the status of an non-healthy service displays the **Advisories** tab at the top of the page. Review any service interruption records or additional information in this **Advisories** tab. <br>

	**Note:** During Microsoft testing, on rare occasions Microsoft 365 did not create the trial tenant properly; as a result, the tenant did not have all the services available to it. If this happens to you, you should create a new trial tenant using a different business email (Microsoft account).

5. After reviewing the advisories for the selected service, select the **All services** tab at the top of the page. Repeat steps 3-4 for any other services that do not have a **healthy** status. 

6. Leave your web browser open and proceed to the next lab exercise. 


**Results**: After completing this exercise, you should have successfully provisioned the Microsoft 365 tenant account for A. Datum Corporation.


## Exercise 2: Complete the Custom Domain Setup process

Adatum has purchased a new domain (provided by your lab hosting provider) that resides in Microsoft Azure and not on-premises. To support Adatum’s new custom domain, your lab hosting provider took on the role of Adatum’s third-party domain registrar. In doing so, it added the custom domain, as well as the DNS records that are necessary to support the services required by Adatum for this new domain. 

Most companies do not personally manage their DNS records themselves; instead, they have a third-party resource that manages these records for them. To assist in this effort, Microsoft 365 provides certain third-party domain registrars with an automation tool that automatically adds and replaces a company’s DNS records. The automation tool also federates the sign in credentials for the third-party registrars and Microsoft 365. 

Using a tool to automatically maintain DNS records is a much-welcomed improvement from the days when companies had to manually maintain these records, which oftentimes introduced human error into a rather complicated process. Because these tools eliminate the need to manually add the DNS records, they eliminate human error from the process. 

Even though your lab hosting provider created the custom domain and corresponding DNS records in Microsoft Azure, Adatum must still complete the provisioning of this custom/vanity domain and its DNS records. This process is important since it places Adatum's business’ name as its email domain, which adds validity to message traffic and confirms that Adatum owns the vanity domain that it has added. 

To complete the domain setup process, you must run a setup wizard that verifies the accuracy of each required DNS record. This process enables you to review and validate the different types of DNS records that have been added to support this new vanity domain in Adatum’s Microsoft 365 deployment. 


### Task 1: Complete Adatum’s custom domain setup

Your lab hosting provider has already added a custom domain for Adatum; however, it did not complete the custom domain setup process. In this task you will complete the setup of this custom domain in Microsoft 365. Your lab hosting provider has added the necessary DNS records for Adatum; it is your job to complete this setup process by initiating a wizard that verifies the accuracy of these DNS records. 

1. After completing the previous lab exercise, you should still be logged into **LON-DC1** as the **Administrator** account.  

2. In your Microsoft Edge browser, you should still be logged in to Microsoft 365 as the **MOD Administrator** (**admin@M365xZZZZZZ.onmicrosoft.com**). You should have tabs open for the Microsoft Office Home page and the Microsoft 365 admin center. 

3. In the **Microsoft 365 admin center**, in the left-hand navigation pane, you already expanded the **Settings** group in the previous exercise when you updated the **Org settings**. To complete the custom domain setup in this task, select **Domains** that appears within the **Settings** group. 

4. On the **Domains** page, you should see two domains. <br>

	One is the **M365xZZZZZZ.onmicrosoft.com** domain, which was automatically created for Adatum's Microsoft 365 tenant (where ZZZZZZ is your unique tenant ID). <br>

	The other domain is the **xxxUPNxxx.xxxCustomDomainxxx.xxx** domain, which is the custom vanity domain that was created for Adatum by your lab hosting provider. <br>

	**Important:** The **xxxUPNxxx.xxxCustomDomainxxx.xxx** domain should be set as Adatum's Default domain (note the **Default domain** moniker next to the domain name). If your lab hosting provider set the **M365xZZZZZZ.onmicrosoft.com** domain as Adatum's default domain, you must change it so that **xxxUPNxxx.xxxCustomDomainxxx.xxx** is the default domain. Having this domain set as the default domain will come into play later in this course when you perform directory synchronization. <br>

	Therefore, if the **M365xZZZZZZ.onmicrosoft.com** domain is set as the default domain, select the vertical ellipsis icon that appears to the right of the **xxxUPNxxx.xxxCustomDomainxxx.xxx** domain and then select **Set as default** on the menu that appears. In the **Set this domain as default?** dialog box that appears, select the **Set as default** button. <br>

	Before you proceed, verify the **xxxUPNxxx.xxxCustomDomainxxx.xxx** custom domain is set as the Default domain. 

5. In the list of domains, note the **Status** of the custom domain, which is **Incomplete setup**. Select the **xxxUPNxxx.xxxCustomDomainxxx.xxx** domain, which opens the setup page for this domain.  

6. On the custom domain’s setup page, note that only one tab currently appears, which is the **Overview** tab. Once you finish provisioning this domain, a second tab titled **DNS records** will appear. You will see this tab towards the end of this task. <br>

	Select the **Continue setup** option on the menu bar at the top of the page. This will initiate the **Add domain** wizard. Since the custom domain has already been added, by selecting the **Continue setup** option the wizard will skip to the steps on connecting your domain. 

7. On the **How do you want to connect to your domain?** page, select **More options**. This displays two options - **Add your own DNS records**, and **Skip and do this later (not recommended)**. The **Add your own DNS records** option is selected by default. Select the **Continue** button, which opens the **Add DNS records** page.

8. The **Add DNS records** page identifies the services that an organization can implement in its Microsoft 365 deployment that require DNS records. Your lab hosting provider has taken on the role of a third-party registrar for Adatum. In doing so, it created in your lab environment each of the DNS records that are required for all the services on the **Add DNS records** page. The check box for the **Exchange and Exchange Online Protection** services should be selected by default (if not, select it now).   <br>
‎  
‎	Three DNS records are required to implement these Exchange services - an **MX** record, a **CNAME** record, and a **TXT** record. Select each record to expand it, and then note the information required for each record. 

9. At the bottom of the **Add DNS records** page select **Advanced Options**.

10. Two additional services are displayed under the **Advanced Options** section: **Skype for Business** and **Intune and Mobile Device Management for Microsoft 365**.  <br> 
‎  
‎	Select the check box for each of these two services. This will display the DNS records required for each service.

11. Note that four DNS records are required to implement **Skype for Business** - two **CNAME** records and two **SRV** records. Select each record type to expand it and then note the information required for each record. <br>

	**Important:** Even though Adatum is using Microsoft Teams for online communication services such as chat, conference calls, and video calls, you must still select the **Skype for Business** check box. The reason for this is that Teams requires the same two SRV records required by Skype for Business. Without these two SRV records, Adatum's users will not be able to make outbound calls from within Teams (or Skype for Business). Since your lab hosting provider created these SRV records, you want to select this **Skype for Business** check box so that the wizard validates the accuracy of these two SRV records that will be used by Microsoft Teams. 

12. Note that two CNAME records are required to implement **Intune and Mobile Device Management for Microsoft 365**. Select the **CNAME** record to expand it, and then note the information required. 

13. Select the **Continue** button at the bottom of the page. By selecting this button, the wizard will validate whether the DNS records were properly set up. 

14. If the DNS records were correctly set up by your lab hosting provider, the **Domain setup is complete** page should appear. Select **Done**.

15. You will be returned to the custom domain page, which will display the **Overview** tab. The **Domain status** should now display **Healthy**. <br>  

	‎Note how a second tab titled **DNS records** now appears next to the **Overview** tab on this page. Select the **DNS records** tab to review the DNS records that your lab hosting provider created.

16. You have now completed the setup of Adatum’s new vanity domain. However, as a best practice, there is one final step that you should perform. You should maintain a documented history of the DNS records that were created for Adatum by its domain registrar (your lab hosting provider) in the event you ever need to reference this information in the future.  <br> 
‎  
‎	To do so, on the **DNS records** tab, select the **Download CSV file** option. If a notification bar appears, select **Save**.  

17. On the taskbar at the bottom of your screen, select the **File Explorer** icon. 

18. In **File Explorer**, select the **Downloads** folder in the tree pane, and then double-click the **xxxUPNxxx.xxxCustomDomainxxx.xxx.csv** file that was just downloaded. Select **Notepad** to open the file. 

19. Review each of the records that were created for each DNS record type. 

20. Close Notepad and File Explorer.

21. Leave your web browser open along with the Microsoft Office Home tab and the Microsoft 365 admin center tab and proceed to the next lab exercise. 

**Results**: After completing this exercise, you should have successfully completed the setup process for Adatum's custom vanity domain.


## Exercise 3 - Exploring the Microsoft 365 administrator interfaces

Now that you have finished provisioning your Microsoft 365 tenant, you can begin using Microsoft 365. In this exercise, you will be guided through several of the more commonly used Microsoft 365 administrator interfaces to familiarize yourself with them. 

In the prior exercises, you accessed the Microsoft 365 admin center from the domain controller (LON-DC1) as you finished provisioning your Microsoft tenant and set up Adatum's custom domain. In this exercise, you will switch to the client PC on LON-CL1 to explore the Microsoft 365 administrator interfaces.

### Task 1 - Explore the Microsoft 365 admin center

While you have already been introduced to the Microsoft 365 admin center in the prior lab exercises, in this task you will examine some additional functionality within this portal. 

1. Switch to the **LON-CL1** client VM. 

2. Log into LON-CL1 as the **Administrator** with the password **Pa55w.rd**. 

3. If you receive a **Networks** warning message asking if you want this PC to be discoverable by other PCs and devices on this network, select **Yes.**

4. On the taskbar at the bottom of the page, select the **Microsoft Edge** icon. Maximize your browser window when it opens.

5. In your browser go to the **Microsoft 365 admin center** page by entering the following URL in the address bar: **https://admin.microsoft.com/** 

6. In the **Sign in** dialog box, copy and paste in (or enter) the username of the Microsoft 365 Tenant administrator account provided by your lab hosting provider (**admin@M365xZZZZZZ.onmicrosoft.com**, where ZZZZZZ is your unique tenant ID provided by your lab hosting provider) and then select **Next**.

7. In the **Enter password** dialog box, copy and paste in the **Tenant Password** provided by your lab hosting provider and then select **Sign in**.

8. On the **Stay signed in?** dialog box, select the **Don’t show this again** check box and then select **Yes.**

9. In Exercise 1, you already viewed the **Active Users** within the **Microsoft 365 admin center**. In this task, you will continue your exploration of Microsoft 365 clients by viewing the Microsoft 365 groups. In the left-hand navigation pane, select **Groups** and then select **Active groups**. This will display the two groups that were created by default for Adatum's Microsoft 365 tenant. 

10. In the left-hand navigation pane, select **...Show all** to display all the navigation menu options. 

11. In the left-hand navigation pane, expand **Health** and then select **Message center**.

12. In the **Message center** window, the **All active messages** tab is displayed by default. Review the messages. If you are interested in a particular message, select the message to open it. This will open a pane on the right side of the screen that displays the details associated with that message. When you are finished reviewing the message, select the X in the upper right corner of the pane to close it. Review as many messages as you would like.

13. Leave your Edge browser open as well as the Microsoft Office Home tab and the Microsoft 365 admin center tab. All remaining tasks in this exercise will use LON-CL1 and the Microsoft 365 admin center.  

### Task 2 - Explore the Exchange admin center

1. After completing the prior task, you should still be in **LON-CL1** and logged into the **Microsoft 365 admin center**. In the left-hand navigation pane, under the **Admin centers** group, select **Exchange**. A new tab will open displaying the **Exchange admin center**.

2. In the **Exchange admin center**, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs (where applicable) that are displayed at the top of the page for each item.

3. When you have finished exploring the Exchange admin center, close its tab in the Edge browser (leave all other tabs open).

### Task 3 - Explore the Teams admin center

1. After completing the prior task, you should still be in **LON-CL1** and logged into the **Microsoft 365 admin center**. In the left-hand navigation pane, under the **Admin centers** group, select **Teams**. A new tab will open displaying the **Teams admin center**.

2. In the **Teams admin center**, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs (where applicable) that are displayed at the top of the page for each item.

3. When you have finished exploring the Teams admin center, close its tab in the Edge browser (leave all other tabs open).

### Task 4 - Explore the SharePoint admin center

1. After completing the prior task, you should still be in **LON-CL1** and logged into the **Microsoft 365 admin center**. In the left-hand navigation pane, under the **Admin centers** group, select **SharePoint**. A new tab will open displaying the **SharePoint admin center**.

2. In the **SharePoint admin center**, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs (where applicable) that are displayed at the top of the page for each item.

3. When you have finished exploring the SharePoint admin center, close its tab in the Edge browser (leave all other tabs open).

### Task 5 - Explore the Microsoft 365 Security admin center 

1. After completing the prior task, you should still be in **LON-CL1** and logged into the **Microsoft 365 admin center**. In the left-hand navigation pane, under the **Admin centers** group, select **Security**. A new tab will open displaying **Office 365 Security & Compliance center**.

2. In the **Office 365 Security & Compliance center** tab, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs that are displayed at the top of the page for each item.

3. In the **Office 365 Security & Compliance center** tab, note the banner at the top of the page that indicates Microsoft 365 Security and Compliance functionality has been split into separate admin centers - a Microsoft 365 Security center and a Microsoft 365 Compliance center.<br>

	In the banner, select the link to the **Microsoft 365 security center**. **Note** this is the first link in the first sentence. 

4. In **Microsoft 365 Defender** tab, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs (where applicable) that are displayed at the top of the page for each item.

5. When you have finished exploring Microsoft 365 Defender, close its tab in the Edge browser (leave all other tabs open).

### Task 6 - Explore the Microsoft 365 Compliance admin center 

1. After completing the prior task, you should still be in **LON-CL1** and logged into the **Microsoft 365 admin center**. In the left-hand navigation pane, under the **Admin centers** group, select **Compliance**. A new tab will open displaying the **Microsoft 365 compliance center**.

2. In the **Microsoft 365 compliance center**, take turns selecting each of the items in the left-hand navigation pane. Review the information that is displayed for each item. Navigate through the available tabs (where applicable) that are displayed at the top of the page for each item.<br>

	**Note:** If you will recall, in the prior task when you selected **Security**, the **Security and Compliance Center** displayed a banner indicating that security and compliance had been split apart. If you had selected the link in the banner to the **Microsoft 365 Compliance center**, it would have displayed this same **Microsoft 365 compliance center** that you navigated to from the Microsoft 365 admin center. 


3. When you have finished exploring the Microsoft 365 Compliance center, close its tab in the Edge browser (leave all other tabs open).

4. At this point, you should just have the **Microsoft 365 admin center** tab open in your Edge browser. Leave this tab open in the browser as it will be used in the next lab.



# End of Lab 1




