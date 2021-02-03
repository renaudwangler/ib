# Module 1 - Lab 2: Key Vault (Implementing Secure Data by setting up Always Encrypted)

**Scenario**
In this lab, you will have a VM looking in a Key Vault for the credentials needed to access a Storage Account. The VM won't need to authenticate to the Key vault, by using a Managed Identity.

This lab includes the following tasks:

 - Create a Windows VM
 - Create a storage Account
 - Create an Azure Key Vault
 - Access the Storage Account content from the VM

## Exercise 1: Provision the lab environment

### Task 1: Provision a Windows Virtual Machine
1. In the Azure portal home (http://portal.azure.com) click **+ Create a resource**
1. In the **New** window, select **Compute** and **Virtual Machine**.
1. In the **Create a virtual machine** window, use the following parameters in the **Basics** tab
  - **Resource Group:** click **Create new** and use **DemoRG** for its name.
  - **Virtual machine name:** **DemoVM**
  - **Region:** An Azure region near you
  - **Availability options:** No insfrastructure redondancy required
  - **Image:** Windows Server 2019 Datacenter - Gen1
  - **Azure Spot intance:** Unchecked
  - **Size:** Leave the default size
  - **Administrator account - Username:** type **Student**
  - **Administrator account - Password:** type **ibForm@tion2021**
  - **Public Inbound ports:** **Allow selected ports** and select **RDP (3389)**
  - **Licensing:** Leave the box unchecked
4. Switch to the **Management** tab and select the **System Assigned managed identity** checkbox (leave all other values to their default)
1. Click on **Review + create**
1. In the **Create a virtual machine** window, once the *Validation passed* message appears, click **Create**

**Note:** You do not need to wait for VM to provision before continuing.

### Task 2: Provision a Storage account
1. Back in the Azure portal home click **+ Create a resource**
1. In the **New** window, select **Storage account**.
1. In the **Create storage account** window, use the following parameters and click **Review + create**
  - **Resource Group:** select **DemoRG**.
  - **storage account name:** **demosaXXX**, replace XXX with a globally unique string made of lowercase letters
  - **Region:** The same as the VM
  - **Performance:** **Standard**
  - **Account kind:** **StandardV2**
  - **Replication:** **Localy-redundant storage**
4. In the **Create storage account** window, once the *Validation passed* message appears, click **Create**
1. Once the storage account is created, click on **Go to resource**
1. On the storage Account page, click on **File Service/File shares**
1. On the **File share settings** page, click on **+ File share** button
1. On the **New file share** pane, type **demoshare** in the **Name** field and click on the **Create** button.
1. On the storage Account page, click on **Settings/Access keys*
1. Click on the **Show keys** button and copy the value of the **key1** field (you may use the copy button at the end of the field)

### Task 3: Provision a Key vault
1. Back in the Azure portal home click **+ Create a resource**
1. In the **New** window, type **Key** in the **Search the marketplace** field and select **Key Vault*.
1. In the **Key Vault** page, click **create**.
1. In the **Create key vault** window, use the following parameters and click **Review + create**
  - **Resource Group:** select **DemoRG**.
  - **Key vault name:** **demoKVXXX**, replace XXX with a globally unique string
  - **Region:** The same as the VM
  - **Pricing tier:** **Standard**
  - **Days to retain deleted vaults:** **7**
  - **Purge protection:** **Disable purge protection**
4. In the **Create key vault** window, once the *Validation passed* message appears, click **Create**
1. Once the key vault is created, click on **Go to resource**

### Task 4: Add a secret to Key Vault
1. In the key vault page, click on **Settings/Secrets**
1. click on the **+ Generate/import** button
1. Use the following values and click on the **Create** button
  - **Upload options:** **Manual**
  - **Name:** **sakey**
  - **Value:** Paste the key value you copied in task 2
  - leave all other values to their default
    
    ```powershell
    $subscriptionName = '[Azure_Subscription_Name]'
    $applicationId = '[Azure_AD_Application_ID]'
    $resourceGroupName = '[Resource_Group_with_KeyVault]'
    $location = '[Azure_Region_of_KeyVault]'
    $vaultName = '[KeyVault_Name]' 
    ```
    
    ```powershell
    Login-AzAccount
    ```
    
    ```powershell
    Set-AZKeyVaultAccessPolicy -VaultName $vaultName -ResourceGroupName $resourceGroupName -ServicePrincipalName $applicationId -PermissionsToKeys get,wrapKey,unwrapKey,sign,verify,list
    ```

**Results** : You have now completed this Lab.

