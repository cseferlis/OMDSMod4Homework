# Week 6.1 Tutorial - Deploying Azure Cosmos DB

**Hello and Welcome!**

Everything you have built so far has been relational. You defined a table with fixed columns and types, and every row had to fit that shape. That works well when your data is uniform, but it breaks down when it is not.

This week we move to **NoSQL**. Azure Cosmos DB is Microsoft's globally distributed, multi-model database — it supports document, key-value, graph, and wide-column models, and replicates to nodes worldwide in single-digit milliseconds. It is the database behind services like the Xbox Live network.

This tutorial deploys a Cosmos DB account and explains the two concepts that govern everything you do with it: **request units** and **partition keys**.

> **NOTE** - this tutorial builds on the Azure environment you created in Weeks 1–4. You will use the same `Resource Group` and, later, the same `Data Factory`.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Welcome to Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction)
- [Quickstart: Create an Azure Cosmos DB account in the portal](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/quickstart-portal)
- [Azure Cosmos DB lifetime free tier](https://learn.microsoft.com/en-us/azure/cosmos-db/free-tier)
- [Request Units in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/request-units)
- [Partitioning and horizontal scaling](https://learn.microsoft.com/en-us/azure/cosmos-db/partitioning-overview)

## Two concepts you need first

### Request Units (RU/s)

Cosmos DB does not bill you for CPU or memory. It bills you for **throughput**, measured in Request Units per second. An RU is a normalised unit of cost covering the processor, memory, and IOPS a request consumes — reading a small document costs roughly 1 RU, and writes and complex queries cost more.

You reserve a number of RU/s and pay for that reservation **continuously**, whether or not you run a single query. This is the important difference from the storage account you have been using, which costs almost nothing when idle. A Cosmos DB container left provisioned all semester will quietly consume your credit.

> **NOTE** - Azure Cosmos DB has a **lifetime free tier** giving you the first 1000 RU/s and 25 GB of storage free for the life of the account. There are two catches, and both matter:
> - You must **opt in when the account is created**. It cannot be switched on afterwards.
> - You may have **only one free tier account per subscription**, and it is not available for serverless accounts.
>
> Enable it. Step 1 below explains how.

### Partition keys

A relational table lives on one machine. A Cosmos container is spread across many, and the **partition key** is the field Cosmos uses to decide which machine each document goes on.

A good partition key spreads documents fairly evenly and matches how you query. A poor one puts most documents in one partition, creating a bottleneck that no amount of RU/s will fix. You choose it when you create the container, and **you cannot change it afterwards** — you would have to recreate the container and reload the data.

## Steps to Complete Tutorial 6.1

### Step 1: Check the free tier setting before you deploy

The free tier cannot be enabled after an account exists, so confirm it is switched on *before* deploying rather than discovering the problem afterwards.

1. Open **Cloud Shell** and navigate into the Week 8 tutorial folder.
2. Run the following command to check the setting:

   ```azurecli-interactive
   grep enableFreeTier ./template/template.json
   ```

3. It should report `"enableFreeTier": true`. If it reads `false`, open the file with `code ./template/template.json`, change it, save with **Ctrl+S**, and close with **Ctrl+Q**.

<!-- SCREENSHOT: Cloud Shell showing the grep result with enableFreeTier set to true -->

> **NOTE** - You may have only one free tier Cosmos DB account per subscription. If you already have one, this deployment will fail. In that case set the value to `false`, accept that this account will bill for its provisioned throughput, and read Step 4 carefully — you will want to delete the account promptly when the module ends.

> **NOTE** - Reading a template before running it is a habit worth building generally. A template is someone else's decisions about your infrastructure, and some of those decisions cost money.

### Step 2: Deploy the account

1. Run the following command to generate your parameters file:

   ```azurecli-interactive
   bash ./formTemplate.sh
   ```

   This generates a globally unique account name of the form `cosmosdb<random>` and writes it into `./template/parameters.json`.

2. Run the following command to deploy, replacing `<resource-group-name>` with your Resource Group:

```azurecli-interactive
az deployment group create --resource-group <resource-group-name> --template-file ./template/template.json --parameters ./template/parameters.json
```

   Cosmos DB accounts take several minutes to provision.

<!-- SCREENSHOT: Cloud Shell showing the Cosmos DB deployment succeeded -->

If you see the "content for this response was already consumed" error, run the following command and retry:

```azurecli-interactive
az account set --subscription "Azure for Students"
```

### Step 3: Confirm the account and its API

1. In the portal, open your **Resource Group** and click the new **Azure Cosmos DB account**.
2. On the **Overview** page, confirm the API is **Core (SQL)** — also called the NoSQL API. This is the document API, and it lets you query JSON documents using SQL-like syntax.
3. Check whether the overview shows the account as free tier. If it does not, revisit Step 1.

<!-- SCREENSHOT: Cosmos DB account overview showing the Core (SQL) API and free tier discount status -->

> **NOTE** - Cosmos DB supports several APIs (MongoDB, Cassandra, Gremlin, Table). The API is fixed at account creation. We use Core (SQL) because it is the native document API and its query language will look familiar after Week 4.

### Step 4: Watch what this costs

Whether or not you got the free tier, build the habit now:

1. Open your Cosmos DB account and go to **Cost Management** in the portal, or search for **Cost analysis** on your subscription.
2. Filter by your Resource Group and look at the daily run rate.

Provisioned throughput bills by the hour, continuously. At the 400 RU/s minimum for a dedicated container, a Cosmos DB account left running for a month costs roughly the same as a modest streaming subscription — and unlike the storage account, idling does not make it cheaper. With free tier enabled and throughput at or below 1000 RU/s, it should cost you nothing.

## Point to Consider 🤔

- Cosmos DB bills for reserved throughput rather than for queries actually run. What does that tell you about the kind of workload it is designed for?
- The partition key cannot be changed after a container is created. Why would a distributed database impose that restriction when a relational database lets you add an index at any time?

---

Ensure you understand each step and reach out with any questions!
