The `infrastructure-template` has not been designed for distributing updates - after the initial setup, each organisation is expected to manage their own infrastructure in their own repository.
This is due to the unknown differences in requirements between organisations/purposes.
Nevertheless, it is possible to apply some of the changes made to this repo to 'update' other repositories.

## Applying changes

Add the template repository as a remote (if you haven't already):

```
git remote add template git@github.com:covid-policy-modelling/infrastructure-template.git
```

Fetch the latest changes:

```
git fetch template
```

Identify the desired changes (listed below), and use `git cherry-pick` to apply them, then change to the appropriate module(s) and use `terraform apply`.

## AKS auto-upgrades

* Commits: 22c71b9
* Modules: `production/actions-runner-aks`

Previous versions defaulted to installing the latest stable version of Kubernetes in the AKS cluster at time of creation, but the cluster version would not change after that point.
This means that deployed versions of AKS will begin to go [out-of-support](https://docs.microsoft.com/en-gb/azure/aks/supported-kubernetes-versions).
To mitigate that, we have now configured the cluster to automatically upgrade by default.
If you try to apply this configuration to an existing infrastructure, you should be aware of this change in behaviour - your cluster will now [upgrade automatically](https://docs.microsoft.com/en-gb/azure/aks/upgrade-cluster#set-auto-upgrade-channel) when new versions are released.
This may cause downtime, or it is possible that a future upgrade may unexpectedly break the application (we've not seen any such issues in testing so far).

### Possible errors

When applying this configuration, you may receive an error similar to the following.

```
"│ Error: updating Managed Kubernetes Cluster "epcc-covid-runner-prod-aks" (Resource Group "epcc-covid-runner-prod-rg"): containerservice.ManagedClustersClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: Code="BadRequest" Message="To enabled Auto Upgrade, agentpools and cluster kubernetes versions must be at least (lowest supported minor version - 1) for rapid and stable channel or supported for patch and node-image channel."                │"
```

This means that you must first upgrade your cluster to a supported version before applying this change.
First, run the following command to identify the possible versions.

```
az aks get-versions --location <location> --output table
```

This will produce output like the following:

```
KubernetesVersion    Upgrades
-------------------  -----------------------
1.23.3(preview)      None available
1.22.6               1.23.3(preview)
1.22.4               1.22.6, 1.23.3(preview)
1.21.9               1.22.4, 1.22.6
1.21.7               1.21.9, 1.22.4, 1.22.6
1.20.15              1.21.7, 1.21.9
1.20.13              1.20.15, 1.21.7, 1.21.9
```

From the `KubernetesVersion` column, ignore any preview versions (`1.23.3`), and the highest non-preview minor versions (`1.22.6`, `1.22.4`).
Select the next-highest version (`1.21.9`).

Next, run the following to check the possible upgrades for your cluster:

```
az aks get-upgrades -g epcc-covid-runner-prod-rg -n epcc-covid-runner-prod-aks --output table
```

This will produce output like the following:

```
Name     ResourceGroup             MasterVersion    Upgrades
-------  ------------------------  ---------------  --------------
default  epcc-covid-runner-prod-rg  1.20.13         1.20.15, 1.21.7, 1.21.9
```

If the desired version is listed in the `Upgrades` column, then you can continue.
If the desired version is *not* listed in the `Upgrades` column, then read the section on *Multiple upgrades* below.

Then, you need to update the configuration for the appropriate environment, e.g. `production/action-runner-aks/main.tf`).

```
module "actions-runner-aks" {
  ...
  automatic_channel_upgrade = null
  kubernetes_version = 1.21.9
}
```

You should then run `terraform apply` in your `production/action-runner-aks` module.
Review the changes carefully to make sure you understand them.
It may take some time to upgrade your cluster.
After it is complete, you should test the changes by running simulations through the web-ui.

Once the application is complete, you should remove the `automatic_channel_upgrade` and `kubernetes_version` variables.
Run `terraform apply` again, and you should be told there are no changes to apply.

### Multiple upgrades

If the desired version is *not* listed in the `Upgrades` column of `az aks get-upgrades`, you will need to do multiple upgrades.
Follow the instructions above, using the latest possible version from the `Upgrades` column as the value for `kubernetes_version`
Once the application and testing is complete, repeat the `az aks get-upgrades` command, edit configuration, and `terraform apply` steps.
Repeat as many times as necessary until you have reached the desired version.

### Retaining the current behaviour

To retain the current behaviour, you should explicitly update the configuration for the appropriate environment, e.g. `production/action-runner-aks/main.tf`).

```
module "actions-runner-aks" {
  ...
  automatic_channel_upgrade = null
}
```

You can then run `terraform apply` in your `production/action-runner-aks` folder.
It should tell you there are no changes to apply.

### Other options

If you wish to use another upgrade channel, you can do so by specifying it, e.g. `automatic_channel_upgrade = rapid` (after first upgrading to an appropriate version).

## Control plane secrets

* Commits: 4795f61
* Modules: `production/control-plane`

Previous versions used an inconsistent secret name - `API_URL` in one place, `STAGING_SERVER_URL` in another.
This change resolves that to use `API_URL` consistently.
