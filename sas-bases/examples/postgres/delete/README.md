---
category: dataServer
tocprty: 44
---

# Delete a PostgreSQL Server

## Overview

This README describes the steps to remove a PostgreSQL cluster from your
SAS Viya deployment.

## Instructions

### Internal PostgreSQL

To delete an internally managed PostgreSQL cluster, run the following command.
{{ CLUSTER-NAME }} is the name of your PostgreSQL cluster, and {{ NAMESPACE }} is
the name of the namespace your SAS Viya deployment is running in.

```bash
kubectl delete -n {{ NAMESPACE }} pgcluster.webinfdsvr {{ CLUSTER-NAME }}
```

#### Artifacts That Are Never Deleted Automatically

There are a few things the above command does *NOT* delete in order to protect
your data.

First, any PersistantVolumeClaims (PVCs) created for your PostgreSQL cluster
are *NOT* deleted. The previously mentioned command destroys your cluster, thus
freeing compute resources on your kubernetes cluster, but protects your data.
The names of all PVCs for your PostgreSQL clusters are prepended with the name
of the PostgreSQL cluster. Thus, you can see the full list like so:

```bash
kubectl get pvc -n {{ NAMESPACE }} | grep {{ CLUSTER-NAME }}
```

The PVC that is simply called {{ CLUSTER-NAME }} holds the data for your primary
PostgreSQL server. The {{ CLUSTER-NAME }}-pgbr-repo holds backrest backup data.
And, all other PVCs are for your replica PostgreSQL servers.

Second, secrets generated for the PostgreSQL roles that own your data in the
database are *NOT* deleted by the above command. As with PVCs, these are named
with the name of your cluster prepended to them. Therefore, you can search for
un-deleted secrets via:

```bash
kubectl get secrets -n {{ NAMESPACE }} | grep {{ CLUSTER-NAME }}
```

#### Recover a Deleted Internal PostgreSQL Cluster

Because a `kubectl delete` command does not delete your data PVCs or role
secrets your cluster can be recovered after a delete. To do so, create a new
pgcluster resource with the same name as the previously deleted pgcluster.

Assuming you did *NOT* manually delete the PVCs/Secrets left behind by the
initial `kubectl delete` your old data will automatically be detected and
reloaded into the new cluster.

### External PostgreSQL

As with an internally managed PostgreSQL cluster, you can delete an externally
managed PostgreSQL cluster via the following command where {{ CLUSTER-NAME }}
is the name of your PostgreSQL cluster and {{ NAMESPACE }} is the name of the
namespace your SAS Viya deployment is running in.

```bash
kubectl delete -n {{ NAMESPACE }} pgcluster.webinfdsvr {{ CLUSTER-NAME }}
```

Unlike an internally managed cluster, this command will have no affect on your
external PostgreSQL cluster. All this will do is de-register your cluster
from SAS so that micro-services stop connecting to it for data. Any data that
micro-services have already written into the cluster will be maintained.

#### Recover a Deleted External PostgreSQL Cluster

Assuming you didn't delete any data from your external cluster (remember it
is the customers responsibility to maintain external clusters) you can recover
it by re-registering the cluster with SAS the same way you did initially.
