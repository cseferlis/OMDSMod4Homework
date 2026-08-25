# Week 12.1 Tutorial - Getting Access to Power BI

**Class,**

Everything left to do is visualisation, and it happens in **Power BI**. Before any of that, you need Power BI running — which is more involved than it sounds, because **Power BI Desktop does not run on macOS**.

This tutorial is entirely about access. Read the section for your platform, get Power BI open and connected to Synapse, and stop. Tutorial 12.2 builds the report.

> **NOTE** - this tutorial builds on Week 11. You need a Synapse workspace with an external table you can query.

## Reference Documents and Tools

- [Download Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/)
- [Power BI service (browser)](https://app.powerbi.com/)
- [Get started with the Windows App](https://learn.microsoft.com/en-us/windows-app/get-started-connect-devices-desktops-apps)
- [Connect to Azure Synapse Analytics from Power BI](https://learn.microsoft.com/en-us/power-bi/connect-data/service-azure-sql-data-warehouse-with-direct-connect)

## Choosing your route

| Your machine | Recommended route |
|---|---|
| Windows | **Power BI Desktop**, installed locally |
| macOS | **Azure Virtual Desktop**, running Power BI Desktop remotely |
| Either, if the above will not work | **Power BI service** in the browser |

The browser version is genuinely usable but its menus differ from Desktop in many places. Tutorial 12.2 gives instructions for both; if you take the browser route, expect to translate a little.

## Steps to Complete Tutorial 12.1

### Step 1a: Windows — install Power BI Desktop

1. Go to the [Power BI Desktop download page](https://powerbi.microsoft.com/en-us/desktop/) and install it.
2. Launch it and sign in with your BU account.

Skip to Step 2.

<!-- SCREENSHOT: Power BI Desktop opening screen after sign-in -->

### Step 1b: macOS — set up Azure Virtual Desktop

Power BI Desktop is Windows-only. You will run it on a hosted Windows desktop and connect from your Mac.

1. Install the **Windows App** from the Mac App Store.
2. Follow Microsoft's [setup guide](https://learn.microsoft.com/en-us/windows-app/get-started-connect-devices-desktops-apps) to connect to your virtual desktop.
3. Sign in with your BU credentials when prompted.

<!-- SCREENSHOT: Windows App on macOS showing the available virtual desktop -->

**Set up folder redirection** so the virtual machine can reach files on your Mac — you will need this to save your report file at the end.

4. In the Windows App connection settings, enable folder redirection and select a local folder to share.

<!-- SCREENSHOT: Folder redirection configuration in the Windows App (see images/hw3c/1.png and 2.png) -->

> **⚠️ IMPORTANT** - Virtual desktop sessions **time out after a period of inactivity, and unsaved work is permanently lost**. Save constantly. This is not a theoretical risk; it happens to someone every term.

### Step 1c: Either platform — the browser version

If neither route above works, go to [app.powerbi.com](https://app.powerbi.com/) and sign in with your BU account. No installation needed.

Be aware that many steps in Tutorial 12.2 are labelled differently here, and the report-building flow goes through a *semantic model* rather than working directly in one application window.

### Step 2: Find your Synapse connection details

Whichever route you took, you need two values from Azure.

1. In the Azure Portal, open your **Synapse workspace**.
2. On the **Overview** page, copy the **Serverless SQL endpoint** — it looks like `<workspace>-ondemand.sql.azuresynapse.net`.
3. Note the **database name** you created in Tutorial 11.2 (for example `RecallsDB`). You can confirm it in Synapse Studio under **Data** > **Workspace**.

<!-- SCREENSHOT: Synapse workspace Overview page with the Serverless SQL endpoint highlighted -->

> **NOTE** - Take the **serverless** endpoint, the one ending `-ondemand`. The workspace also shows a dedicated SQL endpoint; that one points at a pool you do not have.

### Step 3: Connect

**In Power BI Desktop:**

1. Click **Get data** > **More** > **Azure** > **Azure Synapse Analytics SQL**.
2. Paste the serverless endpoint into **Server** and the database name into **Database**.
3. Choose **Import** as the connectivity mode.
4. When prompted for credentials, choose **Microsoft account** and sign in with your BU account.
5. In the Navigator, tick your external table and click **Load**.

<!-- SCREENSHOT: Power BI Get Data dialog with the Synapse server and database entered -->

**In the browser version:**

1. Click **New report** on the landing page.
2. Click **Get data**, search for and select **Azure Synapse Analytics SQL**.
3. Enter the server and database as above, then click **Next**.
4. In the **Choose data** tab, select your external table.
5. Click **Transform Data**.

<!-- SCREENSHOT: Power BI service Get Data flow showing the Synapse connection -->

> **NOTE** - **Import** copies a snapshot of the data into the report file. **DirectQuery** leaves it in Synapse and queries live. Import is the right choice here: your data is not changing, and DirectQuery would send a query to Synapse on every interaction — which, since serverless bills per terabyte scanned, means every click has a cost.

### Step 4: Confirm the data arrived

Switch to **Table view** (the grid icon in the left rail) and check your rows are present with the column names you set in Week 10.

<!-- SCREENSHOT: Power BI Table view showing loaded recall data -->

If the connection fails, work through in this order: is the endpoint the `-ondemand` one, is the database name right and not `master`, and can you still run a query in Synapse Studio against that table.

### Step 5: Save immediately

**Desktop or virtual desktop**: **File** > **Save as**, and save a `.pbix` file. On a virtual desktop, save it to your redirected folder so it lands on your own machine.

**Browser**: your work saves to My workspace automatically, but click **Save** anyway and name the report.

## Point to Consider 🤔

- Import copies data into the report; DirectQuery queries the source on every interaction. Given how serverless SQL is billed, when would DirectQuery still be the right choice?
- Your report will contain a snapshot of the data. What does that mean for someone who opens it in three months?

---

Ensure you understand each step and reach out with any questions!
