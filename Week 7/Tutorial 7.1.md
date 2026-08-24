# Week 7.1 Tutorial - Creating a Container and Loading JSON with Data Factory

**Welcome Once Again!**

Last week's tutorial gave you a Cosmos DB account, which is an empty shell. This tutorial creates the **database** and **container** which holds documents, then uses Azure Data Factory to load a JSON file into it.

The Data Factory portion of this tutorial should be pretty familiar to you: linked service, dataset, copy activity, all of these remain the same as in Weeks 3 and 4. What changes is the shape of the data. A JSON document is not a row. It has nested arrays and objects inside of it, and that nesting is the primary reason to use a document database.

> **NOTE** - this tutorial builds on Tutorial 6.1 and on the Data Factory and Storage Account from earlier weeks. You will use the same `Data Factory`, adding a new pipeline for this work.

## Reference Documents and Tools

- [Create a database and container in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/quickstart-portal)
- [Partitioning and horizontal scaling](https://learn.microsoft.com/en-us/azure/cosmos-db/partitioning-overview)
- [Copy and transform data in Azure Cosmos DB for NoSQL](https://learn.microsoft.com/en-us/azure/data-factory/connector-azure-cosmos-db)
- [JSON format in Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/format-json)

## The data

You will build the tutorial dataset yourself. It is small on purpose — small enough to read in full, so that when a query returns the wrong answer you can see why.

Copy the following into a text editor and save it as `vehicle_recalls.json`:

```json
[
  { "campaignId": "21V-101", "make": "Ford", "model": "Explorer", "year": 2019, "status": "Completed",
    "components": [ { "code": "SUSPENSION", "name": "front suspension" }, { "code": "STEERING", "name": "steering column" } ],
    "suppliers": [ { "id": 41, "name": "Bosch" } ] },
  { "campaignId": "21V-102", "make": "Ford", "model": "F-150", "year": 2018, "status": "Open",
    "components": [ { "code": "ELECTRICAL", "name": "wiring harness" } ],
    "suppliers": [ { "id": 77, "name": "Continental" }, { "id": 41, "name": "Bosch" } ] },
  { "campaignId": "22V-210", "make": "Toyota", "model": "Camry", "year": 2020, "status": "Completed",
    "components": [ { "code": "AIRBAG", "name": "driver airbag inflator" } ],
    "suppliers": [ { "id": 12, "name": "Takata" } ] },
  { "campaignId": "22V-211", "make": "Toyota", "model": "RAV4", "year": 2021, "status": "Open",
    "components": [ { "code": "ELECTRICAL", "name": "wiring harness" }, { "code": "AIRBAG", "name": "side curtain airbag" } ],
    "suppliers": [ { "id": 12, "name": "Takata" }, { "id": 41, "name": "Bosch" } ] },
  { "campaignId": "23V-330", "make": "Honda", "model": "Civic", "year": 2022, "status": "Open",
    "components": [ { "code": "BRAKES", "name": "brake master cylinder" } ],
    "suppliers": [ { "id": 58, "name": "Denso" } ] },
  { "campaignId": "23V-331", "make": "Honda", "model": "CR-V", "year": 2020, "status": "Completed",
    "components": [ { "code": "STEERING", "name": "steering column" } ],
    "suppliers": [ { "id": 58, "name": "Denso" }, { "id": 77, "name": "Continental" } ] },
  { "campaignId": "24V-440", "make": "Tesla", "model": "Model 3", "year": 2023, "status": "Open",
    "components": [ { "code": "ELECTRICAL", "name": "battery management software" } ],
    "suppliers": [ { "id": 91, "name": "Panasonic" } ] },
  { "campaignId": "24V-441", "make": "Tesla", "model": "Model Y", "year": 2022, "status": "Completed",
    "components": [ { "code": "SUSPENSION", "name": "front suspension" }, { "code": "BRAKES", "name": "brake master cylinder" } ],
    "suppliers": [ { "id": 91, "name": "Panasonic" } ] }
]
```

Look at what `components` and `suppliers` are: **arrays of objects**, nested inside each document. In a relational database you would need three tables and two joins to represent this. Here it lives in one document, and that is the trade-off a document database makes — richer structure per record, in exchange for the guarantees a relational schema gives you.

Note also that the file is a **JSON array** at its top level. Data Factory will create one Cosmos document per element.

## Steps to Complete Tutorial 7.1

### Step 1: Upload the file to blob storage

1. In the Azure Portal, open your **Storage Account** and go to **Containers** > `tutorial-data`.
2. Click **Upload** and select your `vehicle_recalls.json`.

<!-- SCREENSHOT: Blob container showing vehicle_recalls.json uploaded -->

### Step 2: Create the database

1. Open your **Azure Cosmos DB account** and click **Data Explorer** in the left sidebar.
2. Click **New Database**.
3. Configure it as follows:

   - **Database id**: `mod4tutorial`
   - **Provision throughput**: **check this box** and set **Manual** at **400 RU/s**

4. Click **OK**.

<!-- SCREENSHOT: New Database panel with database id and manual 400 RU/s throughput -->

> **NOTE** - Throughput can be provisioned at the *database* level, where all containers share it, or at the *container* level, where each has its own. Provisioning at the database level is the cheaper choice here because you only need one container. Set it to **Manual**, not Autoscale — autoscale bills up to ten times the floor value if it decides to scale, which is not what you want on a student credit.

### Step 3: Create the container

1. In **Data Explorer**, click **New Container**.
2. Configure it as follows:

   - **Database id**: use existing, `mod4tutorial`
   - **Container id**: `recalls`
   - **Partition key**: `/make`

3. Leave throughput unchecked, since the database provides it.
4. Click **OK**.

<!-- SCREENSHOT: New Container panel showing container id and the /make partition key -->

> **NOTE** - The partition key is written with a leading slash because it is a **path into the document**, not a column name. `/make` means "the top-level `make` field." Remember from 8.1 that this cannot be changed later.
>
> Is `/make` a good choice? It spreads documents across four values here, which is reasonable. A field where nearly every document shares one value would pile them into a single partition; a field unique to every document would scatter related records apart. Both extremes cause problems at scale.

### Step 4: Create the source dataset in Data Factory

1. Open **Data Factory Studio** and click **Author**.
2. Create a new pipeline named `PL_Recalls_To_Cosmos`.
3. Create a new dataset: **Datasets** > **...** > **New dataset** > **Azure Blob Storage** > **JSON**.
4. Configure it as follows:

   - **Name**: `RecallsJsonSource`
   - **Linked service**: `AzureBlob_Mod4` — the one you built in Tutorial 3.1
   - **File path**: browse to `tutorial-data` and select `vehicle_recalls.json`

5. Click **OK**, then use **Preview data** to confirm you can see the records.

<!-- SCREENSHOT: JSON dataset preview showing recall documents with nested arrays -->

> **NOTE** - The format here is **JSON**, not Binary and not DelimitedText. Choosing the right format for the file is the same decision you made in Weeks 3 and 4, and it has the same consequence — the wrong choice produces either a failure or, worse, a silent mangling.

### Step 5: Create the Cosmos DB linked service and sink dataset

1. Go to **Manage** > **Linked services** > **+ New**.
2. Search for **Azure Cosmos DB for NoSQL** and select it.
3. Configure it as follows:

   - **Name**: `CosmosDB_Mod4`
   - **Account selection method**: **From Azure subscription**
   - **Azure subscription**: Azure for Students
   - **Account name**: your Cosmos DB account
   - **Database name**: `mod4tutorial`

4. Click **Test connection**, then **Create**.

   <!-- SCREENSHOT: Cosmos DB linked service with a successful Test connection -->

5. Back in **Author**, create a new dataset: **Azure Cosmos DB for NoSQL**.
6. Name it `RecallsCosmosSink`, use linked service `CosmosDB_Mod4`, and select the `recalls` collection.

### Step 6: Build and run the copy

1. Open `PL_Recalls_To_Cosmos` and drag a **Copy data** activity onto the canvas. Name it `Copy_Recalls_To_Cosmos`.
2. **Source**: `RecallsJsonSource`.
3. **Sink**: `RecallsCosmosSink`. Set **Write behavior** to **Insert**.
4. Click **Debug**.

<!-- SCREENSHOT: Copy activity configured with JSON source and Cosmos sink -->

This dataset is tiny, so the copy finishes almost instantly. That will not be true of a larger file — at 400 RU/s, Cosmos throttles writes above your provisioned rate, and Data Factory retries. The copy still completes; it just takes longer. You can see those retries in the **Monitor** hub detail.

### Step 7: Verify the documents landed

1. Return to the portal, open **Data Explorer**, and expand `mod4tutorial` > `recalls` > **Items**.
2. Click any document. You should see the full JSON, including the nested `components` and `suppliers` arrays.

   <!-- SCREENSHOT: Data Explorer Items view with one document expanded showing nested arrays -->

3. Note the fields Cosmos added that were not in your source: `id`, `_rid`, `_ts`, `_etag`, and others. These are system properties. `id` is the unique document identifier and `_ts` is a timestamp of the last write.

4. Publish your pipeline in the Studio.

### Troubleshooting

- **Test connection fails** — check the account name and that the `mod4tutorial` database exists. Cosmos linked services fail if the database is missing, unlike blob storage which will happily connect to an empty account.
- **The preview shows one document instead of eight** — your JSON file pattern setting is wrong, or the file is not a valid array. Validate the JSON in an editor first.
- **Documents appear but fields are missing** — your dataset format is probably not JSON.
- **Documents loaded twice** — **Insert** appends. Delete the container and recreate it rather than trying to deduplicate.

## Point to Consider 🤔

- You loaded nested arrays into a single document rather than splitting them into related tables. What kinds of question does that make easier to answer, and what kinds does it make harder?
- Every document here has the same fields. Nothing in Cosmos DB requires that. What would break, and what would keep working, if you added a ninth document with an extra field the others lack?

---

Ensure you understand each step and reach out with any questions!
