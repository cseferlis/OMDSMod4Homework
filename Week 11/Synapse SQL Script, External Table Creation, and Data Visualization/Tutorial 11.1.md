# Week 11.1 Tutorial - Creating an Azure Synapse Workspace

**Class,**

You have Parquet files sitting in a data lake. Nothing can query them yet.

**Azure Synapse Analytics** is Microsoft's analytics platform, and the part you will use is its **serverless SQL pool**. It runs on a Massively Parallel Processing (MPP) engine: a query is split across many nodes, each handling a slice of the data, with results combined at the end. That is what makes querying files at scale feasible.

The word *serverless* matters. There is no database to provision and no compute running when you are idle. You are billed **per terabyte of data processed by your queries**, not per hour. For the volumes in this course that is a very small number — but it also means a careless query that scans everything costs more than a targeted one.

> **NOTE** - this tutorial builds on Week 10. Your storage account must have the hierarchical namespace enabled and contain the Parquet files from Tutorial 10.2.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Create a Synapse workspace](https://learn.microsoft.com/en-us/azure/synapse-analytics/get-started-create-workspace)
- [Serverless SQL pool in Azure Synapse Analytics](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/on-demand-workspace-overview)
- [Access control lists in Azure Data Lake Storage Gen2](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-acl-azure-portal)
- [Synapse workspace access control](https://learn.microsoft.com/en-us/azure/synapse-analytics/security/synapse-workspace-access-control-overview)

## Two pools, one of which you will not use

A Synapse workspace offers two SQL compute models, and picking the wrong one is expensive:

**Serverless SQL pool** (named `Built-in`) — always available, no provisioning, billed per TB scanned. **This is what you will use.**

**Dedicated SQL pool** — a reserved data warehouse billed per hour while running, starting at a rate that would consume your entire course credit in a matter of days. **Do not create one.** If you accidentally do, pause or delete it immediately.

## Steps to Complete Tutorial 11.1

### Step 1: Create the workspace

1. In the portal, open your **Resource Group** and click **Create**.
2. Search for **Azure Synapse Analytics** and select it.
3. Fill in the **Basics** tab as follows:

   - **Resource group**: the one you have used all semester
   - **Workspace name**: something identifiable, such as `<initials>mod4synapse` (globally unique)
   - **Region**: the same region as your storage account

4. Under **Select Data Lake Storage Gen2**:

   - **Account name**: choose **From subscription** and select your existing storage account
   - **File system name**: create a new one, or select an existing container

5. Leave the **Security** tab at its defaults unless you have a reason to change it. Note the SQL administrator credentials shown.
6. Click **Review + Create**, then **Create**. Provisioning takes several minutes.

<!-- SCREENSHOT: Synapse workspace creation Basics tab with storage account selected -->

> **NOTE** - The tutorial linked in Microsoft's documentation offers to load a sample dataset. **Do not use it.** You have your own data and the sample adds storage cost for no benefit.

> **NOTE** - The **file system** Synapse asks for is its own working area for logs and temporary output. It does not need to be the container holding your Parquet files — you will connect to those separately in Step 4.

### Step 2: Give yourself Synapse Administrator rights

Creating the workspace does not automatically grant you everything inside it.

1. Open your **Synapse workspace** in the portal and click **Open Synapse Studio**.
2. In Synapse Studio, click **Manage** (toolbox icon) > **Access control**.
3. Confirm you hold the **Synapse Administrator** role. If not, click **+ Add** and assign it to yourself.

<!-- SCREENSHOT: Synapse Studio Manage > Access control showing the Synapse Administrator assignment -->

> **NOTE** - Permissions may already be configured correctly. Check before changing anything.

### Step 3: Set storage permissions

Synapse reading files from your storage account is a *separate* permission from your rights inside Synapse. Both must be right, and confusing the two is the most common source of "why can I not see my data" in this and the next tutorial.

1. In the portal, open your **Storage Account** > **Containers** > `parquet-data`.
2. Click **Manage ACL** (right-click the container or use the toolbar).
3. Confirm your account has **Read**, **Write**, and **Execute** permissions.
4. Check the **Default permissions** tab as well, which governs newly created files.

<!-- SCREENSHOT: Manage ACL panel showing Read, Write, Execute checked -->

> **NOTE** - ADLS Gen2 has two overlapping permission systems: Azure RBAC roles at the account level, and POSIX-style ACLs at the directory and file level. A user can hold an RBAC role and still be blocked by an ACL, or the reverse. When access behaves inexplicably, check both.

### Step 4: Connect Synapse to your Parquet files

1. In **Synapse Studio**, click **Data** (database icon) in the left rail.
2. Select the **Linked** tab.
3. If your storage account is not listed, click **+** > **Connect to external data** > **Azure Data Lake Storage Gen2**, and select your account from the subscription.

   <!-- SCREENSHOT: Synapse Studio Data hub, Linked tab, showing the connected storage account -->

4. Expand the account and browse to the `parquet-data` container. You should see the `.parquet` files from Tutorial 10.2.

<!-- SCREENSHOT: Synapse Data hub browsing into parquet-data showing manufacturer-named files -->

If the files are not visible, work through in this order: is the storage account linked at all (Step 4), do you hold Synapse Administrator (Step 2), and are the ACLs set (Step 3).

### Step 5: Look at a file without writing any SQL

1. Right-click any `.parquet` file and choose **Preview**.

<!-- SCREENSHOT: Parquet file preview showing rows with named columns -->

Note that the column names are the ones you set in Tutorial 10.2 Step 4. Synapse did not need a reference document, a delimiter setting, or a schema definition — the Parquet file carried all of that with it. Compare that to what Week 4 required to read the same data as text.

## Point to Consider 🤔

- Serverless SQL bills per terabyte scanned rather than per hour running. What does that reward, and what does it punish?
- You needed permissions in two separate systems for one query to work. Why would a cloud platform separate "what you can do in the analytics tool" from "what you can read in storage"?
- Synapse read your Parquet files without being told their schema. What made that possible, and what would you have had to supply if they were still `.txt`?

---

Ensure you understand each step and reach out with any questions!
