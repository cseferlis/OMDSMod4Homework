# Week 2.2 Tutorial - Learning Data Factory Studio & Pipelines

**Class,**

In Tutorial 2.1 you deployed an Azure Data Factory, but a Data Factory with nothing in it does nothing. All of the actual building happens in a separate interface called **Data Factory Studio**, which opens in its own browser tab and looks nothing like the rest of the Azure Portal.

This tutorial is a guided tour. You will not move any data yet — the goal is that when Week 3 asks you to "create a linked service" or "add a copy activity," you already know where those things live and what they mean. Take your time here. Students who skip this tutorial spend Week 3 hunting for buttons.

> **NOTE** - this tutorial builds on Tutorial 2.1. You will need the Data Factory you deployed there.

## Reference Documents and Tools

- [Introduction to Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/introduction)
- [Pipelines and activities in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/concepts-pipelines-activities)
- [Datasets in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/concepts-datasets-linked-services)
- [Integration runtime in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)
- [Visually monitor Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/monitor-visually)

## The Vocabulary

Four terms come up constantly and are easy to confuse. Read these before opening the Studio.

The easiest way to keep them straight is to think about how you would describe a file to a colleague. You would tell them **which building to go to and how to get in the door**, then **which room and which filing cabinet** once they are inside. Data Factory splits those two halves deliberately.

**Linked Service — the building and the key.**
This is the connection: *which* storage account, *which* server, *which* website, and the credentials needed to get in. It says nothing about individual files. One linked service can serve dozens of datasets, which is the point — you configure the credentials once.

**Dataset — the specific file, inside that building.**
This points at one thing within a linked service: which container, which folder, which filename, and what format the contents are in. A dataset cannot exist on its own; it always names the linked service it lives inside.

So for the file you will move in Week 3:

| | |
|---|---|
| **Linked Service** | "The storage account `<initials>mod4storage`, authenticated with this account key." |
| **Dataset** | "Within that account: the `tutorial-data` container, the file `FLAT_RCL_POST_2010.zip`, treated as Binary." |

Because a dataset has to name a linked service, you always build the linked service first.

The remaining two terms describe the *work* rather than the *location*:

**Activity — one step.** A single unit of work, such as copying a file or running a stored procedure.

**Pipeline — the whole job.** An ordered group of activities that run together. A copy activity needs a dataset for its source and another for its sink, which is why datasets have to exist before a pipeline can do anything useful.

Every dataset also has a **format** — Binary, DelimitedText, JSON, Parquet, and others. Binary means Data Factory moves the bytes without attempting to parse them. Keep one rule in mind for Week 3:

> When using a Binary dataset in a copy activity, you can only copy **from Binary to Binary**. Formats cannot be mixed across a single copy.

## Steps to Complete Tutorial 2.2

### Step 1: Launch the Studio

> **IMPORTANT** - The Data Factory Studio UI is only supported in **Microsoft Edge** and **Google Chrome**. If you use Safari or Firefox, you may find that tiles fail to load or buttons do nothing at all. If the Studio looks broken, switch browsers before assuming you have made a mistake.

1. In the Azure Portal, navigate to your **Resource Group** and click your **Data factory** resource.
2. On the overview page, click **Launch studio**. A new tab opens at `adf.azure.com`.

<!-- SCREENSHOT: Data Factory overview page in the portal with the Launch studio tile highlighted -->

### Step 2: The hubs

The narrow strip of icons down the far left is how you move around the Studio. Everything you do lives in one of these. You may also see a **Learning center** icon toward the bottom, which links out to Microsoft's own tutorials and templates.

- **Home** — quick-start tiles and recent items. The *Ingest* tile launches the Copy Data tool, which you will use in Week 3.
- **Author** (pencil icon) — where you build pipelines, datasets, and data flows. You will spend most of your time here.
- **Monitor** (gauge icon) — run history. When a pipeline fails, this is where you find out why.
- **Manage** (toolbox icon) — linked services, integration runtimes, and factory-level settings.

<!-- SCREENSHOT: Full Studio window with the left hub rail visible, all four icons labelled -->

### Step 3: Explore the Author hub

Click the **Author** (pencil) icon. The panel that appears has four collapsible sections:

- **Pipelines** — your jobs
- **Datasets** — your file and table definitions
- **Data flows** — visual transformations that run on Spark clusters behind the scenes
- **Power Query** — an alternative transformation surface

All four are empty right now. The **+** button at the top of the panel is how you create new items in any of them.

