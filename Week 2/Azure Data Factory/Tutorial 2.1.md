# Week 2.1 Tutorial - Setting Up Azure Data Factory

**Class,**

In Week 1 you built your Azure environment: a `Resource Group` and a `Storage Account` with containers ready to receive data. What you do not yet have is anything capable of *moving* data. That is the job of `Azure Data Factory` (ADF) — a managed service for building and running data pipelines. Over the rest of this module, ADF is the tool that will pull a file off a public website, unzip it, and load it into a database.

This tutorial deploys the Data Factory itself. You will do it from the command line using an ARM template rather than clicking through the portal, because this is how infrastructure is created in practice.

> **NOTE** - this tutorial builds on Week 1. You should be using the same `Resource Group` from Tutorial 1.1. If you have not completed Week 1, do that first.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Getting Started with Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory)
- [Introduction to Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/introduction)
- [What are ARM templates?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)
- [Azure Cloud Shell Documentation](https://docs.microsoft.com/azure/cloud-shell/overview)

## What is an ARM template?

An **Azure Resource Manager (ARM) template** is a JSON file that declares what a resource should look like. Instead of clicking through fifteen portal screens and hoping you remember the settings next time, you describe the resource once and deploy it with a single command. Two files do the work:

- `template.json` — the shape of the resource and which values are configurable
- `parameters.json` — the specific values for *your* deployment

The `formTemplate.sh` script in this repository fills in the parts of `parameters.json` that are unique to you (your subscription ID and a randomly generated Data Factory name), so you do not have to edit JSON by hand.

## Steps to Complete Tutorial 2.1

### Step 1: Open Cloud Shell and clone the repository

1. Sign in to the [Azure Portal](https://portal.azure.com).
2. Click the **[>_]** button next to the search bar to open Cloud Shell. Select **Bash**.
3. Clone the course repository by running the following command:

   ```azurecli-interactive
   git clone https://github.com/cseferlis/OMDSMod4Homework.git
   ```

4. Navigate into the Week 2 tutorial folder by running the following commands:

```azurecli-interactive
cd OMDSMod4Homework
cd 'Week 2'
```

> **Tip**: If you are unsure what folders are available, use `ls` to list the contents of the current directory.

<!-- SCREENSHOT: Cloud Shell after successful git clone, showing the repo folder listing -->

### Step 2: Run the template script

From inside the Week 2 folder, run the following command:

```azurecli-interactive
bash ./formTemplate.sh
```

This sets your subscription to **Azure for Students**, pulls your subscription ID, generates a unique Data Factory name, and writes both into `./template/parameters.json`. You should see a confirmation message that the template and parameters were created successfully.

<!-- SCREENSHOT: Cloud Shell output of formTemplate.sh showing the success message -->

If you are curious what the script changed, you can inspect the file by running the following command:

```azurecli-interactive
cat ./template/parameters.json
```

### Step 3: Deploy the Data Factory

Run the following command to deploy, replacing `<resource-group-name>` with the name of the Resource Group you created in Tutorial 1.1:

```azurecli-interactive
az deployment group create --resource-group <resource-group-name> --template-file ./template/template.json --parameters ./template/parameters.json
```

As a worked example, a student whose Resource Group is named `cbsomdsrg` would run the following command:

```azurecli-interactive
az deployment group create --resource-group cbsomdsrg --template-file ./template/template.json --parameters ./template/parameters.json
```

> **Note**: The template inherits its region from the Resource Group, so your Data Factory automatically lands in the same region as your storage account. This is why getting the region right in Week 1 mattered.

Deployment takes a couple of minutes. Success looks like a large JSON block with `"provisioningState": "Succeeded"` near the end.

<!-- SCREENSHOT: Cloud Shell showing a successful deployment with provisioningState: Succeeded -->

### Step 4: Troubleshooting

**"The content for this response was already consumed"**, or any error about being in the wrong subscription. Run the following command to list the subscriptions available to you:

```azurecli-interactive
az account list
```

Find the **Azure for Students** subscription in that list, then run the following command to select it:

```azurecli-interactive
az account set --subscription "Azure for Students"
```

Alternatively, you can select it by its ID by running the following command:

```azurecli-interactive
az account set --subscription "<Your Subscription ID>"
```

Then retry the deployment command.

**A region or location error**: your Resource Group may be in a region not permitted by your subscription policy. Recheck **Azure Policy** > **Assignments** > **Allowed resource deployment regions** as described in Tutorial 1.1.

**The script says the parameters were already replaced**: `formTemplate.sh` edits `parameters.json` in place, so running it twice can leave the file in a bad state. Delete the cloned folder and clone the repository again.

### Step 5: Verify in the portal

1. Navigate to your **Resource Group** in the Azure Portal.
2. You should now see a **Data factory (V2)** resource alongside your storage account. Its name will begin with `datafactory` followed by six random characters.
3. Click into it and note the **Launch studio** button on the overview page — that is where Tutorial 2.2 begins.

<!-- SCREENSHOT: Resource Group overview showing both the storage account and the new data factory -->

<!-- SCREENSHOT: Data Factory overview page with the "Launch studio" tile visible -->

Write down the Data Factory name so you can find it again in the portal — the random suffix makes it easy to forget.

## Point to Consider 🤔

- Why would an organization prefer deploying resources from a template over creating them by hand in the portal?
- The script generates a random suffix for the Data Factory name. What problem is that solving?

---

Ensure you understand each step and reach out with any questions!
