# DX604 Mod 4 — Data Management at Scale

**Hello Everybody!**

Welcome to the Azure portion of DX604! This course empowers you with the skills to design and implement data processing workflows essential for informed decision-making organizations and otherwise. To that end, you will build working data pipelines in Microsoft Azure: extracting data from public sources, staging it, loading it into relational and NoSQL databases, transforming it at scale, and finally visualising it.

This repository is organised into two kinds of material.

**1: Weekly tutorials;** These teach you how a particular Azure service works. They are step-by-step, they use a practice dataset, and they are not graded. Work through them as each week is released.

**2: Homework assignments;** These ask you to apply what the tutorials taught to a *different* dataset, with instructions that describe what to accomplish rather than which buttons to click. There are three assignments, due in Weeks 5, 9, and 13. All of them are graded and account for 50% of the course's grade.

That split is deliberate. The tutorials give you the mechanics; the assignments ask whether you can apply them without being walked through. If an assignment step is unclear, the tutorial covering that mechanism will still be there for you — go back and read it.

## How to Work Through This Repository

| Week | Folder | Contents |
|---|---|---|
| 1 | `Week 1` | Setting up your Azure account; creating a storage account |
| 2 | `Week 2` | Deploying Azure Data Factory; learning Data Factory Studio |
| 3 | `Week 3` | Linked services and datasets; copying and unzipping data |
| 4 | `Week 4` | Azure SQL database; the Query Editor; schema mapping |
| **5** | `Week 5` | **Azure Homework 1 — due end of Week 5** |
| 6 | `Week 6` | Azure Cosmos DB |
| 7 | `Week 7` | Loading JSON data |
| 8 | `Week 8` | Querying nested documents |
| **9** | `Week 9` | **Azure Homework 2 — due end of Week 9** |
| 10 | `Week 10` | ADLS Gen2 and Synapse; Mapping Data Flows; Parquet |
| 11 | `Week 11` | Synapse permissions; external tables; serverless SQL |
| 12 | `Week 12` | Power BI; connecting to Synapse; building a report |
| **13** | `Week 13` | **Azure Homework 3 — due end of Week 13** |

Everything you build carries forward. The Resource Group you create in Week 1 holds every service you deploy for the rest of the module, and the pipelines you build in the tutorials remain in place as working references. Nothing needs to be torn down between weeks.

## Before You Get Started!

You will need the **Azure for Students** offer, which gives you a $100 credit without requiring a credit card. Tutorial 1.1 walks you through activating it.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

**Two aspects of Azure consume credit faster than the others.** Read the relevant tutorial before touching either:

- **Data Flow debug sessions** (Tutorial 10.2) run on a Spark cluster with an 8-vCore minimum and bill for as long as the session is open. This is by a wide margin the most expensive thing going through your subscription. **Turn debug off** when you stop working.
- **Provisioned databases** (Tutorials 4.1 and 8.1) bill continuously whether or not you query them. Cosmos DB's free tier must be opted into *at account creation* and cannot be enabled afterwards.

Everything else is close to free at the volumes this course uses.

## Cloning the Repository

Most tutorials run from **Azure Cloud Shell**, which is a Linux terminal built into the Azure Portal and already signed in as you. Tutorial 1.1 explains it in full. To get this repository into Cloud Shell, run the following command:

```azurecli-interactive
git clone https://github.com/cseferlis/OMDSMod4Homework.git
```

Then move into the week you are working on, for example:

```azurecli-interactive
cd OMDSMod4Homework
cd 'Week 2'
```

Deployment scripts and ARM templates live inside the week that uses them, so the paths in each tutorial are relative to that folder.

## Getting Help

Every semester some students are concerned about the lack of in-class instruction on Microsoft Azure. This is by design. You are pursuing a Master's degree in Data Science, and data engineering is a considerable part of ensuring clean and trusted data. You are professionals who have certainly been put into a role that required learning new tools to do the job effectively. That is the approach of this class.

Your Learning Facilitators hold group office hours and are available for individual appointments through BU Virtual Campus. They are here if you are genuinely stuck. Use the tutorials, use the Microsoft documentation linked throughout, and use an LLM to help you understand what you are reading — but work the problems yourself. The students who do gain significantly more from the process.

## A Note on Cost at the End of the Module

Databases and provisioned throughput continue to bill for as long as they exist. Once your assignments are submitted **and graded**, and you are certain you no longer need the resources, you may delete the Resource Group to stop all charges. Do not do this before your grades are returned — you may need to demonstrate your work.

---

Good luck, and enjoy the challenge!
