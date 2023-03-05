---
category: dataServer
tocprty: 32
---

# Granting Security Context Constraints on an OpenShift Cluster

## Overview

The `$deploy/sas-bases/examples/crunchydata/openshift` directory contains files to grant Security Context Constraints (SCCs) for fsgroup 26 and 2000 on an OpenShift cluster. A Kubernetes cluster administrator should add these SCCs to their OpenShift cluster prior to deploying SAS Viya.

## Installation

1. As a Kubernetes cluster administrator of the OpenShift cluster, use one of the following sets of commands to apply the SCCs.

```sh
# using kubectl
kubectl apply -f pgo-scc.yaml
kubectl apply -f pgo-backrest-scc.yaml

# using the OpenShift CLI
oc create -f pgo-scc.yaml
oc create -f pgo-backrest-scc.yaml
```

2. Use the following commands to link the SCCs to Kubernetes ServiceAccounts. Replace the entire variable {{ NAME-OF-NAMESPACE }}, including the braces, with the Kubernetes namespace used for SAS Viya.

```sh
oc -n {{ NAME-OF-NAMESPACE }} adm policy add-scc-to-user pgo -z pgo-pg
oc -n {{ NAME-OF-NAMESPACE }} adm policy add-scc-to-user pgo -z pgo-target
oc -n {{ NAME-OF-NAMESPACE }} adm policy add-scc-to-user pgo-backrest -z pgo-backrest
oc -n {{ NAME-OF-NAMESPACE }} adm policy add-scc-to-user pgo-backrest -z pgo-default
```