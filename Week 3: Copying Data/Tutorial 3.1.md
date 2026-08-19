# Week 3.1 Tutorial - Connecting Other Azure Services to Data Factory

**Class,**

In Week 2 you deployed a Data Factory and learned your way around the Studio. It still cannot touch a single byte of data, because it has no idea where any data lives. This tutorial fixes that by creating the two `Linked Services` and the two `Datasets` that Tutorial 3.2 will use to actually move a file.

The dataset we will work with in these tutorials is the NHTSA **Recalls** file.

> **NOTE** - this tutorial builds on Weeks 1 and 2. You should be using the same `Resource Group`, `Storage Account`, and `Data Factory` from the previous tutorials. If you need further assistance, please reach out to the course LF during Office Hours.

## Reference Documents and Tools

- [Datasets and linked services in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/concepts-datasets-linked-services)
- [Copy data from an HTTP endpoint](https://learn.microsoft.com/en-us/azure/data-factory/connector-http?tabs=data-factory)
- [Azure Blob Storage connector](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-blob-storage?tabs=data-factory)
- [Recall Data File (tutorials only)](https://static.nhtsa.gov/odi/ffdd/rcl/FLAT_RCL_POST_2010.zip)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)
- [Recalls Data Dictionary (RCL.txt)](https://static.nhtsa.gov/odi/ffdd/rcl/RCL.txt) — plain-text field list, often quicker to read than the PDF

## What you are building

By the end of this tutorial you will have four objects:

```
Linked Service: HTTP          ──▶  Dataset: Binary (the .zip on NHTSA's server)
Linked Service: Blob Storage  ──▶  Dataset: Binary (a landing spot in your container)
```

In Tutorial 3.2, a copy activity will connect the left-hand dataset to the right-hand one.

## Steps to Complete Tutorial 3.1

### Step 1: Create the HTTP Linked Service

The source file sits on a public NHTSA web server. Data Factory reaches it through an HTTP linked service.

1. Open **Data Factory Studio** and click the **Manage** (toolbox) icon.
2. Select **Linked services** > **+ New**.
3. In the search box, type `HTTP` and select the **HTTP** connector, then **Continue**.
4. Configure it as follows:

   - **Name**: `HTTP_NHTSA`
   - **Connect via integration runtime**: `AutoResolveIntegrationRuntime`
   - **Base URL**: `https://static.nhtsa.gov/odi/ffdd/rcl/`
   - **Server Certificate Validation**: Enabled
   - **Authentication type**: **Anonymous** — the file is public, so no credentials are needed

5. Click **Test connection**. You want a green success message.
6. Click **Create**.

<!-- SCREENSHOT: HTTP linked service configuration panel with base URL and Anonymous auth, showing a successful Test connection -->

> **NOTE** - The **Base URL** is the folder, not the file. The specific filename goes in the dataset in Step 3. Splitting it this way means you can point several datasets at the same server without repeating the connection details.

### Step 2: Create the Azure Blob Storage Linked Service

This is the destination side — your own storage account from Tutorial 1.2.

1. Still in **Manage** > **Linked services**, click **+ New**.
2. Search for `Azure Blob Storage` and select it, then **Continue**.
3. Configure it as follows:

   - **Name**: `AzureBlob_Mod4`
   - **Connect via integration runtime**: `AutoResolveIntegrationRuntime`
   - **Authentication type**: **Account key**
   - **Account selection method**: **From Azure subscription**
   - **Azure subscription**: Azure for Students
   - **Storage account name**: the one you created in Tutorial 1.2

4. Click **Test connection**, then **Create**.

<!-- SCREENSHOT: Azure Blob Storage linked service panel with subscription and storage account selected, successful Test connection -->

> **NOTE** - Selecting **From Azure subscription** lets Azure retrieve the account key for you rather than making you paste it in. Never paste a real access key into a screenshot or a submitted document.

Your **Linked services** list should now show both connections.

<!-- SCREENSHOT: Linked services list showing HTTP_NHTSA and AzureBlob_Mod4 -->

### Step 3: Create the Source Dataset

Now point at the specific file.

1. Click the **Author** (pencil) icon.
2. Next to **Datasets**, click **...** > **New dataset**.
3. Search for and select **HTTP**, then **Continue**.
4. For **Select format**, choose **Binary**, then **Continue**.
5. Configure it as follows:

   - **Name**: `RecallZipSource`
   - **Linked service**: `HTTP_NHTSA`
   - **Relative URL**: `FLAT_RCL_POST_2010.zip`
   - **Compression type**: **None**

6. Click **OK**.

<!-- SCREENSHOT: HTTP binary dataset properties with the relative URL filled in -->

> **NOTE** - **Binary** is the important choice here. A `.zip` is not text and not a table; asking Data Factory to interpret it as delimited text will fail. Binary tells ADF to move the bytes without trying to understand them.

> Notice **Compression type** is set to **None** even though this is a zip file. That is deliberate — right now we only want to *download* the archive intact. Decompression is a separate concern you will handle in Tutorial 3.2.

### Step 4: Create the Sink Dataset

This one describes where the file lands in your storage account.

1. Next to **Datasets**, click **...** > **New dataset** again.
2. Search for and select **Azure Blob Storage**, then **Continue**.
3. For **Select format**, choose **Binary**, then **Continue**.
4. Configure it as follows:

   - **Name**: `RecallZipLanding`
   - **Linked service**: `AzureBlob_Mod4`
   - **File path**: use the **Browse** folder icon to select your `tutorial-data` container, then type `FLAT_RCL_POST_2010.zip` in the file name box
   - **Compression type**: **None**

5. Click **OK**.

<!-- SCREENSHOT: Blob binary dataset properties showing the file path browser with the tutorial-data container selected -->

### Step 5: Publish

Click **Publish all** in the top toolbar and confirm. A panel lists the pending changes before it deploys them.

> **NOTE** - Your Data Factory has no Git repository attached, so **Publish all** is the only way to save. There is no separate Save button and no draft that survives on its own. Close the tab without publishing and the work is gone.

<!-- SCREENSHOT: Publish all confirmation panel listing the four pending changes -->

In Tutorial 3.2, you will wire these together with a copy activity and finally move the file.

## Point to Consider 🤔

- The HTTP linked service holds the base URL and the dataset holds the filename. What would you have to change if NHTSA published a second file you also wanted to pull?
- Why does Data Factory ask you to choose a *format* (Binary, DelimitedText, JSON) when creating a dataset rather than working it out from the file extension?

---

Ensure you understand each step and reach out with any questions!
