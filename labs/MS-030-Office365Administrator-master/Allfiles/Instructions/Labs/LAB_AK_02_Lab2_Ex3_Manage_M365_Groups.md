# Module 2 - Lab 2 - Exercise 3 - Managing Microsoft 365 groups

Earlier in this lab, you added several new Microsoft 365 user accounts. As you continue in your role as Holly Dickson, Adatum's Enterprise Admin, you now want to investigate implementing Microsoft 365 groups. In this exercise, you will create two new Microsoft 365 groups and then manage the groups by assigning users to them. You will also analyze the effect on group members when you delete a group.

### Task 1: Creating Microsoft 365 groups

In your role as Holly Dickson, you now want to implement Microsoft 365 groups as part of your pilot project. In this task, you will add two Sales-related groups and a group for Accounts Receivable users. You will then delete one of the Sales groups and verify that deleting a group does not delete the user accounts that were members of the group.

1. You should still be logged into the **LON-CL1** VM as the **Administrator** account with a password of **Pa55w.rd**.

2. The **Microsoft 365 admin center** should still be open in the Edge browser from the prior exercise, and you should be signed into Microsoft 365 as **Holly Dickson** (Holly@M365xZZZZZZ.onmicrosoft.com). In the **Microsoft 365 admin center**, expand **Groups** in the navigation pane on the left, and then under it, select **Active Groups**. 

3. In the **Active Groups** window, select **Add a group** on the menu bar at the top of the page.

4. In the **Choose a group type** pane that appears, the **Microsoft 365** group type is selected by default. Accept this value by selecting **Next**.

5. In the **Set up the basics** window, enter **Inside Sales** in the **Name** field and **Collaboration group for the Inside Sales team** in the **Description field** and then select **Next** (if you leave the **Description** field blank, you must still select it to enable the **Next** button).

6. In the **Assign owners** window, select **+ Assign owners**, which displays the list of active users. Select **Alan Yoo**, then select **Add (1)** and then select **Next**. 

7. In the **Add members** window, select **Next**.

8. In the **Edit settings** window, enter **insidesales** in the **Group email address** field. <br/>
	
		**Note:** To the right of the **Group email address** field is the domain field. It’s already prefilled with the **xxxUPNxxx.xxxCustomDomainxxx.xxx** domain, which is set as Adatum's Default domain. This is different from adding users in that no other domains appear; therefore, you must leave this value as is.   <br/>
		
		After configuring this field, the Inside Sales group email address should appear as: **insidesales@xxxUPNxxx.xxxCustomDomainxxx.xxx** <br>

		After configuring the email address, under the **Privacy** section, leave the default setting of **Public** and leave the check box selected to **Create a team for this group**. However, to enable the **Next** button, you must select the **Public** option. Select **Next**.

9. On the **Review and finish adding group** window, review the information and if anything needs to be changed, select the appropriate **Edit** option; otherwise, select the **Create group** button at the bottom of the page.


10. On the **New group created** window, the message that appears at the top of the page that indicates it may take up to 5 minutes before the group appears in the list of active groups.
	Since you will adding additional groups, under the **Next step** section towards the bottom of the page select **Add another group**. If you already closed this window, then from the **Active groups** page, select **Add a group**.

11. Repeat steps 4-9 to add another group with the following information (this time select **Close** once the group is added and not the **Add another group** option):

	- Type: **Security**
	
	- Name: **Sales**

	- Description: **Sales Department users**
	
	**Note:** There is no email address, or privacy setting for Security groups

12. In the **Active groups** window, if both new groups do not appear in the list, select **Refresh** on the menu bar above the list. Both groups should now appear (you may have to wait a few minutes and then Refresh again). 

13. You’re now ready to add members to the groups. In the list of **Active groups**, select the **Inside Sales** group, which opens a window for the group. 

14. In the **Inside Sales** window, the **General** tab is displayed by default. Select the **Members** tab.

15. In the **Members** tab, you can see that there are zero (0) members. Select **View all and manage members** to add members to the group. 

16. In the **Inside Sales** group window, select **+Add members**. This displays the list of active users.

17. In the list of users, select **Ada Russell** and **Alan Yoo** and then select **Add (2)**. 

18. Select the **X** in the upper right-hand corner to close the window.

19. In the **Active groups** window, select **Add a group** on the menu bar and then add a new group with the following information:

	- Type: **Security**

	- Name: **Accounts Receivable**

	- Description: **Accounts Receivable department users** 

20. If the Accounts Receivable group does not appear in the **Active groups** list, select **Refresh** on the menu bar (you may need to wait a few minutes and then Refresh again). The group should now appear.

21. In the **Active groups** list, select the **Accounts Receivable** group, which opens a window for the group. 

22. In the **Accounts Receivable** group window, select the **Members** tab.

23. In the **Members** tab, you can see that there are zero (0) group owners and members. Select **View all and manage owners** to add an owner for the group.

24. In the **Accounts Receivable** group window, select **+Add owners**. This displays the list of active users.

25. In the list of users, select **Libby Hayward** and then select **Add (1)**. 

26. Select the **<-** in the upper left-hand corner of the window to go back to the **Accounts Receivable** window.

27. In the **Accounts Receivable** group window, select **+Add owners**. This displays the list of current users.

28. In the list of users, select **Libby Hayward** and then select **Save**. 

29. Select **Close**. This displays the list of owners for this group. Select **Close** again. 

28. In the **Members** tab of the **Accounts Receivable** window, select **View all and manage members** to add members to the group. 

29. In the **Accounts Receivable** window, select **+Add members**. This displays the list of active users.

30. In the list of users, select **Adam Hobbs** and **Libby Hayward** and then select **Add (2)**. 

31. Select the X in the upper right-hand corner to close the window. This will return you to the list of **Active groups**. 

32. You now want to test the effect of deleting a group. In the list of **Active groups,** select the vertical ellipsis icon (**More actions**) to the right of the **Inside Sales** group. In the menu box, select **Delete group**. 

33. In the **Delete Inside Sales?** window, select the **Delete group** button.

34. On the **Inside Sales was deleted** window, select **Close**. 

35. This will return you to the list of **Active groups** in the **Microsoft 365 admin center**. The **Inside Sales** group should no longer appear. 

36. To verify whether deleting this group affected any of its members, in the left-hand navigation pane of the **Microsoft 365 admin center**, expand **Users** and then **Active Users**. 

37. In the list of **Active** **Users** verify that the two members of this group, **Ada Russell** and **Alan Yoo**, still appear in the list of users. This verifies that deleting a group does not delete the user accounts that were members of the group.

38. Leave your browser and all tabs open and proceed to the next lab exercise.

**Results**: After completing this exercise, you should have created and managed Microsoft 365 groups and security groups.
