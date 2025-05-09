# Kubernetes and OpenShift CLI Quick Reference

OpenShift, under the hood, is a CNCF certified Kubernetes distribution.  
It contains the vanilla Kubernetes components unmodified and does respond to kubectl / Kubernetes API calls as any other Kubernetes cluster.  
Notable differences are 
  -   authentication - oauth capability on the API server level
  -   web UI (dashboard with admin / developer mode)
  -   the very strict SCC applied by default (can be relaxed by admin)
  -   the use of OpenShift Router for ingress (HAProxy under the hood, Routes can be autogenerated for Ingress-es)
  -   use of a locked down RPM / OSTree based system image (using RHEL packages) + Machine Config Operator for changes
  -   the cluster upgrade is specific
  -   not free, but you can try OKD, where YMMV

---
## 01 | Debugging

- **oc debug -t deployment/todo-http --image registry.access.redhat.com/ubi9/ubi:9.4**  
Start a debug container in an existing Pod.
Container is destroyed after logout.

- **oc debug -t deployment/todo-http --image registry.access.redhat.com/rhel7/rhel-tools**  
An old image, with tools like ping and dig. The successor would be ```registry.redhat.io/rhel9/support-tools:9.4-6``` but that's behind authenticated repo.

- **oc rsh my-cronjob mycommand**  
Attempt to start a shell session in a pod for the specified resource (not all container images have a working shell). It works
with pods, deployment configs, deployments, jobs, daemon sets, replication controllers and replica sets.
Any of the aforementioned resources (apart from pods) will be resolved to a ready pod.
It will default to the first container if none is specified, and will attempt to use `/bin/sh` as the default shell.

- **oc exec no-ca-bundle -- openssl s_client -connect server.network-svccerts.svc:443**  
Execute a command directly (no shell etc) inside a container

- **oc get pod -o=custom-columns=NODE:.spec.nodeName,POD:.metadata.name --sort-by '{.spec.nodeName}'**  
Print a list of pods and the node name they are running

- **oc adm top node**  
Display the resource usage of nodes

- **oc describe node/master01**  
Node details in human readable format

- **oc get event --sort-by .metadata.creationTimestamp**  
Get Events

- **oc debug node/master01 -- chroot /host crictl images | egrep '^IMAGE|httpd|nginx'**  
Start a debug container, chroot to /host, use `crictl` to list all downloaded images and filter for header, httpd and nginx related lines

- **oc get network cluster -o jsonpath='{.spec}' | jq**  
Get the CNI type and the subnets used for Pod network and Service network

- **for node in $(oc get nodes -o jsonpath="{.items[*].metadata.name}"); do oc debug node/${node} -- chroot /host poweroff 1; done**  //*
Gracefully shut down all nodes.  Larger clusters needs more time, e.g. 10 minutes instead of 1.
Changing the command to `reboot` would shut down the cluster, reboot has no parameter.
DANGER: on single-master clusters, the reboot command might not terminate in time.
This means, the debug pod gets created, the Entrypoint set to the part after '--', and the pod is ungracefully terminated.
As soon as the node reboots, it will try to start all pods which were previously running ... including the debug pod with the reboot command,
which immediately reboots the node, effectively putting it to an endless reboot loop. Breaking the loop requires to interrupt the bootloader,
add the 'single' kernel parameter, boot to a rescue shell, disable kubectl service, fully boot the node, remount /usr to rw where 'reboot'
resides, move the binary or symlink out of path, start kubelet service and delete debug pods and namespaces manually, then undo all previous changes to the OS.

- **kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n <namespace>**  
Get ALL manifest in a namespace.

- **kubectl get mutatingwebhookconfigurations | validatingwebhookconfigurations -o yaml**  
Get the object, pipe it to YAML file, delete -- then you can remove finalizers from manifest and force-delete them.  
It is possible to restore the webhook configuration from the YAML files, making it a temporary disable.

- **kubectl get replicaset -o jsonpath='{ .items[?(@.spec.replicas==0)]}' -A | kubectl delete -f -**  
Delete old ReplicaSet objects which has 0 wanted replicas, without changing the Deployment's .spec.revisionHistoryLimit.  
Old ReplicaSets are kept in order to enable a rollback to a previous state 

