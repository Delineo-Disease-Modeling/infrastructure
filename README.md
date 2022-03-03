# Terraform Scripts for Covid-19 Policy Modelling Infrastructure

This repository contains configuration and scripts for managing Azure (and related) infrastructure for the Covid-19 Policy Modelling application.

* [Infrastructure organisation](#infrastructure-organisation)
* [Initial setup](#initial-setup)
* [Dependencies](#dependencies)
* [Authentication](#authentication)
  * [Azure](#azure)
  * [GitHub](#github)
* [Working with an existing environment](#working-with-an-existing-environment)
  * [Initialising terraform](#initialising-terraform)
  * [Creating resources](#creating-resources)
  * [Updating sensitive values](#updating-sensitive-values)
  * [Updating remote database](#updating-remote-database)
  * [Deploying updated code](#deploying-updated-code)
  * [Debugging](#debugging)

## Infrastructure organisation

All infrastructure for this project currently belongs to a single Azure Subscription.
This infrastructure includes two broad types of resources:

* Resources (mostly in Azure) related to the running of models, and the infrastructure required.
* Resources (mostly in GitHub Actions) related to the creation/building of model connectors and other components.

The infrastructure is divided up first by *environment*:

* Running models:
  * **production** - A publicly accessible instance intended for use with external collaborators.
  * **development** - A reduced instance intended for use of developers working on the system (e.g. running the `web-ui` locally in Advanced Mode).
* Building components:
  * **build** - Build credentials shared by other environments.

Within each *environment*, resources are divided by *service*:

* *service*:
  * **actions-runner-aks** - Azure Kubernetes Service cluster for executing simulations.
  * **actions-runner-controller** - Kubernetes resources for management of runners.
  * **actions-runner-runner** - Kubernetes resources acting as GitHub Actions self-hosted runners, to execute the simulations.
  * **blob-store** - Azure Blob (object) storage for storing simulation results.
  * **configuration** - Shared secrets, etc. for authenticating communication between different services.
  * **control-plane** - GitHub Actions workflow definitions.
  * **database** - Database for storing simulation details.
  * **database-server** - Azure Database server to host database.
  * **web-ui** - Azure Container Instance containing web interface to submit simulations.

Each environment/service pair corresponds to one Resource group in the Subscription.
There is also an additional Resource group (**terraform**) used for storing the Terraform shared state.

In addition to Azure, this repository is also responsible for managing secrets used for GitHub Actions.
These Actions are used for both running model simulations, and for development/build tasks.
Note that a particular environment may not contain all services, e.g. the *development* environment does not contain a *web-ui*, as that is deployed locally by each developer.

Each environment/service pair is currently an independent Terraform root module.
Before running any Terraform commands, you will need to change directory to the appropriate `<environment>/<service>` you are interested in.

## Initial setup

If you wish to deploy a new instance of the infrastructure from scratch, see one of the following documents for step-by-step instructions:

* [SETUP.md](SETUP.md) - If you have/can obtain a domain name and an SSL certificate (**not** self-signed) for that domain.
* [SETUP-LE.md](SETUP-LE.md) - This does not require a domain name, and can be more suitable for getting started, but may be less suitable long-term.

The rest of this document assumes you are working on infrastructure that has already been deployed (possibly by another developer).

## Dependencies

Make sure you have the following installed:

- [Terraform CLI](https://www.terraform.io/downloads.html) (Tested with v1.0).
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (Tested with v2.21).
- [jq](https://stedolan.github.io/jq/download/) (Tested with v1.6) if you need to run remote DB scripts.
- [mysql client](https://www.mysql.com/) (Tested with v8.0) if you need to run remote DB scripts.
  - Note there is a [known issue with v8.0.27](https://docs.microsoft.com/en-gb/azure/mysql/single-server-whats-new#october-2021) that will prevent connections. Please use an alternative version.

## Authentication

### Azure

For all services, before doing anything else, you'll need to authenticate with Azure.

- Run `az login`
- Run `az account list --output table`
- Find and pick the subscription for this project
- Run `az account set --subscription <Subscription name>`

The authentication may expire and need to be refreshed periodically.

### GitHub

For the `control-plane` and `web-ui` services, you'll also need to authenticate with GitHub.
First, create a [GitHub Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) with the scope `repo`.
Then, create the file `<environment>/<service>/.auto.tfvars.json` with the following contents:

```
{
    "github_admin_pat": "<token>"
}
```

There may be [alternative authentication options](https://registry.terraform.io/providers/integrations/github/latest/docs) such as setting a `GITHUB_TOKEN` environment variable, but they have not been tested.

## Working with an existing environment

### Initialising terraform

This needs to be done **once per check-out per environment/service** of the project.

- Run `cd <environment>/<service>`, e.g. `cd development/blob-store`.
- Run `../../scripts/bootstrap-service`.

This will run `terraform init`.
If plugins are changed, you will need to run `terraform init` again, but it will usually tell you when to do this.

The first time any developer runs `terraform init` for a particular service on a new platform that no other developer has used, it [may make changes to the `.terraform.lock.hcl` file](https://www.terraform.io/docs/language/dependency-lock.html#new-provider-package-checksums).
Running `git diff` should show changes of the form:

```
   hashes = [
     "h1:TW2UE6F/HRn486QHOuKQGDKFJ1KhhuUhoWTjYB9lchM=",
+    "h1:f7lvcS7RHq2xjYMjP4Vge+0+n0VaueEXKbLidbxFppk=",
     "h1:pEKaDGniJF7moJPR9IrI0E3V1MEodZOZqfto6mgnUGk=",
     "zh:0044f63527fea3e53936a44414c985fc37f509d9da2584dfcd6c1247016473ac",
```

As long as the changes are only the addition of new `h1:...` lines to the `hashes` array, you should commit and push these changes.

### Initial checks

Before starting work on any service:

- Run `git pull`.
- Run `cd <environment>/<service>`, e.g. `cd development/blob-store`.
- Run `terraform validate` to check the config is valid.
- Run `terraform plan`.

The last step should report that there are no changes to be made.
If it doesn't, and you don't understand why, check that nobody else is making changes to the infrastructure.

### Creating/updating resources

Edit the appropriate `<environment>/<service>` or shared `modules/<service>` files to reflect your desired changes.

- Run `cd <environment>/<service>`, e.g. `cd development/blob-store`.
- Run `terraform validate` to check your config is valid.
- Run `terraform plan` to see what changes will be made.
- Run `terraform apply` to apply changes.
- Check that your changes have been made appropriately, e.g. go to your website and test the system.
- Commit and push your changes to the configuration.

*Note* - If `terraform plan`/`apply` hangs, it's possible your Azure session has expired.
Try logging in to Azure again.

It's very important to examine the output of `terraform plan` - if you see changes you don't expect, stop and figure out why.

* Check you have an up-to-date version of the configuration, e.g. run `git pull`.
* Check nobody else is making changes.

### Updating sensitive values

Sensitive values (passwords, private keys, etc.) are stored in an Azure Key Vault.
These values should normally be updated in the Key Vault directly through the Portal / Azure CLI.
Each environment has a `bootstrap-configuration-secrets` module which can be used to configure all the secrets at once, but this is only intended for use in the initial creation of an environment.
You should not usually use this module unless you're absolutely sure about what you're doing.

### Updating remote database

There are a number of scripts available for manipulating the remote database:

* `scripts/fetch-recorded-data-remote <environment>` will fetch data to the database (via a GitHub Actions workflow). This is not normally needed, as the workflow is scheduled to run daily.
* `scripts/authorize-user <environment> <github_id>` will add a user to the list allowed to access the web-ui.

### Deploying updated code

#### model-runner

* Follow the *Publishing a package* instructions from the `model-runner/README.md` in the `model-runner` repo to publish the `model-runner` package.
* Wait for the image to be [built and pushed](https://github.com/covid-policy-modelling/model-runner/actions/workflows/publish_version.yaml).
* In `<environment>/control-plane/main.tf`, update the value of `module.control_plane.runner_version` to reference the new image tag.
* Deploy the `<environment>/control-plane` service as in *Creating/updating resources*.

#### web-ui

* Follow the *Publishing* instructions from the `web-ui/README.md` in the `web-ui` repo.
* Wait for the image to be [built and pushed](https://github.com/covid-policy-modelling/web-ui/actions/workflows/ci.yml).
* In `<environment>/web-ui/main.tf`, update the value of `container_ui_image_tag` to reference the new version.
  * e.g. `container_ui_image_tag  = "v0.0.4"`
* Deploy the `<environment>/web-ui` service as in *Creating/updating resources*.

#### model connectors

* Follow the release process for the appropriate model connector repo,
  * e.g. for `mrc-ide-covidsim` follow the *Publishing a package* instructions from the `model-runner/README.md` to publish the `mrc-ide-covidsim` package.
* Wait for the image to be built and pushed,
  *   e.g. see [GitHub Actions](https://github.com/covid-policy-modelling/model-runner/actions/workflows/publish_version-mrc-ide-covidsim.yaml) for `mrc-ide-covidsim`.
* In *`web-ui/models.yml`*, update the value of the `imageURL` for the appropriate model.
* Release a new version of the `web-ui` as documented above.

### Debugging

#### Kubernetes

The Kubernetes cluster can be inspected using the standard `kubectl` command.
Some resources are deployed using Helm, and you can also use the `helm` command to inspect these.
Run `scripts/kubeconfig` to produce a config file that you can use to connect to the cluster.
Note that most of the important resources are under the "actions-runner-system" namespace, so you should add the `-n actions-runner-system` argument to most commands.

#### Connecting to the database

* `scripts/db-client <environment>` will connect to the remote DB for a particular environment.

`az mysql server` may also be useful for connecting to the DB with other tools.

#### Connecting to the web-ui

* `scripts/web-ui-client <environment>` will open a shell on the web-ui container for a particular environment.

This can be particularly useful for managing database migrations.
While forward migrations are normally run automatically when the container starts, there may be times where it is necessary to run them manually, e.g. to rollback to a previous version.
To do so, run the following commands.

```
scripts/web-ui-client <environment>
npx db-migrate --env=prod --help
```

Note that the `--env` argument to `db-migrate` is not the same as the `<environment>` you're connecting to. You must always use `--env=prod`.
