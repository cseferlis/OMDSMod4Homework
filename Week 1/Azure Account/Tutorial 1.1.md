# Week 1.1 Tutorial - Setting up your Azure for Students Account

**Class,**

Welcome to Module 4. Over the next several weeks you will build a working data pipeline in Microsoft Azure. Before any of that can happen, you need an Azure environment to build it in. This tutorial walks you through activating your student subscription, confirming which regions you are permitted to deploy into, and creating the `Resource Group` that will hold every service you create this semester.

> **NOTE** - Everything you create in these tutorials will be reused. The Resource Group you create here is the same one you will use in Weeks 2, 3, and 4. Write down the names you choose.

> For this course, you will use the "Azure for Students" offer provided by Microsoft. This offer allows for a $100 credit that can be replenished once a year as long as a student email address is being used. You will be expected to manage your budget. By adhering closely to the instructions outlined in the homework assignments, you will remain within the $100 credit limit. However, any expenses incurred beyond this allocation will be your responsibility.

## Reference Documents and Tools

- [Azure for Students](https://azure.microsoft.com/en-us/free/students/)
- [Azure Portal](https://portal.azure.com/)
- [How to Create an Azure Resource Group](https://www.educative.io/answers/how-to-create-an-azure-resource-group-from-the-azure-portal)
- [Azure Cloud Shell Documentation](https://docs.microsoft.com/azure/cloud-shell/overview)

## Steps to Complete Tutorial 1.1

### Step 1: Activate your Azure for Students subscription

The student offer gives you free access to the services used throughout this course without requiring a credit card.

1. Visit the [Azure for Students page](https://azure.microsoft.com/en-us/free/students/).
2. Click **Activate Now** or **Start Free**.
3. Register using your `@bu.edu` email address. Using a personal address will not grant you the student benefits.
4. Complete the registration prompts.

If you already activated this offer for a prior course, you do not need to do it again — sign in and confirm the subscription is still active.

<!-- SCREENSHOT: Azure for Students landing page with the "Activate Now" button visible -->

### Step 2: Confirm you are in the right subscription

Student accounts sometimes carry more than one subscription (for example, a leftover free trial). Nearly every deployment error later in the course traces back to being in the wrong one.

1. Sign in to the [Azure Portal](https://portal.azure.com/).
2. Click your account name in the top right and select **Switch directory** if you belong to more than one tenant.
3. Search for **Subscriptions** in the top search bar and confirm **Azure for Students** is listed and shows a status of *Active*.

<!-- SCREENSHOT: Subscriptions blade showing "Azure for Students" with Active status -->

### Step 3: Find your allowed deployment regions

Azure Student subscriptions are governed by a policy that restricts which regions you may deploy into. This list differs between accounts. Choosing a region outside this list is the single most common cause of a failed deployment in Weeks 2 and 4, so check it now rather than later.

1. Navigate to **Azure Policy** > **Authoring** > **Assignments**:

   https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyMenuBlade/~/Assignments

2. Click the assignment named **Allowed resource deployment regions**.
3. Find the **Allowed locations** parameter value.
4. Note down one region from that list. You will use it for every resource you create in this module.

<!-- SCREENSHOT: Azure Policy assignments page — can reuse images/hw1a/policy.png -->

<!-- SCREENSHOT: Allowed locations parameter values — can reuse images/hw1a/region.png -->

### Step 4: Create your Resource Group

A Resource Group is a logical container for related Azure services. Grouping everything for this course together makes it easy to find your work, track spend, and delete everything at once when the semester ends.

1. In the Azure Portal, search for **Resource groups** and click **Create**.
2. Select the **Azure for Students** subscription.
3. Give it a meaningful name, such as `Mod4_Homework` or `<initials>mod4rg`, that you will recognize later in the portal.
4. Set the **Region** to one of the allowed locations you found in Step 3.
5. Click **Review + Create**, then **Create**.

<!-- SCREENSHOT: Resource Group creation blade with subscription, name, and region filled in -->

### Step 5: Open Cloud Shell

**Azure Cloud Shell** is a command line that runs inside your browser, built into the Azure Portal itself. Rather than installing the Azure CLI on your own machine and authenticating it, you click a button and get a terminal that is already signed in as you, already pointed at your subscription, and already has the tooling installed.

A few things worth understanding about it:

- **It is a real Linux environment**, not a simulation. You can run `ls`, `git clone`, edit files, and run scripts exactly as you would on any Linux machine.
- **It is already authenticated.** Commands beginning with `az` — the Azure CLI — act on your account without you having to log in or paste any keys. This is why the tutorials use Cloud Shell rather than asking you to install anything.
- **It needs a small amount of storage.** The first time you open it, Azure will offer to create a storage account to persist your home directory between sessions. Accept this. The cost is a few cents a month and it means files you create do not vanish when you close the tab.
- **It is not tied to one computer.** Open the portal from a different machine and your Cloud Shell home directory is still there.

Almost everything in these tutorials could also be done by clicking through the portal. We use the command line in places because that is how infrastructure is actually managed in practice — it is repeatable, reviewable, and can be scripted, which pointing and clicking is not.

1. Click the **[>_]** button next to the portal search bar to open Cloud Shell.
2. Select **Bash** as the environment, creating storage if prompted. Choose the **Azure for Students** subscription when asked.
3. Confirm it is working by running the following command:

```azurecli-interactive
az account show
```

You should see a block of JSON output that names your subscription. If the wrong subscription appears, run the following command to set it explicitly:

```azurecli-interactive
az account set --subscription "Azure for Students"
```

<!-- SCREENSHOT: Cloud Shell pane open in the portal showing az account show output -->

> **Note**: You may use **Bash** or **PowerShell** by changing the environment in the Cloud Shell pane's dropdown. These tutorials assume Bash.

Your Resource Group is empty for now. In Tutorial 1.2 you will put a storage account inside it.

## Point to Consider 🤔

- Why does Azure restrict which regions a student subscription can deploy to, and what would happen to your costs if you spread resources across several regions?

---

Ensure you understand each step and reach out with any questions!