---
## 02 | Cluster upgrade


- **oc get clusterversion**  
Get current version, upgrade channel, upgrade status etc.

- **oc get apirequestcounts | awk '{if(NF==4){print $0}}'**
Check for API request counts on deprecated APIs

- **pause MCO**  


- **oc patch configmap admin-acks -n openshift-config --type=merge --patch '{"data":{"release-specific-data":"true"}}'**  
In some cases you have to explicitly patch a system object (technically a ConfigMap) in a high privileged location to prove
that at least one skilled and authorized person has well understood the changes in the next version.
The exact key-value pairs are specified in the Red Hat release documents and corresponding KB-s. 

- **oc adm upgrade**  
View the available updates

- **oc adm upgrade --to-latest=true**  
Apply the update to the latest version

- **oc adm upgrade --to=VERSION**  
Apply an upgrade to a specific version

- **oc get clusteroperators**  
Get a list of installed cluster operators, their versions, upgrade status etc

- **oc get subscriptions -A -o yaml**
Get a list of all operator subscriptions in YAML


---
## 03 | Deploy

- **oc create user**  
Only some resources are supported (User works, Group does not)

- **oc delete -f .**  
Delete all manifests from cluster which has the corresponding yaml in the current working directory

- **oc apply -f . --validate=true --dry-run=server**  

- **watch oc get deployments,pods**  

- **oc diff -f .**  
Kubernetes-aware diff

- **oc scale deployment test --replicas=1** 
Scale the test deployment to one replica

- **oc rollout restart deployment/database**  
ConfigMap-et get read only at Pod startup, if changed the  Pod must be restarted to get the changes applied.
Instead of directly operating on the Pod, a more graceful take is to restart its manager object, mostly a Deployment

---
## 04 | Kustomize

- **kubectl kustomize overlay/production**  
Render the manifests to stdout without applying them to the cluster

- **kubectl apply -k overlay/production**  
Apply configurations to the resources in the cluster. If resources are not available, then it creates the resources

- **oc extract secret/db-secrets-55cbgc8c6m --to=-**  
Extract the contents of the secret to the console

- **oc delete kustomize overlay/production**  
Delete the resources that were deployed by using Kustomize


---
## 05 | OpenShift Templates

- **oc get templates -n openshift**  
Get a list of all templates

- **oc get template/nginx-example -n openshift -o yaml> nginx-example-tpl.yaml**  
Extract template from OpenShift to a local file

- **oc describe template cache-service -n openshift**  
displays the description, labels that the template uses, template parameters, and the resources that the template generates

- **oc process --parameters cache-service -n openshift**  
display the parameters that the cache-service template uses

- **oc process --parameters -f  my-cache-service.yaml**  
view the parameters of a template that are defined in a file

- **oc get template cache-service -o yaml -n openshift**  
view the manifest for the template

- **oc new-app --template=cache-service -p APPLICATION_USER=my-user**  
deploys the resources that are defined in the cache-service template, specifying a parameter APPLICATION_USER

Instead of using the command-line options, place the key-value pairs in a file, with each pair on a separate line:

```
TOTAL_CONTAINER_MEM=1024
APPLICATION_USER='cache-user'
APPLICATION_PASSWORD='my-secret-password'
```

- **oc process myapp-template -o yaml --param-file=myapp.env > myapp-manifest.yaml**  
Create a manifest file from template and parameter file

- **oc process myapp-template -o yaml --param-file=myapp.env | oc diff -f -**  
Check what would change when deployed

- **oc process myapp-template -o yaml --param-file=myapp.env | oc apply -f -**  
Deploy the template processing result directly to the Openshift cluster

---
## 06 | Helm charts

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

---
## 07 | OpenShift Users

- **oc create user johndoe**  
Create new user

- **delete user**  
delete user, secret, identity

- **oc adm groups new mygroup**  
Create new group

---
## 08 | Kubernetes RBAC and OpenShift Security Context Containers


**Check permissions**

- **kubectl get -A clusterrolebindings,rolebindings -o json | jq '.items[] | select( try (.subjects | any(.kind? == "ServiceAccount" and .name? == "sa-mycluster-clusteradmin"))) '**  
List all (Cluster)RoleBindings for a given ServiceAccount


