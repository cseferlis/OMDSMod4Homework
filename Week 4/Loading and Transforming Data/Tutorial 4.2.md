# Week 4.2 Tutorial - The Azure SQL Query Editor

**Class,**

Tutorial 4.1 gave you a database. This tutorial is about the interface you use to talk to it, and about the single most important thing you will do in that interface: **defining a table**.

Like Tutorial 2.2, the first half is a guided tour with no graded outcome. Take the time — students who understand the Query Editor spend Week 5 debugging their data, and students who do not spend it debugging their tools.

> **NOTE** - this tutorial builds on Tutorial 4.1. You need a deployed SQL database and a firewall rule allowing your client IP. If you cannot connect, go back to 4.1 Step 3 before assuming something is broken.

## Reference Documents and Tools

- [Query editor in the Azure portal](https://learn.microsoft.com/en-us/azure/azure-sql/database/query-editor?view=azuresql)
- [CREATE TABLE (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=azuresqldb-current)
- [Data types (Transact-SQL)](https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=azuresqldb-current)
- [nchar and nvarchar](https://learn.microsoft.com/en-us/sql/t-sql/data-types/nchar-and-nvarchar-transact-sql?view=azuresqldb-current)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)
- [Recalls Data Dictionary (RCL.txt)](https://static.nhtsa.gov/odi/ffdd/rcl/RCL.txt)

## Steps to Complete Tutorial 4.2

### Step 1: Open the Query Editor and sign in

1. In the Azure Portal, open your **SQL database** (the database, not the server).
2. In the left-hand sidebar, click **Query editor (preview)**.
3. Sign in. You have two options:
   - **Microsoft Entra authentication** — click the **Continue as \<your name\>** button. Usually the simplest.
   - **SQL server authentication** — Login `omdsmod4admin`, Password `omdsmod4password013!`

<!-- SCREENSHOT: Query editor login panel showing both the Entra option and the SQL authentication fields -->

If you get a firewall error instead of a login prompt, it will name your current IP address. Copy that address, go to the **SQL server** > **Security** > **Networking**, add it as a firewall rule, save, and try again.

<!-- SCREENSHOT: The firewall error message shown by Query editor, with the client IP visible -->

### Step 2: Look around

The editor has three regions:

- **Left**: an object explorer with **Tables**, **Views**, and **Stored Procedures**. Expanding **Tables** shows what already exists — you should see several `SalesLT.*` tables from the AdventureWorksLT sample data the template loaded.
- **Centre**: the query pane where you type SQL, with a **Run** button above it.
- **Bottom**: **Results**, **Messages**, and query timing. **Messages** is where errors appear, and it is more informative than the red banner.

<!-- SCREENSHOT: Query editor with the object explorer expanded showing SalesLT tables -->

> **NOTE** - The Query Editor runs whatever is selected in the pane, or the entire contents if nothing is selected. This is useful — you can keep several statements in the pane and highlight just the one you want — and it is also a good way to accidentally run something you did not intend. Check what is highlighted before clicking Run.

### Step 3: Practise on the sample data

Before defining your own table, get comfortable with the editor using the sample tables. Type and run the following:

```sql
SELECT TOP 10 * FROM SalesLT.Product;
```

<!-- SCREENSHOT: Results grid showing rows returned from SalesLT.Product -->

Then try a few of these to build familiarity with the shapes of query you will need in Week 5:

```sql
-- How many rows are in a table?
SELECT COUNT(*) FROM SalesLT.Product;

-- What is the largest value in a column?
SELECT MAX(SellStartDate) FROM SalesLT.Product;

-- Filter to matching rows
SELECT * FROM SalesLT.Product WHERE Color = 'Black';
```

`COUNT(*)` and `MAX()` in particular are worth knowing now. After loading data in Tutorial 4.3, `COUNT(*)` is how you confirm all your rows arrived, and `MAX()` on a date column is how you find the most recent date present in a table.

### Step 4: Understand the data before defining the table

Here is the part that actually requires thought.

Your extracted `.txt` file has **no header row**. It is a tab-delimited file where the meaning of each column is defined entirely by an external document. Before you can write a `CREATE TABLE` statement, you must read the [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf) — the appendix lists every field in order, with its type and maximum length.

Two rules to carry into your table definition:

**Use `NVARCHAR`, not `VARCHAR`, for text columns.** `VARCHAR` stores one byte per character and cannot represent characters outside its code page. This is public-submitted data containing manufacturer names, model names, and free-text descriptions from across the world; it will contain characters that `VARCHAR` mangles. `NVARCHAR` is Unicode and handles them.

**Match or exceed the lengths in the reference document.** If the reference says a field is 25 characters and you declare `NVARCHAR(10)`, the load will fail on the first row that exceeds it — often thousands of rows in, after a long wait.

> **NOTE** - The Recalls schema has changed over time; fields have been added in recent years. Read the reference document rather than relying on an older example, and count the columns in the file itself if you are unsure.

### Step 5: Create your table

The statement follows this shape. The first few columns are given as a worked example — you will complete the rest from the reference document.

```sql
CREATE TABLE <initials>Recalls (
    RECORD_ID      INT,
    CAMPNO         NVARCHAR(9),
    MAKETXT        NVARCHAR(25),
    MODELTXT       NVARCHAR(256),
    YEARTXT        NVARCHAR(4)
    -- continue with the remaining fields from the reference document
);
```

Replace `<initials>` with your own initials, so your table is identifiable.

Some judgement calls you will have to make:

- **Dates.** The flat file stores dates as text in `YYYYMMDD` format. You can load them as `NVARCHAR(8)` and convert later, or declare the column as `DATE` and convert during the copy. Tutorial 4.3 covers the second approach; think now about which you would prefer and why.
- **Numbers.** A field that contains only digits is not necessarily a number. A campaign number with leading zeros becomes a different value if stored as `INT`. When in doubt, text is the safer choice for a raw staging table.
- **Empty fields.** Every column above is nullable by default, which is what you want. Real-world public data has gaps.

Run the statement, then confirm it worked:

```sql
SELECT COUNT(*) FROM <initials>Recalls;
```

You should get `0` — the table exists and is empty. An error instead means the table was not created; read **Messages** for the reason.

<!-- SCREENSHOT: Query editor showing a successful CREATE TABLE with the new table visible in the object explorer -->

### Step 6: Know how to undo

You will almost certainly get a column length or type wrong on the first attempt. Fixing it is easy as long as the table is still empty:

```sql
DROP TABLE <initials>Recalls;
```

Then run your corrected `CREATE TABLE` again. There is no confirmation prompt and no undo, so be certain you have named the right table.

> **NOTE** - Getting the schema wrong and rebuilding it is a normal part of this work, not a sign you have gone off track. Expect two or three iterations.

## Point to Consider 🤔

- Why does a tab-delimited file with no header row require an external reference document, and what would go wrong if you guessed the column order?
- What is the practical consequence of declaring a text column shorter than the data it will receive? Would you rather find out at load time or at query time?
- The sample `SalesLT` tables have typed date and money columns, while your staging table is mostly text. When is it better to type data on the way in, and when is it better to load it raw and convert afterwards?

---

Ensure you understand each step and reach out with any questions!
