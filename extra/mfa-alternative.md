# Lab: Setup Multifactor Authentication with APP on Windows

**Scenario**
In this lab, you will use an application on a Windows 10/11 workstation to setup multifactor authentication. This setup could be used to authenticate in a m365 or Azure AD environment.

This lab includes the following tasks:

 - Enable MFA for a user
 - Disable  MFA for the user

## Exercise 1: Enable MFA for a user

### Task 1: Install a Windows 10/11 Store Application
1. On a test/lab windows system, I advise to *clean* the Microsoft store.
1. Click on the Windows 10/11 **Start** button and type **"store"**
1. Click on the **"Microsoft Store"** shortcut
---
**Note :** The Windows Update service must be enabled and running to use the Microsoft Store.

---
4. Click on the **Sign in** button (at top of the Microsoft Store app, with a user picture) and click **Sign in**
1. Enter the username to logon to the Microsoft Store with the user you want to setup (any Microsoft account would do the job) and click **Next**.
1. Enter the user's password and click **Sign in**.
1. On the **"Use this account everywhere on your device"**, click **Microsoft apps only**.
1. Click on the **"Search apps, games, movies and more"** field and type **2fast**.
1. Click on the **"2fast - Two factor authentictior[...]"** link.
1. Click on the **Install** button.
1. Wait for the App to Install before proceding.
1. On the **Microsoft Store** app, on the **"2 fast - Two factor[...]"** page, click on the **Open** button.
1. On the **Welcome** page, click on the **Create new datafile** button.
1. On the **Create datafile** window, click on the **Choose local path** button.
1. On the **Select Folder** window, slect any folder you want to store the app config into (for instance the *Documents* folder) and click the **Select Folder** button.
1. Back on the **Create datafile** window, type any value for the **Filename** and the two **Password** fields and click on the **Create datafile** button.


### Task 2: Enable MFA for a user account
1. Launch your favorite Internet browser and log into either 365 or Azure portal wiht the user account you want to enable MFA for
1. On the portal webpage, click on the account information (picture/logo in the top-right corner) and click on the **View account** link.
---
**Note :** The user may access directly the **My Account** webpage by going to the **https://myaccount.microsoft.com** url.

---
3. Click on the **Security info** link.
1. On the **Security info** page, click on the **+ Add method** button.
1. On the **Add a method** window, select **"Authenticator app"** and clcik on the **Add** button.
1. On the **Microsoft Authenticator** window, click on the **I want to use a different authenticator app** link.
1. On the **Auhtenticator app** window, click on the **Next** button.
1. On the **Scan QR code** page, click on the **Can't scan image?** button.
1. Copy the "Account name" value in your clipboard.
1. Switch back to the **2fast** app window.
1. On the **Accounts** page, click on the *Add* **+** button on top.
1. On the **Input type** page, click on the **Manual key entry** button.
1. On the **Inputs** page, choose any label and ensure the **Manual key input** checkbox is selected.
1. Paste the account name in the **Account name** field (remove any character before the real user logon name).
1. Switch back to your Internet browser and copy the **Secret key** value to your clipboard.
1. Switch back to the **2fast** app window and paste the secret key in the **Secret key** field.
1. Click on the **Create account** button.
1. Copy the 6 digits code showed in the **2fast** app.
1. Switch back to your Internet browser and click on the **Next** button.
1. On the **Enter code** page, paste the 6 digits code and click **Next** (if the code/session is out of date, repeat the 2 previous steps).

**Results** : You may now use the **2fast** app to generate 6 digit codes to login with the user you just setup.

## Exercise 2: Disable MFA for the user

### Task 1: Install a Windows 10/11 Store Application
1. Launch your favorite Internet browser and log into either 365 or Azure portal wiht the user account you want to enable MFA for
1. On the portal webpage, click on the account information (picture/logo in the top-right corner) and click on the **View account** link.
---
**Note :** The user may access directly the **My Account** webpage by going to the *https://myaccount.microsoft.com** url.

---
3. Click on the **Security info** link.
4. If needed use the 6 digits code from the **2fast** app to verify your MFA logon.
5. On the **Security info** page, click on the **Delete** link on the line matching the **"Authenticator app"**
6. Confirm your choice by clicking on the **Ok** button.
---
**Note :** Since we are on a test/lab environment, there is no readon to delete the account information in the **2fast** application...

---

**Results** : You have now removed the MFA information form the user account.
