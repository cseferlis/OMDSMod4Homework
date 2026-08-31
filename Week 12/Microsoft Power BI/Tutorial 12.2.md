# Week 12.2 Tutorial - Building an Interactive Power BI Report

**Hello Everyone!**

You have data from Synapse loaded into Power BI. With this tutorial, you'll be able to turn it into a report: a calculated column, a second table, a relationship between them, and visuals that respond to each other.

The last of those is the part worth focusing on. A chart is easy. A set of visuals that filter each other when you click one is what makes a dashboard useful, and it depends entirely on *getting the data model right first.*

> **NOTE** - this tutorial builds on Tutorial 12.1. You need Power BI open with your Synapse external table loaded.

## Reference Documents and Tools

- [Create reports in Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-dimensional-model-report)
- [Create and manage relationships in Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-create-and-manage-relationships)
- [Using calculated columns in Power BI Desktop](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-calculated-columns)
- [Slicers in Power BI](https://learn.microsoft.com/en-us/power-bi/visuals/power-bi-visualization-slicers)

## The three views

Power BI has three views, reachable from icons in the left rail. Knowing which one you need saves a lot of hunting.

- **Report view** — the canvas where you place visuals
- **Table view** — the data itself, where you add calculated columns
- **Model view** — the tables and the relationships between them

## Steps to Complete Tutorial 12.2

### Step 1: Add a calculated column

To relate two tables you need a column they share. Neither has one yet, so build it.

**Power BI Desktop:**

1. Switch to **Table view**.
2. With your table selected, click **New column**.
3. Enter this DAX expression, substituting your table's actual name:

   ```DAX
   YEAR_MODEL_ID = 'YourTableName'[YEARTXT] & "_" & 'YourTableName'[MODELTXT]
   ```

4. Press Enter. The column appears at the end of the table.

<!-- SCREENSHOT: Table view with the DAX formula bar showing the new calculated column -->

**Browser version:**

1. In the query editor, go to **Add Column** > **Custom Column**.
2. Name it `YEAR_MODEL_ID` and use:

   ```
   [YEARTXT] & "_" & [MODELTXT]
   ```

3. Click **OK**, then **Create Report**. Wait for both the semantic model and the report to finish processing before continuing.

> **NOTE** - `&` concatenates in DAX. The underscore separator matters: without it, year 2001 model "5" and year 200 model "15" would both produce `20015`. Composite keys need an unambiguous separator.

### Step 2: Bring in a second table

A single table cannot demonstrate a relationship, so add one. For this tutorial, create a small lookup table by hand — this also teaches a feature worth knowing.

**Power BI Desktop:**

1. **Home** > **Enter data**.
2. Build a small table with two columns, `YEAR_MODEL_ID` and a second column of your choosing — a rating, a category, a note.
3. Populate five or six rows using `YEAR_MODEL_ID` values that actually exist in your Synapse table. Find them in Table view first.
4. Name the table `ModelNotes` and click **Load**.

<!-- SCREENSHOT: Enter data dialog with a small lookup table being created -->

> **NOTE** - **Enter data** is genuinely useful beyond teaching. Small reference tables — region groupings, category labels, targets — often have no system of record and live perfectly well inside the report.

If you would rather practise with a larger external file, importing a CSV via **Get data** > **Text/CSV** works the same way and produces the same relationship exercise.

### Step 3: Create the relationship

1. Switch to **Model view**. You should see both tables as boxes.
2. Drag `YEAR_MODEL_ID` from one table onto `YEAR_MODEL_ID` in the other. Alternatively, right-click a table and choose **Manage relationships** > **New**.
3. Configure it as follows:

   - **Cardinality**: **Many to one**. Many recall records share one model-year; each model-year appears once in the lookup.
   - **Cross-filter direction**: **Single** (the default)

4. Click **OK**.

<!-- SCREENSHOT: Model view showing two tables joined by a relationship line -->

> **NOTE** - The relationship is what makes visuals filter each other. Without it, two visuals built from different tables sit on the same canvas and ignore each other entirely. If interactivity is not working later, this is the first thing to check.

### Step 4: Build the visuals

Switch to **Report view**. The **Visualizations** pane is on the right; click a visual type to add it, then drag fields into its wells.

**A chart:**

1. Click **Stacked column chart**.
2. Drag `YEARTXT` to the **X-axis**.
3. Drag any field to **Values** and set the aggregation to **Count**.

<!-- SCREENSHOT: Column chart showing recall counts by year -->

**A table:**

1. Click an empty area of the canvas, then choose the **Table** visual.
2. Drag in three or four fields — model, year, a field from your second table.

<!-- SCREENSHOT: Table visual alongside the chart -->

**A slicer:**

1. Click empty canvas, then choose **Slicer**.
2. Drag `MODELTXT` (or another field with a manageable number of values) into it.

<!-- SCREENSHOT: Slicer with model values listed -->

### Step 5: Test the interactivity

This is the step that tells you whether the model is right.

1. Click a value in the slicer. The chart and table should both narrow.
2. Click a bar in the chart. The table should filter to that year.
3. Click the same bar again to clear.

<!-- SCREENSHOT: Report with a slicer selection applied, chart and table both filtered -->

If the visuals do not respond to each other, check in this order: does the relationship exist in Model view, is its cardinality right, and are the visuals actually built from related tables.

> **NOTE** - Cross-filtering is on by default. You can turn it off per visual pair via **Format** > **Edit interactions**, which is occasionally what you want and more often the cause of a visual that mysteriously ignores everything.

### Step 6: Tidy up and save

1. Give each visual a meaningful title through the **Format** pane.
2. Check that axis labels are readable and numbers are formatted sensibly.
3. Save. On a virtual desktop, save to your redirected folder.

A report that answers a question at a glance is worth more than one with six visuals nobody can read.

### Troubleshooting

- **Visuals ignore each other** — no relationship, or the wrong cardinality. Model view.
- **The DAX column errors** — table names with spaces need single quotes: `'My Table'[Column]`.
- **The relationship will not create** — the columns may be different data types. Both sides must be text here.
- **Blank rows appear after relating tables** — values exist in one table with no match in the other. Expected with a hand-built lookup.
- **Work lost on the virtual desktop** — the session timed out. Save more often; there is no recovery.

## Point to Consider 🤔

- You built a composite key by concatenating two columns. What does that tell you about the grain of each table, and what would break if a model-year appeared twice in the lookup?
- Cross-filtering works because of the relationship, not because the visuals sit on the same page. Why is that distinction worth understanding before building a dashboard someone will rely on?
- Your report holds an imported snapshot. What would you need to change for it to stay current, and what would that cost?

---

Ensure you understand each step and reach out with any questions!
