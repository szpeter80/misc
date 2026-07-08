# Helm charts Quick Reference

- **helm repo** subcommands:

    - **add** `openshift-helm-charts` `https://charts.openshift.io/`  
    Adds a new repo by the name "openshift-helm-charts"

    - **remove** `openshift-helm-charts`  
    Removes the repo named "openshift-helm-charts"

    - **list**  
    List Helm chart repositories

    - **update**  
    Update Helm chart repositories


- **helm pull** `<chart>`  
Downloads the chart locally (.tgz)

- **helm show chart** `<chart-reference>`  
Displays general information, such as the maintainers, or the source URL

- **helm show values** `<chart-reference>`  
Displays the default values for the chart. The output is in YAML format and comes from the **values.yaml** file in the chart.

- **helm search** `<repo>`  
Lists all available charts in the configured repositories. By default shows only the **latest version** of a given chart, use **--versions** to list all versions

- **helm list**  
List releases in the cluster

- **helm install** `<release-name>` `<chart-reference>` \  
`--values values.yaml` `--dry-run`  
Displays the resources to be created. If the preview looks correct, then run without **--dry-run** to deploy the resources and create the release. By default the **latest version** of the chart used, Use the **--version** option to  install / upgrade to a specific version  

- **helm upgrade mybusinessapp corp-repo/mybusinessapp-chart -f values.yaml --version 42.0**  
The upgrade arguments must be a release and chart.
The chart argument can be either: a chart reference('example/mariadb'), a path to a chart directory, a packaged chart, or a fully qualified URL.
For chart references, the latest version will be specified unless the `--version` flag is set.

- **helm history** `<release_name>`  
Show log of past release installs and upgrades

- **helm rollback** `<release_name>` `<revision>`  
Roll back to a previous version of the chart.
Rollback might not be a supported operation, eg if a db structure was changed, usually a restore from backup is requried.
