# Week 11.2 Tutorial - External Tables and Serverless SQL

**Class,**

In Week 4 you loaded data into a table. Synapse lets you do something different: define a table that **points at files** without copying anything. The files stay in the data lake; the table is a schema definition laid over them.

This is **data virtualisation**, and it is why the Parquet work in Week 10 mattered. This tutorial creates an external table, queries it, and charts the result.

> **NOTE** - this tutorial builds on Tutorial 11.1. You need a Synapse workspace with your storage account linked and your Parquet files visible in the Data hub.

## Reference Documents and Tools

- [Use external tables with Synapse SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables?tabs=hadoop)
- [Query Parquet files using serverless SQL pool](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/query-parquet-files)
- [CREATE EXTERNAL TABLE (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-table-transact-sql?view=azure-sqldw-latest)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)

## What an external table actually is

Three objects work together, and Synapse generates all three for you:

- **External data source** — where the files live (your storage account and container)
- **External file format** — how to read them (Parquet, in this case)
- **External table** — the column definitions, plus a pointer to a file or folder

Querying it runs a distributed read across the underlying files. Nothing is stored in a database. **Drop the table and the files are untouched**; delete the files and the table still exists but returns nothing.

## Steps to Complete Tutorial 11.2

### Step 1: Pick a file and generate the table

1. In **Synapse Studio**, go to **Data** > **Linked** and browse to your `parquet-data` container.
2. Pick one manufacturer file to work with — the examples below use `Ford Motor Company.parquet`, but any large manufacturer works.
3. Right-click the file and choose **New SQL script** > **Create external table**.

   <!-- SCREENSHOT: Right-click menu on a parquet file showing Create external table -->

4. In the dialog:

   - **SQL pool**: **Built-in** (the serverless pool)
   - **Database**: click **Create new** and name it something clear, such as `RecallsDB`
   - **External table name**: something descriptive, such as `FordExternalTable`
   - Choose **Using SQL script** rather than the automatic option, so you can see what is generated

5. Click **Create**.

<!-- SCREENSHOT: Create external table dialog with database and table name filled in -->

### Step 2: Read the generated script before running it

Synapse produces a script containing `CREATE DATABASE`, `CREATE EXTERNAL FILE FORMAT`, `CREATE EXTERNAL DATA SOURCE`, and `CREATE EXTERNAL TABLE`. Read it.

The column list is inferred from the Parquet file's embedded schema — this is the payoff for naming columns properly in Tutorial 10.2. Check that types look sensible; Synapse tends toward generous `NVARCHAR` lengths, which is safe but worth noticing.

<!-- SCREENSHOT: Generated CREATE EXTERNAL TABLE script in the Synapse SQL editor -->

Click **Run**. When it completes, refresh the **Workspace** tab under **Data** and confirm the database and table appear.

> **NOTE** - Nothing was copied. This ran in seconds regardless of file size, because all it did was record a schema and a path.

### Step 3: Query it

Above the editor, set **Use database** to `RecallsDB`. Leaving it on `master` produces "Invalid object name" errors that look like the table failed to create.

<!-- SCREENSHOT: The Use database dropdown set to RecallsDB rather than master -->

Start simple:

```sql
SELECT TOP 10 * FROM FordExternalTable;
```

```sql
SELECT COUNT(*) FROM FordExternalTable;
```

<!-- SCREENSHOT: Query results showing recall rows from the external table -->

Note that the column names are the readable ones you set in Week 10, not `Prop_0`.

### Step 4: An aggregate query

Now something with shape to it — recalls per model year:

```sql
SELECT YEARTXT, COUNT(*) AS RecallCount
FROM FordExternalTable
WHERE YEARTXT BETWEEN '1990' AND '2010'
GROUP BY YEARTXT
ORDER BY YEARTXT ASC;
```

Three things to notice:

- **`YEARTXT` is text**, so the `BETWEEN` comparison is a string comparison. It works here because four-digit years sort correctly as strings. It would not work for two-digit years or unpadded numbers.
- **`GROUP BY` then `ORDER BY`** is the standard shape for "count something per category, in order."
- The query is **distributed** across nodes and combined. You did not write anything to make that happen.

<!-- SCREENSHOT: Aggregate query results showing year and recall count columns -->

Try filtering further — a specific model, for instance:

```sql
SELECT YEARTXT, COUNT(*) AS RecallCount
FROM FordExternalTable
WHERE MODELTXT = 'F-150'
  AND YEARTXT BETWEEN '1990' AND '2010'
GROUP BY YEARTXT
ORDER BY YEARTXT ASC;
```

If this returns nothing, check the exact spelling in the data. Model names in public datasets are inconsistent — try `SELECT DISTINCT MODELTXT FROM FordExternalTable` to see what is actually there.

> **NOTE** - That `SELECT DISTINCT` habit is worth keeping. Assuming a value exists in the form you expect is one of the most common ways to conclude a query is broken when the data simply spells things differently.

### Step 5: Chart the result

Synapse can visualise a result set without leaving the browser.

1. With the aggregate query results showing, click the **Chart** toggle above the results pane.
2. Choose a **Bar** or **Line** chart.
3. Set the **Category column** to `YEARTXT` and the value to `RecallCount`.

<!-- SCREENSHOT: Synapse results pane switched to Chart view showing recalls by year -->

This is a quick look, not a reporting tool — the chart lives only in this query tab. Week 12 introduces Power BI for anything you would actually share.

### Step 6: Save your work

Click **Publish** in the top toolbar to save the SQL script into the workspace. Note the script name; you will connect Power BI to this database next week.

### Troubleshooting

- **"Invalid object name"** — the **Use database** dropdown is on `master`. See Step 3.
- **Permission or access errors** — ACLs on the container. See Tutorial 11.1 Step 3.
- **The table exists but returns no rows** — the path in the external data source may not match where the files actually are. Check the generated `LOCATION` value against the Data hub.
- **Columns are named `C1`, `C2`, ...** — the Parquet files were written without proper column names. Fix it in the Data Flow (Tutorial 10.2 Step 4) and regenerate.
- **A query is unexpectedly slow or expensive** — you may be scanning far more files than intended. Check that your table points at one file rather than the whole container.

## Point to Consider 🤔

- Dropping an external table leaves the files untouched. What does that imply about who is responsible for data integrity in this architecture, compared to Week 4?
- Your table points at one manufacturer's file. What would change if it pointed at the whole container, and what would that cost you?
- `YEARTXT BETWEEN '1990' AND '2010'` compares strings, not numbers. When would that quietly give a wrong answer?

---

Ensure you understand each step and reach out with any questions!