<!-- SCREENSHOT: Author panel expanded showing the empty Pipelines / Datasets / Data flows / Power Query tree -->

Click **+** > **Pipeline** > **Pipeline** to create an empty one. The main area now shows the **authoring canvas**:

- **Left**: the *Activities* pane, a searchable catalogue grouped by category (Move and transform, Iteration and conditionals, and so on). *Copy data* lives under **Move and transform** — find it now, you will need it next week.
- **Centre**: the canvas where you drag activities and connect them.
- **Bottom**: the properties pane for whichever activity is selected, with tabs like *Source*, *Sink*, *Mapping*, and *Settings*.
- **Right**: pipeline-level properties.

<!-- SCREENSHOT: Empty pipeline canvas with the Activities pane expanded to show "Move and transform > Copy data" -->

Drag a **Copy data** activity onto the canvas and click it. Look at the tabs that appear along the bottom — *Source*, *Sink*, *Mapping*, *Settings*, *User properties*. Do not configure anything yet. Just note that **Source** asks for a dataset and **Sink** asks for a dataset, which is why datasets have to exist before a copy activity can do anything.

<!-- SCREENSHOT: Copy data activity selected on the canvas with the Source/Sink/Mapping tabs visible at the bottom -->

### Step 4: Debug vs. Publish

This distinction catches people out, so it is worth understanding now.

- **Debug** runs your pipeline immediately using the current unsaved draft. Use it constantly while building.
- **Publish all** saves your work to the Data Factory service. Until you publish, your pipelines exist only in your browser session.

The **Publish all** button shows a count of unsaved changes. Your factory has no Git repository attached, so **Publish all** is the only way to save — there is no separate Save button. If you close the tab without publishing, that work is gone.

<!-- SCREENSHOT: Top toolbar showing "Publish all" with a change count badge, alongside the Debug button -->

> **NOTE** - Get in the habit of publishing before you close the tab. Losing an afternoon of pipeline building to an unsaved session is a rite of passage nobody enjoys.

### Step 5: Explore the Manage hub

Click the **Manage** (toolbox) icon. The sections that matter to you:

- **Linked services** — currently empty. In Tutorial 3.1 you will create two here: one pointing at a public HTTP endpoint, one pointing at your storage account.
- **Integration runtimes** — you should see `AutoResolveIntegrationRuntime` already present. The integration runtime is the compute that actually performs the data movement. The auto-resolve default is managed by Azure and picks a region for you; it is all you need for this course. You would only create your own if you needed to reach data behind a corporate firewall.
- **Triggers** — schedules that start pipelines automatically. Not used in this module, but worth knowing they exist.

<!-- SCREENSHOT: Manage hub with Linked services selected (empty) and the left menu showing Integration runtimes and Triggers -->

<!-- SCREENSHOT: Integration runtimes list showing AutoResolveIntegrationRuntime -->

### Step 6: Explore the Monitor hub

Click the **Monitor** (gauge) icon. **Pipeline runs** is empty because you have not run anything. Once you do, each run appears here with a status, a duration, and — critically — an error message you can expand when something fails.

Hovering over a run reveals action icons; the glasses icon opens a detailed activity-level view showing exactly how many rows or bytes moved at each step.

<!-- SCREENSHOT: Monitor hub, Pipeline runs view (empty state is fine here) -->

> **NOTE** - When you get stuck in Weeks 3 and 4, come here first. The error text in Monitor is far more specific than the generic red banner on the canvas.

### Step 7: Keep your practice work

Leave the practice pipeline where it is. An empty pipeline costs nothing to keep — Data Factory only bills you when a pipeline actually runs — and having it around means you can come back and re-read the Source and Sink tabs whenever you need a reminder.

If you want it to persist beyond this browser session, click **Publish all** now. If you would rather not, simply closing the tab discards it, and nothing is harmed either way. You may also find it useful to rename it something like `SCRATCH_practice` so you can tell it apart from the real pipelines you build in Week 3.

The same applies to everything you build across these tutorials: keep it. A working pipeline you built yourself is the best reference you will have, and nothing you create here needs to be torn down later.

## Point to Consider 🤔

- Without looking back: which hub holds linked services, which hub tells you why a pipeline failed, and what is the difference between Debug and Publish?
- Why does Data Factory separate the *connection* (linked service) from the *file* (dataset), rather than defining both in one place?
- What would go wrong if you built a pipeline, hit Debug successfully, and then closed the browser tab?

---

Ensure you understand each step and reach out with any questions!
