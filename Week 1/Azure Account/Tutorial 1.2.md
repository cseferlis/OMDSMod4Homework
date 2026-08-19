# Week 1.2 Tutorial - Creating a Storage Account

**Class,**

In Tutorial 1.1 you activated your Azure for Students subscription and created a `Resource Group`. That Resource Group is currently empty. Now we add the first service to it: a `Storage Account`. This will act as your data lake for the semester — every file you extract, unzip, and stage in later weeks lands here first.

> **NOTE** - this tutorial builds on Tutorial 1.1. You should be using the same `Resource Group` you created there. If you have not completed 1.1, do that first.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Create an Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal)
- [Create an Azure Storage Container](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container)
- [Introduction to Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)

## Steps to Complete Tutorial 1.2

### Step 1: Create the Storage Account

1. In the Azure Portal, navigate to the **Resource Group** you created in Tutorial 1.1.
2. Click **Create** and search for **Storage account**.
3. On the **Basics** tab, fill in the following:

   - **Subscription**: Azure for Students
   - **Resource Group**: the one from Tutorial 1.1
   - **Storage account name**: must be globally unique across all of Azure, 3–24 characters, lowercase letters and numbers only. Something like `<initials>mod4storage` works well.
   - **Region**: the **same region as your Resource Group**. Keeping all services in one region avoids data egress charges, which is the main way students burn credit unintentionally.
   - **Performance**: **Standard**
   - **Redundancy**: **Locally-redundant storage (LRS)** — the cheapest option and more than sufficient for this course.

4. Leave every other tab at its defaults.
5. Click **Review + Create**, then **Create**. Deployment takes about a minute.

<!-- SCREENSHOT: Storage account creation Basics tab with all fields filled -->

> **NOTE** - The storage account name is global. If you get a "name is already taken" error, add a few digits to the end. Write down whatever you settle on; you will type it again in Weeks 2 and 3.

### Step 2: Understand what you just created

Before creating a container, it is worth knowing the hierarchy, because Data Factory will ask you for each level separately later on:

```
Storage Account
└── Container            (like a top-level folder)
    └── Blob             (a file — your .zip and .txt will live here)
```

A **blob** is simply a file stored in Azure. **Blob storage** is optimized for unstructured data — exactly what a raw `.zip` download from a government website is.

<!-- SCREENSHOT: Storage account overview page showing the left-hand nav with "Containers" under Data storage -->

### Step 3: Create a Storage Container

You will create **two** containers. One holds the data you work with in these tutorials; the other stays empty for now and gives you a separate place to keep later work. Keeping different datasets in different containers is ordinary good practice and will save you confusion later.

1. In your new Storage Account, go to **Data storage** > **Containers** in the left-hand sidebar.
2. Click **+ Container**.
3. Name it `tutorial-data`. Container names must be lowercase.
4. Leave the access level at its default. Anonymous access is disabled by default and should stay that way — Data Factory authenticates as your account, so nothing needs to be public.
5. Click **Create**.
6. Repeat steps 2–5 to create a second container named `assignment-data`.

<!-- SCREENSHOT: Containers list showing both tutorial-data and assignment-data -->

In Week 2, you will create an Azure Data Factory, the service that actually moves data into these containers.

## Point to Consider 🤔

- Why does a storage account name have to be globally unique when a resource group name does not?
- What is the practical difference between Locally-redundant storage and Geo-redundant storage, and when would the extra cost be justified?

---

Ensure you understand each step and reach out with any questions!
