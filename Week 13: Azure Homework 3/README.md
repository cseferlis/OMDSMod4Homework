# Azure Homework 3 — Data Lake, Synapse, and Power BI

**Class,**

Over Weeks 10, 11, and 12 you built a complete analytics stack: a data lake with a hierarchical namespace, a Data Flow converting text to partitioned Parquet, a Synapse workspace, an external table queried in place by a serverless SQL pool, and an interactive Power BI report.

This assignment asks you to do the same against the NHTSA **Complaints** dataset, focused on **Ford** vehicles.

The instructions describe what to accomplish rather than which buttons to press. Every interface was covered in Tutorials 10.1 through 12.2, and those tutorials remain in the repository.

**Due: end of Week 13.** This is a cumulative assignment — the three stages below build on one another, and the final submission covers all of them. Do not leave it to the final week; the Data Flow stage in particular takes time to get right.

> **NOTE** - Use the same `Resource Group`, `Storage Account`, `Data Factory`, and `Synapse workspace` from the tutorials.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## The Data

You will work with the NHTSA **Complaints** file you first met in Azure Homework 1 — the public record of safety-related defect complaints, collected by web form and telephone since 1995.

- **Complaints Reference File**: [Import Instructions (Appendix A defines every field)](https://static.nhtsa.gov/odi/ffdd/cmpl/Import_Instructions_Excel_All.pdf)
- **Complaints Data Dictionary**: [CMPL.txt](https://static.nhtsa.gov/odi/ffdd/cmpl/CMPL.txt)
- **Ford safety ratings**: [Safercar_data_FORD.csv](https://mod4.blob.core.windows.net/hw3c/Safercar_data_FORD.csv) — also in the repository
- **Safercar documentation**: [READ ME file](https://static.nhtsa.gov/nhtsa/downloads/Safercar/Safercar_data_READ_ME_file.txt)

## Stage 1 — Data Lake and Parquet

1. Ensure your storage account has the **hierarchical namespace** enabled (ADLS Gen2).
2. Build an **Azure Data Factory Mapping Data Flow** that reads the Complaints `.txt` file and writes **Parquet** files to your data lake.
3. **Name the output columns** to match the fields defined in the Complaints Reference File. The auto-generated positional names are not acceptable — everything downstream depends on these.
4. **Partition the output by manufacturer name**, producing one file per manufacturer, each named after that manufacturer with a `.parquet` extension.
5. Handle manufacturer names that end with a period. Azure storage will not accept them in a filename.

## Stage 2 — Synapse External Table and Query

1. Confirm your **ACL permissions** on the storage container and your **Synapse Administrator** role in the workspace.
2. Create an **external table** in your Synapse **serverless** SQL pool over the **Ford Motor Company** Parquet file.
3. Write a query returning **crash data for the Ford F-150, model years 1990 to 2010**:
   - Model: `F-150`
   - Model year: between 1990 and 2010
   - Crash indicator only
   - Count of crashes per year
   - Sorted ascending by year
4. Produce a **chart** of that result in the Synapse results pane.

> **NOTE** - Consult the Complaints Reference File for the correct column names. The crash indicator field does not have an obvious name, and its values may not be what you first assume — check what is actually in the data before concluding your query is broken.

## Stage 3 — Power BI Report

1. Connect **Power BI** to your Synapse **serverless SQL endpoint** and import the external table.
2. Create a calculated column `YEAR_MODEL_ID` combining `YEARTXT` and `MODELTXT` with an underscore.
3. Import **`Safercar_data_FORD.csv`**.
4. Create a **many-to-one relationship** between the two tables on `YEAR_MODEL_ID`.
5. Build a report meeting all of the following:
   - At least one **graph** (bar, line, or similar), clearly formatted
   - At least one **table** visual presenting key data points
   - At least one **interactive filter or slicer**
   - Fields from **both** datasets used in your visuals
   - All visuals **connected and interactive** — selecting in one updates the others

**Optional but encouraged**: additional pages or visuals for deeper analysis. Be creative.

## Submission

Submit the following through Gradescope:

1. **A screenshot of your Synapse SQL query and its chart** (Stage 2).
2. **A screenshot of your completed Power BI report**, showing at least one graph, one table, and one interactive filter.
3. **Your Power BI report file** (`.pbix`).

**IMPORTANT:** Ensure your BU account information is visible in the top right corner of your screenshots for verification.

## Managing Your Credit

This assignment contains the most expensive activity in the course.

- **Data Flow debug mode runs a Spark cluster and bills while it is on**, whether you are working or not. Turn it on when you start, off when you stop, and set the shortest time to live. Do not leave it running overnight.
- **Synapse serverless bills per terabyte scanned.** Point your external table at a single manufacturer file rather than the whole container.
- **Do not create a dedicated SQL pool.** It bills hourly at a rate that would consume your remaining credit quickly.
- Check **Cost analysis** in the portal periodically.

## Where to Look When You Are Stuck

| If you are stuck on | Read |
|---|---|
| ADLS Gen2 upgrade, why Parquet | Tutorial 10.1 |
| Data Flows, filters, derived columns, partitioning | Tutorial 10.2 |
| Synapse workspace, ACLs, linking storage | Tutorial 11.1 |
| External tables, serverless SQL, charts | Tutorial 11.2 |
| Power BI access on Mac or Windows, connecting | Tutorial 12.1 |
| Calculated columns, relationships, interactivity | Tutorial 12.2 |
| Data Factory datasets and linked services | Tutorials 3.1 and 4.3 |

Your Recalls-based pipeline, external table, and report all remain in place. They are working references — open them and compare when something will not behave.

## Points to Consider 🤔

- How do you use the Complaints Reference File to name your Parquet columns correctly, and what breaks downstream if you skip it?
- Your Data Flow partitions by manufacturer. What makes a file-per-manufacturer layout better than folders, and what query pattern does it optimise for?
- The crash indicator field may hold values you do not expect. How would you find out what is actually in a column before writing a filter against it?
- Your Power BI visuals should filter each other. What has to be true of the data model for that to work?
- Synapse queries files in place rather than loading them into a database. What did you give up compared to the Azure SQL approach in Homework 1?

## When You Are Finished

Leave your resources in place until your grade is returned — you may need to demonstrate your work. Once graded, and once you are certain you no longer need them, deleting the Resource Group stops all charges.

---

Good luck, and enjoy building your report!
