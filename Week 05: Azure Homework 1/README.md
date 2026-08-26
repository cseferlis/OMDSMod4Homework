# Azure Homework 1 — Building an ETL Pipeline

**Hello Once Again,**

Over the past four weeks you have built a complete data pipeline in Microsoft Azure: an environment, a Data Factory, a pipeline that pulls a compressed file from a public web server and unzips it, a SQL database, a typed table, and a schema-mapped load into that table. You did all of it against the NHTSA **Recalls** dataset.

This assignment asks you to do the same thing against the NHTSA **Complaints** dataset.

The instructions below describe *what* your pipeline must accomplish, not which buttons to click. That is deliberate. The tutorials taught you the mechanics; this assignment asks whether you can apply them to a dataset you have not been walked through. Every Azure interface you need has already been covered in Weeks 1–4, and those tutorials remain in the repository — go back and read them whenever you are unsure.

> **NOTE** - Use the same `Resource Group`, `Storage Account`, `Data Factory`, and `SQL Server` you built in the tutorials. There is no need to create anything new except the pipeline objects and the table specific to this assignment. Use the `assignment-data` container you created in Tutorial 1.2 so this data stays separate from your tutorial work.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## The Data

The National Highway Traffic Safety Administration (NHTSA) is a U.S. government agency committed to ensuring safety on America's roads. By enforcing vehicle performance standards and collaborating with state and local governments, NHTSA works to reduce fatalities, injuries, and economic losses caused by motor vehicle crashes.

The **Complaints** dataset is a public record of every safety-related defect complaint NHTSA has received since 1995. It is collected through a web form and over the phone, which means the data has genuine problems with integrity and consistency — you will meet them first hand. This is not a cleaned teaching dataset, and that is the point.

- **Complaints Data File**: [FLAT_CMPL.zip](https://static.nhtsa.gov/odi/ffdd/cmpl/FLAT_CMPL.zip)
- **Complaints Reference File**: [Import Instructions (Appendix A defines every field)](https://static.nhtsa.gov/odi/ffdd/cmpl/Import_Instructions_Excel_All.pdf)
- **Complaints Data Dictionary**: [CMPL.txt](https://static.nhtsa.gov/odi/ffdd/cmpl/CMPL.txt)
- **Dataset overview**: [NHTSA Datasets and APIs](https://www.nhtsa.gov/nhtsa-datasets-and-apis#complaints)

> **NOTE** - This is a substantially larger file than the Recalls file you used in the tutorials, with a different number of columns and different field definitions. Do not assume anything carries over. Read the reference document.

## What You Must Build

Your pipeline must, using Azure Data Factory only — no manual uploads or downloads:

1. **Extract** the Complaints `.zip` from the NHTSA web server.
2. **Load** it into your Azure Storage account.
3. **Unzip** it into a `.txt` file, still within Azure.
4. **Transform** the `DATEA` column from text into a `date` type — a date, not a datetime.
5. **Stage** the result into a SQL table named `<initials>Complaints`.

Then **query** the loaded data and export the result.

## Requirements

**The table.** Named `<initials>Complaints`, in your Azure SQL database, with columns matching the fields defined in Appendix A of the Complaints Reference File — correct order, appropriate types, sufficient lengths. Use `NVARCHAR` for text columns.

**The transform.** `DATEA` must end up as a `date` type in your table. How you achieve this is up to you; Tutorial 4.3 Step 6 lays out two approaches and their trade-offs.

**The pipeline.** Every step must run inside Data Factory. Downloading the file to your laptop and uploading it by hand does not satisfy the assignment.

**The query.** Once loaded, run:

```sql
SELECT *
FROM <initials>Complaints
WHERE DATEA = CONVERT(Date, GETDATE() - 1)
```

`GETDATE() - 1` means yesterday. If your download is older than that, or you are working over a weekend, there may be no records for yesterday — adjust the offset (`-2`, `-5`, `-7`) until you find the most recent day with data. To find it directly:

```sql
SELECT MAX(DATEA) FROM <initials>Complaints;
```

Expect roughly a couple hundred records per day. If you get thousands, check your query. If you get zero, go further back.

## Submission

Submit the following through Gradescope:

1. **A screenshot of the query executing in the Azure SQL Query Editor**, with the results grid visible.
2. **The query output**, exported as a PDF or CSV.

**IMPORTANT:** Your BU account information must be visible in the top right corner of your screenshots for verification.

Save screenshots as `.png` or `.jpg`. For help with Gradescope submission, refer to the Blackboard page or ask your Learning Facilitator.

## Where to Look When You Get Stuck

Every mechanism this assignment needs was covered in a tutorial:

| If you are stuck on | Read |
|---|---|
| Resource group, region, or storage setup | Tutorials 1.1 and 1.2 |
| Deploying or finding your Data Factory | Tutorial 2.1 |
| Where anything lives in the Studio; Debug vs Publish | Tutorial 2.2 |
| Linked services and datasets | Tutorial 3.1 |
| Copy activities, unzipping, `ZipDeflate` | Tutorial 3.2 |
| SQL server, database, or firewall problems | Tutorial 4.1 |
| Query Editor, `CREATE TABLE`, data types | Tutorial 4.2 |
| Delimiters, schema mapping, loading into SQL | Tutorial 4.3 |

Your Recalls pipeline is still in your Data Factory. It is a working reference — open it and compare when something will not behave.

## A Note on Getting Help

Every semester some students are concerned about the lack of in-class instruction on Microsoft Azure. This is by design. You are pursuing a Master's degree in Data Science, and data engineering is a considerable part of ensuring clean and trusted data. You are professionals who have certainly been put into a role that required learning new tools to do the job effectively. That is the approach of this class.

Your Learning Facilitators are here if you are genuinely stuck, but they will not hand you answers — they have taken this class and built this material, and they will know whether you have done the work. Use the tutorials, use the Microsoft documentation, and use an LLM to help you understand what you are reading. The students who work through the problems themselves gain significantly more from the process.

## Points to Consider 🤔

- How do you use the Complaints Reference File to define a table in Azure SQL Database?
- What is the delimiter in this file, how many columns does it have, and does it have a header row?
- How do you handle rows with missing values?
- What happens when a value in the text file does not conform to the datatype you set for that column?
- What would you do if the number of columns in the file did not match the number in the reference document?
- Your load reports success and the row count looks right. What else would you check before trusting it?

## When You Are Finished

Your SQL database continues to bill for as long as it exists, whether you use it or not. Once your assignment is submitted **and graded**, and you are certain you no longer need the resources, you may delete the Resource Group to stop all charges. Do not do this before your grade is returned — you may need to demonstrate your work.

---

Good luck, and enjoy the challenge!
