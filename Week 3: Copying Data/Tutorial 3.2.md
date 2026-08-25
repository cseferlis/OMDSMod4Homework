# Week 3.2 Tutorial - Copying Data from One Source to Another

**Class,**

In Tutorial 3.1 you built two linked services and two datasets but did not move anything. Now we connect them. This tutorial covers the `Copy activity` — the single most-used activity in Azure Data Factory and the mechanism behind the `Extract` and `Load` portions of an ETL pipeline.

You will do this in two stages: first pull the compressed archive from NHTSA's server into your storage account, then unzip it into a usable `.txt` file. The second stage is the part that trips people up, so read Step 3 carefully before clicking.

> **NOTE** - this tutorial builds on your activities in the previous weeks. You should be using the same `Resource Group`, `Storage Account`, and `Data-Factory` from the previous tutorials. It is strongly recommended that you complete the tutorials from prior weeks before starting this tutorial. If you need further assistance, please reach out to the course LF during Office Hours.

## Reference Documents and Tools

- [Copy activity in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-overview)
- [Copy Data tool quickstart](https://learn.microsoft.com/en-us/azure/data-factory/quickstart-hello-world-copy-data-tool)
- [Reading and writing compressed files](https://learn.microsoft.com/en-us/azure/data-factory/format-binary)
- [Recall Data File (tutorials only)](https://static.nhtsa.gov/odi/ffdd/rcl/FLAT_RCL_POST_2010.zip)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)

## Steps to Complete Tutorial 3.2

### Step 1: Create a pipeline

1. Open **Data Factory Studio** and click the **Author** (pencil) icon.
2. Next to **Pipelines**, click **...** > **New pipeline**.
3. In the properties pane on the right, name it `PL_Recall_Extract_Load`.

<!-- SCREENSHOT: New empty pipeline with the name set in the right-hand properties pane -->

### Step 2: Add the download copy activity

1. In the **Activities** pane, expand **Move and transform** and drag **Copy data** onto the canvas.
2. On the **General** tab, name it `Copy_Zip_From_NHTSA`.
3. On the **Source** tab, set **Source dataset** to `RecallZipSource`. Leave the request method as `GET`.
4. On the **Sink** tab, set **Sink dataset** to `RecallZipLanding`.

   <!-- SCREENSHOT: Copy activity Source tab with RecallZipSource selected -->

   <!-- SCREENSHOT: Copy activity Sink tab with RecallZipLanding selected -->

5. Click **Debug** in the top toolbar. Watch the **Output** tab at the bottom of the canvas.

   A successful run shows a green check and reports data written. The file is several megabytes, so give it a moment.

   <!-- SCREENSHOT: Output tab showing the copy activity succeeded, with data read/written figures -->

6. Verify in the portal: go to your **Storage Account** > **Containers** > `tutorial-data`. The `.zip` should be sitting there.

<!-- SCREENSHOT: Storage container in the portal showing FLAT_RCL_POST_2010.zip — compare to images/hw1b/container.png -->

### Step 3: Understand the unzip problem

You now have a `.zip` in blob storage. It is useless in that form — nothing downstream can query a compressed archive. You need the `.txt` file inside it.

Here is the constraint that matters:

> When using a Binary dataset in a copy activity, you can **only** copy from a Binary dataset to a Binary dataset. You cannot make the source Binary and the sink DelimitedText.

So how do you get a `.txt` out? Decompression is a property of the **dataset**, not of the sink format. A binary dataset whose **Compression type** is set to **ZipDeflate** is decompressed *on read* — Data Factory opens the archive and writes out its contents. The sink stays Binary with **Compression type: None**, and the extracted `.txt` lands intact.

You will build a **second copy activity** to do this, whose source is the zip you just landed in blob storage.

> **NOTE** - Strictly speaking, ADF *can* decompress in a single hop: the HTTP connector supports Binary format, so one copy activity reading from an HTTP source with ZipDeflate compression could write the extracted `.txt` straight to blob storage. We deliberately split it into two activities so that the compressed archive is retained in your storage account as a raw landing copy. Keeping the untouched source file is standard practice in a real pipeline — if a downstream transformation turns out to be wrong, you can reprocess without re-downloading from the source system.

### Step 4: Create the datasets for the unzip step

**Source dataset (compressed):**

1. **Author** > **Datasets** > **...** > **New dataset** > **Azure Blob Storage** > **Binary**.
2. Name it `RecallZipCompressed`.
3. **Linked service**: `AzureBlob_Mod4`
4. **File path**: `tutorial-data` container, file `FLAT_RCL_POST_2010.zip`
5. **Compression type**: **ZipDeflate**

   <!-- SCREENSHOT: Binary dataset with Compression type set to ZipDeflate -->

   > **NOTE** - **Compression type** is a *dataset* property, but the related **Preserve zip file name as folder** option is **not**. It lives on the copy activity's Source tab and only appears once the source dataset declares ZipDeflate compression. You will set it in Step 5.

   **Sink dataset (extracted):**

1. **New dataset** > **Azure Blob Storage** > **Binary**.
2. Name it `RecallTxtExtracted`.
3. **Linked service**: `AzureBlob_Mod4`
4. **File path**: `tutorial-data` container, folder `extracted`. Leave the file name blank — the name comes from inside the archive.
5. **Compression type**: **None**

<!-- SCREENSHOT: Sink binary dataset pointing at the extracted/ folder with no compression -->

### Step 5: Add the unzip copy activity

1. Return to `PL_Recall_Extract_Load`.
2. Drag a second **Copy data** activity onto the canvas and name it `Unzip_Recall_File`.
3. Connect the two activities: drag from the green **Success** handle on the right edge of `Copy_Zip_From_NHTSA` to the second activity. This enforces the order — the unzip will not start until the download succeeds.

   <!-- SCREENSHOT: Canvas showing both copy activities connected by a green success arrow -->

4. **Source**: set **Source dataset** to `RecallZipCompressed`. Because that dataset declares ZipDeflate compression, an **Advanced settings** section now appears on this tab containing **Preserve zip file name as folder**. **Uncheck it.**

   This box is checked by default. Left checked, Data Factory writes the extracted file to `<your path>/FLAT_RCL_POST_2010/FLAT_RCL_POST_2010.txt` — a folder named after the archive. Unchecked, the file lands directly in the path your sink dataset specifies.

5. **Sink**: set **Sink dataset** to `RecallTxtExtracted`. Leave **Copy behavior** at its default.

   <!-- SCREENSHOT: Copy activity Source tab with ZipDeflate dataset selected and Advanced settings expanded showing the unchecked "Preserve zip file name as folder" box -->

6. Click **Debug** and watch the Output tab. Both activities should report success.

<img width="569" height="529" alt="image" src="https://github.com/user-attachments/assets/3e64d074-7b83-4aff-b54e-340cddf05ef7" />

### Step 6: Verify and publish

1. In the portal, browse to **Storage Account** > **Containers** > `tutorial-data` > `extracted`. You should see `FLAT_RCL_POST_2010.txt`, dramatically larger than the archive it came from — the zip is roughly 15 MB, the extracted text file is several hundred MB. Expect the unzip activity to take a few minutes.
2. Click the file and use **Edit** or **Preview** to confirm it contains readable, tab-separated recall records.
3. Cross-reference the columns against the appendix of the [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf). The file has no header row, so the reference document is the only way to know what each field is.
4. Return to the Studio and click **Publish all**.

<img width="1417" height="449" alt="image" src="https://github.com/user-attachments/assets/57a70fb9-37cc-4175-9404-e4e48f4a62a9" />


### Troubleshooting

- **"The Copy activity failed: source is binary but sink is not"** — both datasets in a given copy activity must use the same format. Binary to binary, delimited to delimited.
- **The extracted file lands inside a folder named after the zip** — uncheck **Preserve zip file name as folder** under **Source** > **Advanced settings** on the copy activity. Note this is on the *activity*, not the dataset. If you cannot find the option, your source dataset is not set to ZipDeflate.
- **`UserErrorUnzipInvalidFile` / "not a valid Zip file with Deflate compression method"** — ADF only supports the Deflate algorithm inside a zip archive. The NHTSA file uses Deflate, so if you see this, the download is almost certainly truncated or is an error page rather than a real archive. Check the file size in blob storage against the source.
- **The pipeline succeeds but writes zero bytes** — check the **Relative URL** on your HTTP dataset. A typo produces a 404 that ADF can report as a successful transfer of an error page.
- **Anything else** — go to the **Monitor** hub, click into the failed run, and expand the error detail. It is far more specific than the canvas banner.

In Week 4, you will create an Azure SQL database and load extracted data into a proper table.

## Point to Consider 🤔

- The success arrow between the two activities enforces ordering. What would happen if you left them unconnected and hit Debug?
- We split download and decompress into two activities to keep a raw copy of the archive. What would you lose by combining them into one?
- How would you verify the integrity and structure of the `.txt` file without opening it manually?

---

Ensure you understand each step and reach out with any questions!
