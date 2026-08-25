# Week 10.2 Tutorial - Mapping Data Flows and Partitioned Parquet

**Hello Everybody!**

Every pipeline you have built so far used the **Copy activity**, which moves data and can map columns but cannot reshape it. This tutorial introduces **Mapping Data Flows**, which can make deeper, fundamental changes before the data reaches its final destination. Data Flow can filtering row, derive new columns, and control how the output is split across files.

Behind the visual designer, a Data Flow compiles to Apache Spark and runs on a cluster Azure provisions for you. That is what makes it powerful and it is also what makes it, by a wide margin, **the most expensive thing you will do in this course**. Read Step 1 before you click anything.

> **NOTE** - this tutorial builds on Tutorial 10.1. Your storage account must have the hierarchical namespace enabled, and you need the extracted `.txt` file from Week 3.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Mapping data flows in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/concepts-data-flow-overview)
- [Data flow debug mode](https://learn.microsoft.com/en-us/azure/data-factory/concepts-data-flow-debug-mode)
- [Tutorial: Write to a data lake](https://learn.microsoft.com/en-us/azure/data-factory/tutorial-data-flow-write-to-lake)
- [Sink transformation and file naming options](https://learn.microsoft.com/en-us/azure/data-factory/data-flow-sink)
- [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf)

## Steps to Complete Tutorial 10.2

### Step 1: Understand what debug mode costs

A Data Flow cannot be previewed or run without a live Spark cluster. Turning on **Data flow debug** starts that cluster, and **it bills for as long as it is on**, whether you are actively using it or staring at the screen thinking.

Some numbers, so this is not abstract. The minimum cluster Data Flows will run on is **8 vCores**, billed per vCore-hour and prorated by the minute. At General Purpose rates that works out to roughly **$2 per hour** of debug session. Microsoft's own pricing example walks through an engineer who leaves debug on across an eight-hour working day and arrives at **$12.35 for that single day**.

Your entire credit for this course is $100.

Before you begin:

- Turn debug **on** only when you are ready to work, and **off** the moment you stop.
- Check the **time to live (TTL)** when starting the session. The default is 60 minutes, meaning an abandoned session keeps billing for an hour after you walk away. Set it shorter.
- Do not leave a debug session running overnight. This is the single fastest way to consume your $100 credit.
- Plan your Data Flow on paper first, then build it in one sitting.

<!-- SCREENSHOT: Data flow debug toggle with the TTL/integration runtime options panel open -->

> **NOTE** - Everything else in this course is close to free at your usage level. This is the exception. Treat the debug toggle the way you would treat a taxi meter.

### Step 2: Create the Data Flow

1. In **Data Factory Studio**, click **Author**.
2. Next to **Data flows**, click **...** > **New data flow**.
3. Name it `DF_Recalls_To_Parquet`.
4. Turn on **Data flow debug** now, choosing the shortest available TTL. The cluster takes a few minutes to start.

<!-- SCREENSHOT: Empty data flow canvas with debug starting -->

### Step 3: Add the source

1. Click **Add Source**.
2. Configure it as follows:

   - **Output stream name**: `RecallsSource`
   - **Source type**: Dataset
   - **Dataset**: `RecallTxtDelimited` (the tab-delimited dataset from Tutorial 4.3)

3. Open the **Projection** tab. Because the file has no header, columns are named positionally.
4. Click **Import projection** to have Data Factory infer the column list.

   <!-- SCREENSHOT: Source transformation Projection tab showing inferred columns -->

5. Open **Data preview** and confirm you see recall records in sensible columns.

> **NOTE** - If Data preview shows one giant column, the delimiter on the underlying dataset is wrong. Fix it in the dataset before continuing — the Data Flow inherits it.

### Step 4: Rename the columns

Positional names like `Prop_0` are useless downstream. Parquet carries its schema with it, so naming the columns here means every later query gets readable field names for free.

1. Click the **+** after `RecallsSource` and add a **Select** transformation.
2. Name it `RenameColumns`.
3. Map each input column to a meaningful output name, using the field list in the [Recall Reference File](https://static.nhtsa.gov/odi/ffdd/rcl/Import_Instructions_Recalls.pdf) appendix — `RECORD_ID`, `CAMPNO`, `MAKETXT`, `MODELTXT`, `YEARTXT`, and so on.

<!-- SCREENSHOT: Select transformation showing positional columns mapped to named output columns -->

This is tedious and it is the step most worth doing carefully. Everything in Weeks 11 and 12 refers to these names.

### Step 5: Filter out problem rows

Manufacturer names in this data sometimes end with a period. You are about to use the manufacturer name as a **filename**, and Azure storage does not allow a trailing period in a file or directory name. Those rows will break the write.

1. Add a **Filter** transformation after `RenameColumns`. Name it `FilterTrailingDot`.
2. Set the filter condition to one of:

```
!endsWith(MAKETXT, ".")
```

or equivalently:

```
right(MAKETXT, 1) != '.'
```

<!-- SCREENSHOT: Filter transformation with the endsWith expression entered -->

> **NOTE** - This is a good illustration of a general principle: a constraint in your *destination* propagates backwards into your *transformation*. Nothing about the data is wrong; it is the choice to use this field as a filename that makes a trailing period a problem.

### Step 6: Build the output filename

You want each output file named after the manufacturer, with a `.parquet` extension. Data Factory will not add the extension for you when filenames come from column data.

1. Add a **Derived Column** transformation. Name it `BuildFileName`.
2. Create a new column called `FileName` with the expression:

```
concat(MAKETXT, '.parquet')
```

<!-- SCREENSHOT: Derived Column transformation with the concat expression -->

### Step 7: Configure the sink

1. Add a **Sink** transformation. Name it `ParquetSink`.
2. Create a new dataset: **Azure Data Lake Storage Gen2** > **Parquet**, pointing at your `parquet-data` container. Name it `RecallsParquet`.
3. On the sink's **Settings** tab, set **File name option** to **As data in column**, and choose the `FileName` column you just created.

   <!-- SCREENSHOT: Sink Settings tab with "As data in column" selected and FileName chosen -->

   > **NOTE** - There are two ways to split output, and they produce different results:
   > - **File name as column data** → **files** named after each manufacturer. **This is what you want.**
   > - **Set partitioning by key** → **folders** named after each manufacturer, each containing generically-named files. This is not what you want here.
   >
   > The distinction is easy to miss and produces output that looks superficially correct.

4. On the **Optimize** tab, set partitioning to **Single partition**. If that errors, use **Use current partitioning** instead.

<!-- SCREENSHOT: Sink Optimize tab with Single partition selected -->

> **NOTE** - Spark parallelises by splitting data across executors. Left to itself, each executor writes its own file, so you would get several fragments per manufacturer rather than one clean file. Forcing a single partition trades some speed for the one-file-per-manufacturer result you need.

### Step 8: Run it

1. Create a new pipeline named `PL_Recalls_Parquet`.
2. Drag a **Data flow** activity onto the canvas and select `DF_Recalls_To_Parquet`.
3. Click **Debug**.

   <!-- SCREENSHOT: Pipeline with a Data flow activity, showing a successful run in the Output tab -->

4. In the portal, browse to **Storage Account** > **Containers** > `parquet-data`. You should see one `.parquet` file per manufacturer.

<!-- SCREENSHOT: parquet-data container listing files named after manufacturers -->

### Step 9: Turn debug off

Go back to the Studio and **switch Data flow debug off**. Do this now, not later.

<!-- SCREENSHOT: Data flow debug toggle in the off position -->

### Troubleshooting

- **Debug will not start** — Spark clusters take several minutes to provision. If it fails outright, your region may be at capacity; try again shortly.
- **Write fails on invalid filename** — a manufacturer name contains a character storage does not permit. The trailing-period filter in Step 5 handles the common case; extend it if you hit others.
- **Files have no `.parquet` extension** — the Derived Column in Step 6 is missing or not selected in the sink.
- **You get folders instead of files** — you used key partitioning rather than "As data in column." See the note in Step 7.
- **Many fragment files per manufacturer** — the Optimize tab is not set to single partition.
- **Data preview is empty** — check the source dataset's delimiter and file path.

## Point to Consider 🤔

- A Copy activity could not have done this. Which specific steps required a Data Flow, and why?
- You partitioned by manufacturer. What kind of query does that make fast, and what kind does it make slow?
- Debug mode bills for a running cluster rather than for work completed. How does that change how you would plan a build compared to the Copy activities you wrote in Week 3?

---

Ensure you understand each step and reach out with any questions!
