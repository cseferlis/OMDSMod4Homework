# Week 10.1 Tutorial - Data Lakes and the ADLS Gen2 Upgrade

**Welcome to Week 10!**

For the next three weeks you will build the second half of a modern analytics stack. The pattern is different from Weeks 1–5, and the difference is worth understanding before you touch anything.

In Week 4 you did **ETL**: extract, transform, then load into a database that owns the data. Everything you query has been copied into SQL Server first.

Now you will do **ELT**, or more precisely **data virtualisation**. The data stays in storage as files. A query engine reads those files directly, in place, with no loading step at all. This is how large-scale analytics is actually done, because at a certain volume copying everything into a database stops being practical.

Two things have to be true before that works: the storage account has to behave like a filesystem, and the files have to be in a format built for analytics. This tutorial handles both.

> **NOTE** - this tutorial builds on the Azure environment from Weeks 1–4. You will use the same `Resource Group`, `Storage Account`, and `Data Factory`.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Introduction to Azure Data Lake Storage Gen2](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)
- [Upgrade Azure Blob Storage with Azure Data Lake Storage Gen2 capabilities](https://learn.microsoft.com/en-us/azure/storage/blobs/upgrade-to-data-lake-storage-gen2-how-to)
- [What is Parquet?](https://www.databricks.com/glossary/what-is-parquet)
- [PolyBase and data virtualisation](https://learn.microsoft.com/en-us/sql/relational-databases/polybase/polybase-guide?view=sql-server-ver16)

## The shortcoming of Blob Storage vs. Data Lake

Your storage account currently uses a **flat namespace**. Despite what the portal shows you, there are no real folders — a blob named `extracted/file.txt` is a single object whose name happens to contain a slash. The folder structure is a display convention.

That is fine for storing files. It is a problem for analytics engines, which need to do things like "list everything under this directory" and "rename this folder" efficiently, and which need per-directory permissions.

**Azure Data Lake Storage Gen2** adds a **hierarchical namespace** on top of blob storage. Directories become real objects. Renaming one becomes a single atomic operation instead of copying every file inside it. Permissions can be set per directory. Analytics services like Synapse and Databricks expect this.

The upgrade is **one-way**. You cannot revert a storage account to a flat namespace once it is done.

## Why Parquet

Your NHTSA data is currently a tab-delimited text file. Parquet is a **columnar** format, and the difference matters:

- A text file stores row by row. Reading one column means reading every row in full.
- Parquet stores column by column. Reading one column means reading only that column's data.

Because a column holds values of one type, Parquet also compresses far better than text, and it carries its own schema — column names and types travel with the file, so no external reference document is needed to interpret it.

For a query like "count crashes per year," a columnar format reads two columns instead of forty. That is the entire basis of analytics-scale query performance.

## Steps to Complete Tutorial 10.1

### Step 1: Check whether your account needs upgrading

1. In the portal, open your **Storage Account**.
2. Go to **Settings** > **Configuration**.
3. Look for **Hierarchical namespace**. If it already says Enabled, skip to Step 4.

<!-- SCREENSHOT: Storage account Configuration blade showing the Hierarchical namespace setting -->

### Step 2: Clear the blockers

The upgrade validation fails if certain features are switched on. Deal with them first.

1. Go to **Data management** > **Data protection**.
2. Uncheck every retention policy that is enabled — in particular **Enable container soft delete** and **Enable blob soft delete**.
3. Click **Save**.

<!-- SCREENSHOT: Data protection blade with soft delete options unchecked -->

> **NOTE** - The most common upgrade error mentions `containerDeleteRetentionPolicy`. That is the container soft delete setting above. Clearing it and retrying resolves it.

### Step 3: Run the upgrade

1. Go to **Settings** > **Data Lake Gen2 upgrade**.
2. Read the notice, then click **Review and agree to changes** and accept.
3. Click **Start validation**. Azure checks for anything incompatible.
4. When validation passes, click **Start upgrade**.

<!-- SCREENSHOT: Data Lake Gen2 upgrade blade after successful validation -->

The upgrade takes a few minutes. When it completes, return to **Configuration** and confirm **Hierarchical namespace** is Enabled.

> **NOTE** - This is irreversible. It is also safe for everything you have built — your existing containers and files are preserved, and the blob endpoints your Data Factory pipelines use continue to work unchanged.

### Step 4: Confirm your existing data survived

1. Go to **Data storage** > **Containers**.
2. Open `tutorial-data` and confirm your extracted `.txt` file is still there.
3. Note that the interface now shows **Directories** as real objects rather than name prefixes.

<!-- SCREENSHOT: Container browser after the upgrade showing directories -->

### Step 5: Create a container for Parquet output

Keep the columnar output separate from the raw text.

1. Click **+ Container**.
2. Name it `parquet-data`.
3. Click **Create**.

<!-- SCREENSHOT: Containers list showing tutorial-data, assignment-data, and parquet-data -->

## Point to Consider 🤔

- The hierarchical namespace makes renaming a directory a single operation instead of a copy of every file inside it. Why would that matter enormously to a query engine and not at all to a photo backup service?
- Parquet carries its own schema, while your `.txt` file needed an external reference document. What class of error does that eliminate?
- You are about to query files in storage directly rather than loading them into a database. What do you give up by doing that?

---

Ensure you understand each step and reach out with any questions!
