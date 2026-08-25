# Week 8.1 Tutorial - Querying Nested Data in Cosmos DB

**Welcome Once Again!**

You have eight recall documents in a Cosmos DB container. This week's tutorial focuses on getting answers out of them.

Cosmos DB for NoSQL uses a query language that looks like SQL and is not SQL. The differences are small in appearance and large in consequence, and nearly all of them come down to one fact: a document **can** contain arrays, and a table cell **cannot.**

> **NOTE** - this tutorial builds on Tutorial 8.2. You need the `recalls` container populated with documents.

## Reference Documents and Tools

- [Getting started with SQL queries in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/query/getting-started)
- [Tutorial: Query Azure Cosmos DB for NoSQL](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/tutorial-query)
- [JOIN in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/query/join)
- [Request Units in Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/request-units)

## Steps to Complete Tutorial 8.1

### Step 1: Open a query window

1. In your Cosmos DB account, open **Data Explorer**.
2. Expand `mod4tutorial` > `recalls`.
3. Click **New SQL Query**.

<!-- SCREENSHOT: Data Explorer with a New SQL Query tab open against the recalls container -->

### Step 2: The basic shape of a query

Run this:

```sql
SELECT TOP 5 c.campaignId, c.make, c.model FROM recalls AS c
```

Three things differ from the T-SQL you wrote in Week 4:

- **The alias is mandatory.** `recalls AS c`, and then every field is `c.make`, not bare `make`. Cosmos requires the alias because a document has no fixed shape — the alias tells it what you are projecting from.
- **`TOP` takes no parentheses** and there is no `LIMIT`.
- **The `FROM` names the container**, and there is only ever one. You cannot join two containers.

That last point deserves emphasis. In a relational database, `JOIN` combines rows from different tables. In Cosmos DB, `JOIN` does something else entirely, which is Step 4.

### Step 3: Filtering

```sql
SELECT c.campaignId, c.model FROM recalls AS c WHERE c.status = "Open"
```

Note the **double quotes** around the string. Cosmos DB queries are JSON-flavoured; single quotes also work, but double quotes are the convention you will see in the documentation.

Try a few more:

```sql
-- Numeric comparison
SELECT c.model, c.year FROM recalls AS c WHERE c.year >= 2021

-- Count all documents
SELECT VALUE COUNT(1) FROM recalls AS c

-- Substring match
SELECT c.campaignId FROM recalls AS c WHERE CONTAINS(c.model, "Model")
```

`SELECT VALUE` returns a bare value rather than an object wrapping it. Without `VALUE`, the count comes back as `[{"$1": 8}]`; with it, you get `[8]`.

<!-- SCREENSHOT: Query results pane showing the output of a filtered query -->

### Step 4: JOIN, which is not what you think

This is the important part of the tutorial.

Each document has a `components` array holding several objects. Suppose you want every recall involving a wiring harness. The field you want to filter on is not on the document — it is inside an array on the document.

```sql
SELECT c.campaignId, c.make, c.model
FROM recalls AS c
JOIN p IN c.components
WHERE p.name = "wiring harness"
```

Read `JOIN p IN c.components` as: *for each document, unroll its `components` array, and let `p` be one element at a time.* A document with three components temporarily becomes three rows, each with the same document fields and a different `p`. The `WHERE` then filters those.

This is a **self-join within a document**, not a join between containers. Cosmos DB calls it an intra-document join for that reason.

You should get two results — the Ford F-150 and the Toyota RAV4.

<!-- SCREENSHOT: JOIN query returning the two matching recalls -->

> **NOTE** - Leave off the `WHERE` and run it again. You will get more rows than you have documents, because each array element produces one. That is the clearest way to see what the unrolling actually does.

### Step 5: Write one yourself

The `suppliers` array works the same way. Write a query that returns the `campaignId` and `make` of every recall involving the supplier **Bosch**.

Start from the structure above and change what needs changing. You should get three results.

Then try one that needs a little more thought: every recall that is both `Open` **and** involves an airbag component. Combining a document-level condition with an array-level condition in the same `WHERE` is exactly the pattern you will reach for most often.

<!-- SCREENSHOT: The suppliers JOIN query and its results -->

### Step 6: Watch what queries cost

Cosmos DB tells you the price of every query, which no relational database does by default.

1. Run any query.
2. Look at the **Query Stats** tab beside the results.
3. Find **Request Charge**, measured in RUs.

<!-- SCREENSHOT: Query Stats tab showing the request charge in RUs -->

Compare a few:

- `SELECT * FROM recalls AS c` — reads everything
- `SELECT c.campaignId FROM recalls AS c WHERE c.make = "Ford"` — filters on the **partition key**
- `SELECT c.campaignId FROM recalls AS c WHERE c.model = "F-150"` — filters on a non-partition-key field

The second is a single-partition query: Cosmos knows exactly where to look. The third is a cross-partition query, which must check every partition. On eight documents the difference is trivial. On eight hundred million it is the difference between a working application and an unusable one, and it is decided entirely by the partition key you chose before loading any data.

### Troubleshooting

- **"Syntax error, incorrect syntax near ..."** — usually a missing alias. Every field reference needs one.
- **A query returns nothing when you expect results** — check your string case. Comparisons are case-sensitive, so `"Open"` and `"open"` are different values.
- **`JOIN` returns more rows than expected** — that is the array unrolling. It is working correctly.
- **Query Stats tab is missing** — it appears only after a query runs successfully.

## Point to Consider 🤔

- `JOIN p IN c.components` turns one document into several rows. If a document had two arrays and you joined both in one query, how many rows would a single document produce?
- The same question — "which recalls involve a wiring harness" — would require a join across two tables in a relational database and an intra-document join here. Which model would you rather maintain if the list of components per recall kept growing?
- Cosmos DB shows you the RU cost of every query. What would change about how you write SQL if your relational database did the same?

---

Ensure you understand each step and reach out with any questions!
