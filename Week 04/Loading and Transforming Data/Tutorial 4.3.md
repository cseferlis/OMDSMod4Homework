# Week 4.3 Tutorial - Managing Data Schemas in Data Factory

**Hello Everybody!**

You have a `.txt` file in blob storage (Week 3) and an empty typed table in a SQL database (Tutorial 4.2). This tutorial connects them, and in doing so covers the part of ETL that gives people the most trouble: **schema mapping**.

Up to now every copy activity you built was Binary to Binary — Data Factory moved bytes without caring what they meant. That ends here. To load a text file into a typed table, Data Factory has to understand the file as *columns*, and you have to tell it which source column goes into which destination column, and what to do when the types do not match.

> **NOTE** - this tutorial builds on Weeks 3 and 4. You need the extracted `.txt` in your `tutorial-data` container, a SQL table created in Tutorial 4.2, and the "Allow Azure services" firewall exception from Tutorial 4.1 Step 3.

## Reference Documents and Tools

- [Copy activity in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/copy-activity-overview)
- [Schema and data type mapping in copy activity](https://learn.microsoft.com/en-us/azure/data-factory/copy-activity-schema-and-type-mapping)
- [Delimited text format in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/format-delimited-text)
- [Copy data to and from Azure SQL Database](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-sql-database?tabs=data-factory)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)

## Why this step is different

A **Binary** dataset is opaque: Data Factory knows the file's size and nothing else. A **DelimitedText** dataset is structured: Data Factory knows the delimiter, whether there is a header row, the encoding, and therefore how many columns exist and what is in each one.

That structure is what makes mapping possible, and it is also what makes this step fail in ways the earlier copies could not. A binary copy either works or does not. A delimited copy can succeed while quietly putting the wrong data in the wrong column, which is far worse.

## Steps to Complete Tutorial 4.3

### Step 1: Create a DelimitedText dataset for the source

1. In **Data Factory Studio**, click **Author** > **Datasets** > **...** > **New dataset**.
2. Select **Azure Blob Storage**, then **Continue**.
3. For **Select format**, choose **DelimitedText**, then **Continue**.
4. Configure it as follows:

   - **Name**: `RecallTxtDelimited`
   - **Linked service**: `AzureBlob_Mod4`
   - **File path**: browse to `tutorial-data` > `extracted` and select `FLAT_RCL_POST_2010.txt`
   - **First row as header**: **leave unchecked** — this file has no header row
   - **Import schema**: **None** for now

5. Click **OK**.

   <!-- SCREENSHOT: DelimitedText dataset creation panel with First row as header unchecked -->

   Now set the delimiter, which is not on the creation panel:

6. Open the dataset and go to the **Connection** tab.
7. Set **Column delimiter** to **Tab (\t)**.
8. Set **Encoding** to **UTF-8**.
9. Set **Escape character** and **Quote character** to **No escape character** / **No quote character**.

   <!-- SCREENSHOT: Dataset Connection tab with Tab delimiter selected -->

   > **NOTE** - Setting quote and escape characters to none matters more than it looks. This is free-text data written by the public, and it contains stray apostrophes and quotation marks. If Data Factory treats a `"` as the start of a quoted field, every column after it on that row shifts by one and the row silently corrupts.

10. Click **Preview data**. You should see a grid of recall records with generic column names — `Prop_0`, `Prop_1`, and so on.

<!-- SCREENSHOT: Preview data showing tab-separated recall rows with Prop_0, Prop_1 column headers -->

If the preview shows one enormous column instead of many, your delimiter is wrong. Fix it before continuing — everything downstream depends on this being right.

### Step 2: Create the Azure SQL linked service

Data Factory needs its own connection to the database; it cannot borrow yours.

1. Click **Manage** (toolbox) > **Linked services** > **+ New**.
2. Search for **Azure SQL Database** and select it, then **Continue**.
3. Configure it as follows:

   - **Name**: `AzureSQL_Mod4`
   - **Connect via integration runtime**: `AutoResolveIntegrationRuntime`
   - **Account selection method**: **From Azure subscription**
   - **Azure subscription**: Azure for Students
   - **Server name**: your `<...>mod4server`
   - **Database name**: your `<...>mod4db`
   - **Authentication type**: **SQL authentication**
   - **User name**: `omdsmod4admin`
   - **Password**: `omdsmod4password013!`

4. Click **Test connection**, then **Create**.

<!-- SCREENSHOT: Azure SQL Database linked service panel with a successful Test connection -->

> **NOTE** - If Test connection fails with a firewall message, the **Allow Azure services and resources to access this server** exception from Tutorial 4.1 Step 3 is not enabled. Data Factory connects from Azure's own address space, not from your machine, so your personal client IP rule does nothing for it. These are two separate permissions.

### Step 3: Create the sink dataset

1. **Author** > **Datasets** > **...** > **New dataset**.
2. Select **Azure SQL Database**, then **Continue**.
3. Configure it as follows:

   - **Name**: `RecallSqlTable`
   - **Linked service**: `AzureSQL_Mod4`
   - **Table name**: select `<initials>Recalls` from the dropdown

4. Click **OK**.

