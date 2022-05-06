# Setting up a publicly available COVID Policy Modelling simulation cluster and web-ui

This tutorial will take you through deploying a cluster for running simulations through the COVID Policy Modelling web-ui.

## Table of contents

* [Assumptions](#assumptions)
* [Process](#process)
  * [Setup and authentication](#setup-and-authentication)
  * [Global configuration](#global-configuration)
  * [Blob store](#blob-store)
  * [Secrets](#secrets)
  * [Database server](#database-server)
  * [Database](#database)
  * [Actions Runner Kubernetes cluster](#actions-runner-kubernetes-cluster)
  * [Actions Runner controller](#actions-runner-controller)
  * [Control plane](#control-plane)
  * [Actions Runner](#actions-runner)
  * [Web UI](#web-ui)
  * [Testing](#testing)
  * [Tidying up](#tidying-up)

## Assumptions

This tutorial assumes you have a basic knowledge of using:

* [git](https://git-scm.com/) - cloning, committing, pushing and pulling
* [GitHub](github.com/) - you should have an account, and know how to create repositories

It also assumes you have a domain for the front-end of the service, and an SSL certificate (**not** self-signed) for that domain.
If you prefer, you can instead follow [SETUP-LE.md](SETUP-LE.md) which does not require this, but which is slightly more complicated.

## Process

### Setup and authentication

1. Create a GitHub [organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch).

1. Copy this repository, by clicking "Use this template" on [this page](https://github.com/covid-policy-modelling/infrastructure-template). Select your organization as the owner, and enter *infrastructure* as the name. Ensure the repository is private.

1. Clone your new repository, and open a terminal inside your local working copy.

1. If you do not already have one, sign up for an Azure Subscription. Your organisation may be able to help you with this, or you can [sign up directly](https://azure.microsoft.com/en-gb/account/).

1. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

1. Authenticate with Azure:

   1. Run `az login`.
   1. Run `az account list --output table`.
   1. Find and pick the appropriate subscription.
   1. Run `az account set --subscription <Subscription name>`.

1. Run `./scripts/bootstrap-backend`. This should create a file called `backend.tf`, with contents like the following (where `0000` will be replaced with a random number):

      ```
      resource_group_name  = "terraform"
      storage_account_name = "tfstate0000"
      container_name       = "tfstate"
      ```

1. Go to [Azure Portal](https://portal.azure.com/#home) and locate your subscription.

1. In the left sidebar, select "Resource groups". You should see a list of Resource Groups, including one named *terraform*. Select it, and you should see a list of resources. There should be one resource listed, named *tfstate0000* of type *Storage account*.

1. Install [Terraform CLI](https://www.terraform.io/downloads.html).

1. Install [jq](https://stedolan.github.io/jq/download/).

1. Install [mysql client](https://www.mysql.com/). (Note there is a [known issue with v8.0.27](https://docs.microsoft.com/en-gb/azure/mysql/single-server-whats-new#october-2021) that will prevent connections. Please use an alternative version.)

### Global configuration

1. Change to the *configuration* service for the *production* environment and run:

    ```bash
    cd production/configuration
    ```

1. Initialise the service by running:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Run `terraform validate`. This should confirm that your configuration is valid.

1. In Azure Portal, take a note of the username which appears at the top-right of the screen next to your profile icon. It should be of the form *user@domain*

1. Edit the file `variables.tf`. In the block which begins `variable "admin_principal_names" {`, add the following line, using your username from the previous step:

      ```terraform
      default = ["user@domain"]
      ```

1. Run `terraform plan`. This should tell you that it needs to create one resource.

1. Run `terraform apply`. This should show you the same output as before, then ask if you'd like to go ahead and create the resources. Type *yes*. Terraform will begin creating resources - this may take some time.

1. In the Azure Portal, return to the *terraform* resource group. You should now see a new resource *tfstate0000-config-prod* of type *Key vault*.

### Blob store

1. Change to the *blob-store* service for the *production* environment: Run `cd ../blob-store`.

1. Initialise the service by running:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Edit the file `variables.tf` in a similar fashion to before to add a `default` to the `resource_group_prefix` variable. This value should be short, but specific to your organisation/deployment, as it is used in forming names which must be **globally** unique in Azure.

      ```terraform
      default = ...
      ```

1. Run `terraform plan`. This should tell you that it needs to create six resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the Azure Portal, under "Resource groups", you should now see a new resource group named *&lt;prefix&gt;-model-prod-rg*. Select it, and it should contain one resource named *&lt;prefix&gt;modelprodact*, of type *Storage account*.

### Secrets

1. Change to the *bootstrap-configuration-service* service for the *production* environment:

    ```bash
    cd ../bootstrap-configuration-service
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Run `cp tfvars.template .auto.tfvars`. You will then edit this file to populate it with various secrets that are needed for the cluster.

1. Create an [GitHub OAuth app](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app), by going to the "Settings" for your organisation, followed by "Developer Settings", "OAuth Apps", then "New OAuth App" to create the application.

   1. Enter something meaningful for "Application name" (this will be displayed to users).

   1. Enter your domain name for _Homepage URL_.

   1. For _Authorization callback URL_, enter `https://<domain>/api/callback`.

   1. Click "Register application"

   1. Click "Generate a new client secret"

1. Add the "Client Secret", to your `.auto.tfvars` as the value for `oauth_client_secret`.

1. Take a note of the "Client ID" for later use.

1. Create a GitHub machine user using the normal [GitHub signup process](https://github.com/signup). This is separate from any existing GitHub account you have, and limits the scope of exposure in the case of any security issues, as well as facilitating multiple developers to work on the system. You will need to use a separate email address for the account.

1. Create a [GitHub Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) (PAT) for the machine user with the scope "repo". Add this to your `.auto.tfvars` as the value for `github_actions_runner_pat`. Remember to put quotes around the values you are setting.

1. Create another PAT with the scope "repo". Add this to your `.auto.tfvars` as the value for `github_api_pat`.

1. Create another PAT with the scope "read: packages". Add this to your `.auto.tfvars` as the value for `github_container_ui_install_pat`.

1. Fill in `certificate_basename` in `.auto.tfvars` with a value based on your domain name e.g. *host-name.ac.uk* should result in *host-name_ac_uk*

1. Copy your SSL certificate and corresponding private key into the current folder, naming them based on your `certificate_basename`, e.g. `host-name_ac_uk.pem` and `host-name_ac_uk-key.pem`

1. Generate a random value, e.g. by running `openssl rand -base64 32`, and use this to fill in the value of `actions_runner_vm_admin_password` in `.auto.tfvars`

1. Repeat this, generating different passwords for:
   - [ ] `mysql_admin_password`
   - [ ] `mysql_appuser_password`
   - [ ] `runner_shared_secret`
   - [ ] `webhook_shared_secret`
   - [ ] `session_secret`
   - [ ] `oauth_secret`

1. Run `terraform plan`. This should tell you that it needs to create twelve resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the [Azure Portal](https://portal.azure.com/#home), return to the Key Vault *tfstate0000-config-prod*. Select "Secrets" in the left-hand menu, and you should see 12 secrets listed corresponding to the values you have entered. You can select any of these, then select the row under "CURRENT VERSION" (a string of hexadecimal digits), and press "Show Secret Value" to see the value.

### Database server

1. Change to the *database-server* service for the *production* environment:

    ```bash
    cd ../database-server
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Edit the file `variables.tf` in a similar fashion to before to add a `default` to the `resource_group_prefix` variable as you did for *blob-store*. We recommend using the same value.

1. Run `terraform plan`. This should tell you that it needs to create three resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the Azure Portal, under "Resource groups", you should now see a new resource group named *&lt;prefix&gt;-database-prod-rg*. Select it, and it should contain one resource named *&lt;prefix&gt;-database-prod*, of type *Azure Database*.

### Database

1. Change to the database service for the production environment:

    ```bash
    cd ../database
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Edit the file `variables.tf` in a similar fashion to before to add a `default` to the `resource_group_prefix` variable as you did for *blob-store*. We recommend using the same value.

1. Run `terraform plan`. This should tell you that it needs to create three resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

### Actions Runner Kubernetes cluster

1. Change to the *actions-runner-aks* service for the *production* environment:

    ```bash
    cd ../actions-runner-aks
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Edit the file `variables.tf` in a similar fashion to before to add a `default` to the `resource_group_prefix` variable as you did for *blob-store*. We recommend using the same value.

1. Run `terraform plan`. This should tell you that it needs to create three resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the [Azure Portal](https://portal.azure.com/), under "Resource groups", you should now see a new resource group named *&lt;prefix&gt;-runner-prod-rg*. Select it, and it should contain one resource named *&lt;prefix&gt;-runner-prod-aks* of type Kubernetes service.

### Actions Runner controller

1. Change to the *actions-runner-controller* service for the *production* environment:

    ```bash
    cd ../actions-runner-controller
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Run `terraform plan`. This should tell you that it needs to create three resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the [Azure Portal](https://portal.azure.com/), select your *&lt;prefix&gt;-runner-prod-aks* service. In the left-hand menu select "Workloads", and you should see a list of deployments including "actions-runner-controller" and "actions-runner-controller-github-webhook-server".

### Control plane repo

1. Create a control-plane on GitHub, by clicking "Use this template" on the [control-plane-template](https://github.com/covid-policy-modelling/control-plane-template). Select your GitHub Organization as the owner, and enter *control-plane-production* as the name. Ensure the repository is **Private**.

   1. Go to "Settings", then "Manage access" and "Invite teams or people". Enter the name of your machine user.

   1. As the machine user, accept the invitation.

   1. As your normal GitHub user (**not** the machine user), on the "Manage access" page, change the role for your machine user to *Admin*

### Actions Runner

1. Change to the *actions-runner-runner* service for the *production* environment:

    ```bash
    cd ../actions-runner-runner
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Edit the file `variables.tf` in a similar fashion to add a `default` value to the `control_repo_nwo` variable with the value based on your GitHub organization, e.g. *my-org/control-plane-production*

1. Run `terraform plan`. This should tell you that it needs to create two resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

### Control plane

1. Change to the *control-plane* service for the *production* environment:

    ```bash
    cd ../control-plane
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Create a control-plane on GitHub, by clicking "Use this template" on the [control-plane-template](https://github.com/covid-policy-modelling/control-plane-template). Select your GitHub Organization as the owner, and enter *control-plane-production* as the name. Ensure the repository is **Private**.

   1. Go to "Settings", then "Manage access" and "Invite teams or people". Enter the name of your machine user.

   1. As the machine user, accept the invitation.

   1. As your normal GitHub user (**not** the machine user), on the "Manage access" page, change the role for your machine user to *Admin*

1. Create a [PAT](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) for yourself (**not** the machine user) with the scope `repo`.

1. Create a `.auto.tfvars.json` file with the following contents:

      ```
      {
          "github_admin_pat": "<token from previous step>"
      }
      ```
1. Edit the file `variables.tf` to add a `default` to the `github_organization` variable with the name of your GitHub Organization, i.e. `default = "NameOfMyGitHubOrg"`.

1. Similarly, add a `default` to the `build_container_user` variable with the name of your machine user.

1. Also, add a `default` to the `proxy_url` variable with your domain name.

1. Run `terraform plan`. This should tell you that it needs to create eight resources.

1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In GitHub, go to your "control-plane-production" repository, followed by "Settings" and "Secrets". You should see a number of repository secrets listed.

### Web UI

1. Change to the web-ui service for the production environment:

    ```bash
    cd ../web-ui
    ```

1. Initialise the service:

    ```bash
    ../../scripts/bootstrap-service
    ```

1. Copy the file `.auto.tfvars.json` from the *control-plane* service:

    ```bash
    cp ../control-plane/.auto.tfvars.json .
    ```

1. Edit the file `variables.tf` in a similar fashion to before to add a `default` to the `resource_group_prefix` variable as you did for *blob-store*. We recommend using the same value.

1. Similarly, add a `default` to the `ui_container_registry_user` variable with the name of your machine user.

1. Also add a `default` value to the `control_repo` variable with the value based on your GitHub organization, e.g. *my-org/control-plane-production*.

1. Also add a `default` value to the `github_client_id` variable with the "Client ID" you noted when creating your OAuth App.

1. Also, add a `default` to the `proxy_url` variable with your domain name.


1. Run `terraform plan`. This should tell you that it needs to create two resources.


1. Run `terraform apply`, and as before it should repeat the plan, ask for confirmation, then create resources after you enter *yes*.

1. In the Azure Portal, under "Resource groups", you should now see a new resource group named *&lt;prefix&gt;-web-prod-resource-group*. Select it, and it should contain two resources, including one named *web-ui* of type *Container instances*.

1. Run `terraform output -raw web_ui_fqdn`. This will display a domain name. Ensure this domain name is as you expected, e.g. *&lt;prefix&gt;-web-prod.uksouth.azurecontainer.io*. Go to this domain name in a web browser, making sure to use *https*. You should be presented with a security warning. You should ignore this (temporarily), and will be presented with a page with "COVID Simulator" in the top-left.

1. Configure the DNS entry for your domain name with a CNAME record pointing to the domain name from the previous step (without the https protocol).

1. Go to your domain name in a browser. You should **not** be presented with a security warning, but should see the same page as before.

### Testing

1. Change to the top-level directory:

    ```bash
    cd ../..
    ```

1. Add your GitHub username (**not** the machine user) to the list of authorised users. Run:

   ```bash
    ./scripts/authorize-user production <username>
   ```

1. In your browser, on the website, select `Sign in with GitHub`. You will be redirected to a page on GitHub, displaying your OAuth App name and details. You can then select `Authorize <your app>` to login.

1. Select `Create new simulation`. You will need to enter at least one policy change through the `⊕ Add policy changes`, and choose `Submit simulation`.
    * Note that it might take some time for (around 5-10 minutes) for the first job to be picked up and start running.
    * You can go to Azure and view the "&lt;prefix&gt;-covid-runner-prod-aks" resource to view what is happening. For example, select `Workloads`in the left-hand menu, then `Pods`, and you will see a list of pods. For each simulation, a pod called `actions-runner-<digits>-<digits>` will be created. You can also see charts of the overall cluster, e.g. select `Metrics` in the left-hand menu, then the metric `Total number of available cpu cores in a managed cluster`, and you should see a chart showing the total number of cores. As your simulations continue to run, this should increase.

1. Once your simulations have completed (checking in your control-plane), you should see the results in the web-ui.
    * If no more simulations are executed, the number of nodes in the cluster should begin to reduce, although it may take 5-10 minutes until this happens.

1. The web-ui makes use of case and intervention data from external sources, which must be loaded into the database. This is normally done via a scheduled job (initiated from your control-plane repo). If you wish to load data immediately instead of waiting for the first scheduled run, you can do so by running:

   ```bash
    ./scripts/fetch-recorded-data-remote production
   ```

1. You can monitor this job. Go to your control-plane repo in Github and select `Actions` in the same way as before. You should see a run labelled `fetch-recorded-data` in progress. Select it to view the progress.

1. Once the job is completed, return to the website in your browser. Choose `Create new simulation` and you should now see default policies displayed for many regions/subregions. Submit a simulation as before. Once it has completed, view the results. You should now see both the predicted case numbers and the actual case numbers displayed in the charts.

### Tidying up

1. You can now delete the file containing secrets:

    ```bash
    rm production/bootstrap-configuration-secrets/.auto.tfvars
    ```

1. You should now add and commit your changes to your repository:
    * Include `backend.tf`.
    * Include any changes to any `variables.tf` files.
    * Include any changes to any `.terraform.lock.hcl` files.
    * **Do not include any .auto.tfvars or .auto.tfvars.json files** (these should be ignored by default, but this is important to reiterate)
1. You may wish to update the `README.md` file with information specific to your deployment.

