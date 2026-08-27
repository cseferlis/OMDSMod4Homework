# Azure Homework 2 — NoSQL with Cosmos DB

**Hello Everyone,**

Throughout the last three weeks, you deployed a Cosmos DB account, created a database and container, loaded a JSON dataset into it with Data Factory, and learned to query nested arrays with the Core (SQL) API.

This assignment asks you to apply that work. The instructions describe what to accomplish rather than which buttons to press — every interface you need was covered in Tutorials 6.1 through 8.1, and those tutorials remain in the repository.

**Due: end of Week 9.**

> **NOTE** - Use the same `Resource Group`, `Data Factory`, and `Cosmos DB account` from the Week 8 tutorials. Create a new pipeline for this assignment rather than modifying the tutorial one.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## The Data

You will work with the **TMDB 5000 Movies** dataset — a public collection of metadata for 5,000 films, including budget, revenue, runtime, genres, keywords, and production companies. Genres, keywords, and production companies are stored as nested arrays of objects, which is what makes this a natural fit for a document database rather than a relational one.

- **Dataset**: [tmdb_5000_movies.json](https://mod4.blob.core.windows.net/hw2/tmdb_5000_movies.json)

## What You Must Build

1. A Cosmos DB **database** with id `omdsmod4` and a **container** with id `movies`, using `status` as the partition key and throughput set to **Manual at 400 RU/s** (or the free tier allowance, if you enabled it).
2. An **Azure Data Factory pipeline** that retrieves the JSON file from the link above and loads it into the `movies` container. The pipeline must do the retrieval — downloading the file yourself and uploading it by hand does not satisfy the assignment.
3. **Two queries**, run in the Data Explorer, described below.

## The Queries

**Query 1 — run this exactly as written:**

```sql
SELECT c.title 
FROM movies AS c 
JOIN p IN c.keywords 
WHERE p.name = "artificial intelligence"
```

This should return **26 titles**. If your count matches, your data loaded correctly. If it does not, the problem is almost certainly in the load rather than the query — check your document count before rewriting anything.

**Query 2 — write this one yourself:**

Find the films produced by the production company **"Dentsu"**. Start from the structure below and complete it. There are **12 matching records**.

```sql
SELECT c.title 
FROM movies AS c 
JOIN 
WHERE 
```

The `production_companies` array has the same shape as `keywords`. Tutorial 8.1 Step 4 explains the construct.

## Submission

Submit the following through Gradescope:

1. **A screenshot of Query 1 executing**, with results visible.
2. **A screenshot of Query 2 executing**, with results visible.

**IMPORTANT:** Ensure your BU account information is visible in the top right corner of your screenshots for verification.

Save screenshots as `.png` or `.jpg`. For help with Gradescope submission, refer to the Blackboard page or ask your Learning Facilitator.

> **IMPORTANT** - Do not delete your Cosmos DB resources after submitting. Leave the database active until your grade is returned.

## Managing Your Credit

Cosmos DB bills for **provisioned throughput continuously**, whether you query it or not. This is different from the storage account and Data Factory you have used so far, which cost close to nothing when idle.

- If you enabled the **free tier** when creating your account, 1000 RU/s and 25 GB are free for the life of the account and this assignment should cost you nothing.
- If you did not, 400 RU/s runs continuously against your credit. Check **Cost analysis** in the portal and keep an eye on the daily rate.
- Do not set throughput to Autoscale. It bills up to ten times the floor value.

## Where to Look When You Get Stuck

| If you are stuck on | Read |
|---|---|
| Deploying the account, free tier, RU/s | Tutorial 6.1 |
| Databases, containers, partition keys | Tutorial 7.1 |
| Data Factory linked services and JSON datasets | Tutorial 7.1 |
| Query syntax, aliases, joining into arrays | Tutorial 8.1 |
| Anything about the Studio interface itself | Tutorials 2.2 and 3.1 |

## Points to Consider 🤔

- Which dataset format must you select in Data Factory for JSON data, and what happens if you choose wrongly?
- How would you confirm that all 5,000 documents loaded before concluding a query is wrong?
- `production_companies` is an array of objects. What does that require of your query that a simple `WHERE` clause could not do?
- Your queries consume request units. How would you find out what a given query costs, and why does that matter more here than in Azure SQL?

---

Good luck, and enjoy working with Cosmos DB!