If your table does not appear in the dropdown, it was not created successfully — return to Tutorial 4.2.

<!-- SCREENSHOT: SQL dataset properties with the table selected from the dropdown -->

### Step 4: Build the load activity

1. Open your `PL_Recall_Extract_Load` pipeline.
2. Drag a third **Copy data** activity onto the canvas and name it `Load_Recalls_To_SQL`.
3. Connect the green **Success** output of `Unzip_Recall_File` to this new activity, so the three run in order.
4. On the **Source** tab, set **Source dataset** to `RecallTxtDelimited`.
5. On the **Sink** tab, set **Sink dataset** to `RecallSqlTable`. Leave **Write behavior** as **Insert**.

<img width="672" height="236" alt="image" src="https://github.com/user-attachments/assets/30a4ed03-a11d-4a56-9001-6436ffffb58c" />


### Step 5: Map the columns

This is the substance of the tutorial.

1. Click the **Mapping** tab.
2. Click **Import schemas**. Data Factory samples the source file and reads the destination table, then proposes a mapping.

   <!-- SCREENSHOT: Mapping tab after Import schemas, showing source Prop_N columns paired with destination table columns -->

3. Read every row of that mapping before running anything.

Because your source file has no header, the source columns are positional — `Prop_0`, `Prop_1`, `Prop_2`. Data Factory pairs them with your table columns **in order**. That is correct only if your `CREATE TABLE` listed columns in exactly the same order as the reference document. If you reordered anything, the mapping is wrong even though nothing will error, and you will end up with model names in the year column.

Things to check and fix:

- **Column count.** If the source has more columns than your table, the extras will be dropped. If your table has more, they will be left null. Either is a sign your `CREATE TABLE` does not match the file.
- **Types.** Each destination column shows the type it expects. Where the source is text and the destination is `DATE` or `INT`, Data Factory attempts a conversion.
- **Unwanted columns.** You can delete a mapping row to skip a source column entirely.

> **NOTE** - If a type will not convert, the **JSON view** (the `{}` icon in the top right of the pipeline canvas) lets you edit the mapping definition directly and set the type by hand. This is a useful escape hatch when the visual editor will not cooperate.

### Step 6: Converting a text date

The flat file stores dates as `YYYYMMDD` text. Loading that into a `DATE` column is the transform step of ETL, and there are two ways to do it.

**Option A — let the copy activity convert.** Declare the destination column as `DATE` and set the mapping's type accordingly. Data Factory parses on the way in. Fewer moving parts, but the entire load fails if any single row holds a value that will not parse.

**Option B — load raw, then convert.** Declare the column as `NVARCHAR(8)`, load everything, and convert with SQL afterwards:

```sql
SELECT CONVERT(DATE, RCDATE) FROM <initials>Recalls;
```

This is more forgiving: bad rows land in the table where you can find them, rather than aborting the load. Many production pipelines stage raw and transform afterwards for exactly this reason.

Try Option A here so you have seen it work. Which approach is right depends on how clean the data turns out to be, so it is worth understanding both.

### Step 7: Run and verify

1. Click **Debug**. This copy moves far more data than the earlier ones and will take several minutes.
2. Watch the **Output** tab, then open the **Monitor** hub and click into the run. The activity detail shows **rows read** and **rows written** — these should match.

<img width="807" height="678" alt="image" src="https://github.com/user-attachments/assets/9c5c104e-3dc3-471a-9d83-bbbe6388041c" />

3. Go to the **Query editor** in the portal and confirm the data landed:

   ```sql
   SELECT COUNT(*) FROM <initials>Recalls;

   SELECT TOP 20 * FROM <initials>Recalls;
   ```

   Look at those twenty rows properly. Do the values sit in sensible columns? Are model names in the model column and years in the year column? A load can report complete success while being shifted by one column, and `COUNT(*)` will not tell you.

   <!-- SCREENSHOT: Query editor showing loaded recall rows -->

4. Return to the Studio and click **Publish all**.

### Troubleshooting

- **"String or binary data would be truncated"** — a value is longer than the column allows. Find the offending field in the reference document, then `DROP TABLE`, widen the column, and recreate.
- **"Conversion failed when converting date and/or time from character string"** — a value will not parse as a date. Switch that column to `NVARCHAR` and convert in SQL afterwards.
- **Cannot connect to the SQL server** — the "Allow Azure services" exception is off. See Tutorial 4.1 Step 3.
- **Row counts match but data looks wrong** — a delimiter, quote character, or column-order problem. Go back to the dataset preview in Step 1.
- **Rows loaded twice** — **Insert** appends. Re-running the pipeline adds a second copy of everything. Run `DELETE FROM <initials>Recalls;` before retrying.

## Point to Consider 🤔

- Your source columns are positional (`Prop_0`, `Prop_1`) rather than named. What does that imply about how carefully the `CREATE TABLE` column order has to match the reference document?
- A load can report success while being shifted by one column. What query would you write to detect that, beyond eyeballing twenty rows?
- Option A fails the whole load on one bad date; Option B loads everything and leaves you to find the bad rows. Which would you choose for a pipeline that runs nightly without supervision?

---

Ensure you understand each step and reach out with any questions!
