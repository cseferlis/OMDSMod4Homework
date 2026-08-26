# Week 4.1 Tutorial - Deploying an Azure SQL Database & Server

**Class,**

In Weeks 2 and 3 you built a Data Factory and used it to pull a compressed file off a public web server, land it in blob storage, and unzip it into a `.txt`. That covers the `Extract` and `Load` portions of an `ETL (Extract, Transform, Load)` pipeline. What you have now is a large text file sitting in a container — readable, but not queryable.

This week you will give that data somewhere structured to live. An **Azure SQL Database** lets you define a table with typed columns, load the text file into it, and then ask questions of the data with SQL. This tutorial deploys the database and the server that hosts it.

> **NOTE** - this tutorial builds on your activities in the previous weeks. You should be using the same `Resource Group`, `Storage Account`, and `Data Factory` from the previous tutorials. If you have not completed Week 3, do that first.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Create a single database in Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart?view=azuresql&tabs=azure-portal)
- [Azure SQL Database server-level firewall rules](https://learn.microsoft.com/en-us/azure/azure-sql/database/firewall-configure?view=azuresql)
- [Azure SQL Database service tiers](https://learn.microsoft.com/en-us/azure/azure-sql/database/service-tiers-sql-database-vcore?view=azuresql)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)

## Server vs. Database

These are two different things and the distinction matters when you start clicking around the portal.

**The logical server** (`Microsoft.Sql/servers`) is the front door. It owns the hostname you connect to — something like `<yourserver>.database.windows.net` — along with the administrator login and the firewall rules that decide who is allowed to reach it. It holds no data itself.

**The database** (`Microsoft.Sql/servers/databases`) sits inside that server and holds your tables. This is also where the cost lives: you pay for the database's compute tier, not for the server.

One server can host several databases. You will create one of each.

## Steps to Complete Tutorial 4.1

### Step 1: Deploy the server and database

As in Week 2, use the deployment script and template rather than clicking through the portal.

1. Open **Cloud Shell** from the Azure Portal and navigate into the Week 4 tutorial folder.
2. Run the following command to generate your parameters file:

   ```azurecli-interactive
   bash ./formTemplate.sh
   ```

   This generates a random six-character string and builds a unique server name and database name from it, then writes both into `./template/parameters.json`. Server names must be globally unique, which is why they are randomized.

3. Run the following command to deploy, replacing `<resource-group-name>` with the Resource Group you have been using all semester:

```azurecli-interactive
az deployment group create --resource-group <resource-group-name> --template-file ./template/template.json --parameters ./template/parameters.json
```

   Deployment typically takes **5–10 minutes** — considerably longer than the Data Factory in Week 2. This is normal.

<!-- SCREENSHOT: Cloud Shell showing the SQL deployment succeeded -->

> **NOTE** - SQL Server credentials are set by the template:
> - **Login**: `omdsmod4admin`
> - **Password**: `omdsmod4password013!`
>
> These are shared course credentials, not secrets. In any real deployment, a password would never be committed to a repository — it would come from a key vault or be prompted for at deploy time. Worth noting the difference between what is convenient for a class and what is acceptable in practice.

If you see the "content for this response was already consumed" error, run the following command and then retry the deployment:

```azurecli-interactive
az account set --subscription "Azure for Students"
```

### Step 2: Deploying manually, if the template fails

Region and capacity errors are the most common failure here — SKUs are not available in every region for every subscription. If the deployment will not succeed, create the resources by hand in the portal:

1. Navigate to your **Resource Group** and click **Create** > **SQL Database**.
2. Fill in the **Basics** tab as follows:

   - **Resource Group**: the one you have been using since Week 1
   - **Database name**: `<initials>mod4db`
   - **Server**: click **Create new**
     - **Server name**: `<initials>mod4server` (must be globally unique — add digits if taken)
     - **Location**: the same region as your Resource Group
     - **Authentication method**: use both SQL and Microsoft Entra authentication
     - **Server admin login**: `omdsmod4admin`
     - **Password**: `omdsmod4password013!`
     - Set yourself as the Entra admin
   - **Want to use SQL elastic pool?**: **No**
   - **Workload environment**: **Development**
   - **Compute + storage**: click **Configure database** and choose **General Purpose — Serverless**
   - **Backup storage redundancy**: **Locally-redundant backup storage**
3. Navigate over to **Additional Settings**:
   
   - Under **Data Source**, click **Sample.**
   - A prompt will show appear specifying **AdventureWorksLT** as the sample database. Click **OK.**
This gives your SQL database the sample data that you need to fanmiliarize yourself with the query editor in Tutorial 4.2.

<img width="732" height="464" alt="image" src="https://github.com/user-attachments/assets/4cd33d17-d2df-4554-a764-5290657ddff5" />

4. Click **Review + Create**, then **Create**. Allow 5–10 minutes.

> **NOTE** - The template deploys a **Standard S0** database, while these manual instructions specify **General Purpose — Serverless**. Serverless pauses when idle and is usually the cheaper of the two for coursework, since your database sits unused most of the week. Either will complete the assignment. If you deploy manually, prefer serverless.

<!-- SCREENSHOT: SQL Database creation Basics tab with server settings expanded -->

### Step 3: Open the firewall

A freshly created SQL server rejects every connection. Two separate permissions need granting, and skipping either one produces errors in Tutorial 4.2 that look like the database is broken, even though it isn't.

1. In the portal, open your **SQL server** resource (not the database).
2. Go to **Security** > **Networking**.
3. Under **Public network access**, ensure **Selected networks** is chosen.
4. Under **Firewall rules**, click **+ Add your client IPv4 address**. This lets *you* connect from your own machine.
5. Under **Exceptions**, check **Allow Azure services and resources to access this server**. This lets *Data Factory* connect in Tutorial 4.3.
6. Click **Save**.

<img width="966" height="648" alt="image" src="https://github.com/user-attachments/assets/ab8bf913-889a-4496-8051-f24e814c1c07" />

> **NOTE** - Your client IP is not permanent. If you move between home and campus, switch to a different Wi-Fi network, or connect through a VPN, your address changes and you will be locked out again. When Tutorial 4.2 refuses to connect and it worked yesterday, come back here and add your new address first. This is the single most common source of confusion in Week 4.

### Step 4: Confirm the database exists

1. Navigate to your **Resource Group**. You should now see a **SQL server** and a **SQL database** alongside your storage account and data factory.
2. Click the **SQL database**. On the overview page, note the **Server name** — the full `*.database.windows.net` hostname. You will need it in Tutorial 4.3.

<!-- SCREENSHOT: Resource Group showing storage account, data factory, SQL server, and SQL database -->

> **NOTE** - The deployment template also seeds your database with Microsoft's **AdventureWorksLT** sample dataset, so it will not be empty. Those `SalesLT.*` tables are not part of your assignment and can be ignored — though they are genuinely useful for practising queries, which is exactly what you will do in Tutorial 4.2.

### Extra Step: Understand what this is costing you

A database bills continuously from the moment it is created, whether or not you query it. This is different from the storage account and Data Factory, which are close to free at your usage level.

1. Open your **SQL database** and go to **Settings** > **Compute + storage** to see your current tier.
2. Search for **Cost Management** in the portal and open **Cost analysis** on your subscription to see spend accumulating.

Leaving a database running for the rest of the semester will consume a meaningful share of your $100 credit. Keep an eye on it.

## Point to Consider 🤔

- Why does Azure separate the logical server from the database, when the database is the only part that holds your data?
- The firewall needs two different permissions — one for your IP and one for Azure services. What would happen if you granted only the first, then tried to run a Data Factory pipeline against the database?

---

Ensure you understand each step and reach out with any questions!