**Working with SCC-s**


- **oc get scc**  
List the SCCs that OpenShift defines

- **oc describe scc anyuid**  
Get info about a given SCC

- **oc adm policy who-can use scc anyuid**
Who can use the given SCC (anyuid) ?

- **oc adm policy who-can create persistentvolumeclaims -n custom-app**  
List who can perform the specified action on a resource. Generic form:  
```oc adm policy who-can VERB RESOURCE [ -n my-namespace | -A ]```

- **oc get pod podname -o yaml | oc adm policy scc-subject-review -f -**  
List all the security context constraints that the pod requires

- **oc create serviceaccount service-account-name**  
Create a new service account for pods in the given namespace

- **oc adm policy add-scc-to-user SCC -z service-account**  
Associate the service account with an SCC

- **oc set serviceaccount deployment/deployment-name service-account-name**  
Change an existing deployment or deployment configuration to use the service account


**Project / NS roles**

- **oc adm policy add-role-to-user role-name username -n project**  
Add a specified role to a user


**Cluster roles**

- **oc adm policy add-cluster-role-to-user cluster-role username**  
Add a cluster role to a user

- **oc adm policy add-cluster-role-to-user cluster-admin username**  
Change a regular user to a cluster administrator

- **oc adm policy remove-cluster-role-from-user cluster-role username**   
Remove a cluster role from a user

- **oc adm policy remove-cluster-role-from-user cluster-admin username**  
Change a cluster administrator to a regular user

- **oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth**  
Remove the privilege to create projects from all users who are not cluster administrators

- **oc adm policy who-can delete user**  
Check who (which user / group) can execute an action on a resource

- **oc get clusterrolebinding -o wide | grep -E 'NAME|self-provisioner'**  
List all cluster role bindings that reference the self-provisioner cluster role

- **oc describe clusterrolebindings/self-provisioners**  
Display what cluster roles ("role" block) are assigned to who ("subject" block) by the given clusterrolebinding object

---
## 09 | Network security

- **oc create route edge --service api-frontend --hostname api.apps.acme.com --key api.key --cert api.crt**  
Create a secure edge route (default name)

- **oc create route edge todo-https --service todo-http --hostname todo-https.apps.ocp4.example.com**  
Create a secure edge route (explicit resource name)

- **oc expose svc todo-http --hostname todo-http.apps.ocp4.example.com**  
Create an unsecured edge route (service use tcp/80)

- **oc get endpoints**  
List endpoints (ip addresses and ports) for services

- **oc get routes**  
List routes (in the given project)

- **oc annotate service hello service.beta.openshift.io/serving-cert-secret-name=hello-secret**
Apply this annotation to a `service`, the `service-ca` controller then creates the secret with certs in the same namespace.

- **oc annotate configmap my-cm-ca-bundle service.beta.openshift.io/inject-cabundle=true**
The `service-ca` controller injects the CA bundle to the `configmap`

---
## 10 | Project and Cluster Quotas

- **oc set resources deployment test --requests=cpu=1**  
Update (set) the deployment's resource request (reservation) to one CPU

- **oc create resourcequota --help**  
Display examples and help for creating resource quotas without a complete resource definition.

- **oc create resourcequota example --hard=count/pods=1**  
Create a resource quota that limits the number of pods in a namespace. The YAML equivalent is:  

- **oc get quota example -o yaml**  
The status key in the `quota` resource describes the current values and limits set by it.


---
## 11 | The Project Template and the Self-Provisioner Role

- **oc adm create-bootstrap-project-template `-o yaml > project_template.yaml`**  
Prints a template (kind="Template") which can be used as a starter for customization

- **oc create -f project_template -n openshift-config**  
Create the new project template (kind="Template") resource 

- **oc edit projects.config.openshift.io/cluster** 
Set spec as below to use the new template, or set `spec: {}` to use default template

```
apiVersion: config.openshift.io/v1
kind: Project
metadata:
...output omitted...
  name: cluster
...output omitted...
spec:
  projectRequestTemplate:
    name: my-custom-template
```

---
