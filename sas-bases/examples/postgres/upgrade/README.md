---
category: dataServer
tocprty: 40
---

# Upgrade the PostgreSQL Operator and PostgreSQL Cluster

## Overview

If you are updating your software, you must perform the following steps.
If you are performing a new deployment of your software, these steps can be
safely ignored.

## Instructions

**Note:** These instructions apply to all internal PostgreSQL clusters.
If you are using an external instance of PostgreSQL, do not perform any of these steps.

Perform the steps in each of the following subsections. You must be an administrator with namespace permissions
to perform the steps.

### Scale Down the SAS Data Server Operator

1. Scale down the existing SAS Data Server Operator deployment. In the following command, replace the entire variable {{ KUBERNETES-NAMESPACE }}, including the braces, with the actual namespace.

   ```bash
   kubectl scale deployment --replicas=0 sas-data-server-operator -n {{ KUBERNETES-NAMESPACE }}
   ```

   If you receive the following error, your SAS Viya deployment did not include the
   SAS Data Server Operator. In this case, skip to [Terminate PostgreSQL Clusters](#terminate-postgresql-clusters).

   ```bash
   Error from server (NotFound): deployments.apps "sas-data-server-operator" not found
   ```

2. Ensure that there are no pods running the SAS Data Server Operator:

   ```bash
   kubectl get po -l app=sas-data-server-operator -n {{ KUBERNETES-NAMESPACE }}
   ```

   This is the expected output for this command:

   ```bash
   No resources found in < KUBERNETES-NAMESPACE > namespace
   ```

### Terminate PostgreSQL Clusters

1. List the PostgreSQL clusters included in your deployment using the command below.

   ```bash
   kubectl get pgclusters.crunchydata.com -n {{ KUBERNETES-NAMESPACE }}
   ```

2. Scale down the replica deployments. Scaling down fails back the primary if it was failed over to a replica.

   ```bash
   kubectl scale --replicas=0 deployment --selector=crunchy-pgha-scope={{ PGCLUSTER-NAME }},name!={{ PGCLUSTER-NAME }} -n {{ KUBERNETES-NAMESPACE }}

   kubectl wait --for=delete --selector=crunchy-pgha-scope={{ PGCLUSTER-NAME }},name!={{ PGCLUSTER-NAME }} pods --timeout=300s -n {{ KUBERNETES-NAMESPACE }}
   ```

   Ignore the following error, which is returned if the pods are already down before the wait command.

   ```bash
   error: no matching resources found
   ```

3. Check the cluster to ensure only one pod is running as Leader.

   ```bash
   kubectl exec deployment/{{ PGCLUSTER-NAME }} -c database -n {{ KUBERNETES-NAMESPACE }} -- patronictl list
   ```

   The output would look something like the following:

   ```bash
   + Cluster: sas-crunchy-data-postgres (7016764262444130456) -----------+---------+---------+----+-----------+
   | Member                                                | Host        | Role    | State   | TL | Lag in MB |
   +-------------------------------------------------------+-------------+---------+---------+----+-----------+
   | sas-crunchy-data-postgres-7f846c5d94-wlwrp            | 10.244.2.88 | Leader  | running | 19 |           |
   +-------------------------------------------------------+-------------+---------+---------+----+-----------+
   ```

4. Delete the replica PVCs.

   ```bash
   kubectl delete pvc $(kubectl get deploy --selector=crunchy-pgha-scope={{ PGCLUSTER-NAME }},name!={{ PGCLUSTER-NAME }} -o jsonpath='{.items[*].metadata.name}' -n {{ KUBERNETES-NAMESPACE }} ) --timeout=300s -n {{ KUBERNETES-NAMESPACE }}
   ```


5. Terminate the PostgreSQL cluster.

   Copy the template file `$deploy/sas-bases/examples/postgres/upgrade/pgtask-rmdata.yaml` to
   your site-config directory, `$deploy/site-config/`. If a copy already exists, you may overwrite it.
   Then, follow the instructions within the copied file to populate any necessary variables.

   After copying and filling out the file, apply it to terminate the PostgreSQL cluster.
   Replace the entire variable {{ PGTASK-PATH }}, including the braces, with the expanded location of your copy of the file
   `$deploy/sas-bases/examples/postgres/upgrade/pgtask-rmdata.yaml`.

   ```bash
   kubectl apply -f {{ PGTASK-PATH }} -n {{ KUBERNETES-NAMESPACE }}
   ```

   **Note:** Your copy of the file `$deploy/sas-bases/examples/postgres/upgrade/pgtask-rmdata.yaml`
   should NOT be added or referenced in any kustomization files. After applying it, you
   may delete your copy of the file.

6. Wait for the internal PostgreSQL pods to be terminated. Replace the entire variable
{{ PGCLUSTER-NAME }}, including the braces, with the name of the PostgreSQL cluster you are
targeting. For example, this may be sas-crunchy-data-postgres.

   ```bash
   kubectl wait --for=delete --selector=pg-cluster={{ PGCLUSTER-NAME }} pods --timeout=300s -n {{ KUBERNETES-NAMESPACE }}
   ```

7. Wait for the custom resource pgtask to be terminated.

   ```bash
   kubectl wait --for=delete --selector=pg-cluster={{ PGCLUSTER-NAME }} pgtask --timeout=300s -n {{ KUBERNETES-NAMESPACE }}
   ```

8. Remove the TLS artifacts for the PostgreSQL cluster. Replace the entire variable
{{ PGCLUSTER-NAME }}, including the braces, with the name of the PostgreSQL cluster you are
targeting. For example, this may be sas-crunchy-data-postgres.

   ```bash
   kubectl delete job "{{ PGCLUSTER-NAME }}-tls-generator" --ignore-not-found=true --timeout=300s -n {{ KUBERNETES-NAMESPACE }}

   kubectl delete secret "{{ PGCLUSTER-NAME }}-tls-secret" --ignore-not-found=true --timeout=300s -n {{ KUBERNETES-NAMESPACE }}
   ```

9. Repeat steps 2-8 for all clusters listed in step 1.

### Delete the pgo-client Job

Run the following command to delete the pgo-client job.

```bash
kubectl delete job sas-crunchy-data-pgo-client --ignore-not-found true --timeout 300s -n {{ KUBERNETES-NAMESPACE }}
```

### Scale Down the PostgreSQL Operator

1. Scale down the existing internal PostgreSQL Operator deployment:

   ```bash
   kubectl scale deployment --replicas=0 sas-crunchy-data-postgres-operator -n {{ KUBERNETES-NAMESPACE }}
   ```

2. Ensure that there are no pods running the internal PostgreSQL operator.

   ```bash
   kubectl get po -l vendor=crunchydata,pgrmdata!=true,name!=sas-crunchy-data-pgadmin -n {{ KUBERNETES-NAMESPACE }}
   ```

   This is the expected output for this command:

   ```bash
   No resources found in < KUBERNETES-NAMESPACE > namespace
   ```

   Do not continue with your SAS Viya software update until the command
   indicates that no resources have been found.

For more information on SAS Viya software updates, see
[Updating Your SAS Viya Software](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=k8sag&docsetTarget=p0hm2t63wm8qcqn1iqs6y8vw8y81.htm&locale=en)
