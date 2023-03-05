---
category: dataServer
tocprty: 1
---

# Configure PostgreSQL

## Overview

SAS Viya provides two options for your PostgreSQL server: an internal instance
provided by SAS or an external PostgreSQL that you would like SAS Viya to
utilize. So, before deploying you must select which of these options you would
like to use for your SAS Viya deployment. If you follow the instructions in the
SAS Viya Deployment Guide, the deployment includes an internal instance of
PostgreSQL.

Before configuring PostgreSQL, you should be aware of the TLS configuration
you plan to use for your SAS Viya deployment. For more information about TLS,
see the "Configure Network Security and Encryption Using SAS Security
Certificate Framework" README file at `$deploy/sas-bases/examples/security/README.md`
(for Markdown format) and `$deploy/sas-bases/docs/configure_network_security_and_encryption_using_sas_security_certificate_framework.htm` (for HTML format).

This README also describes how to deploy Common Data Store or CDS PostgreSQL. CDS PostgreSQL is an additional PostgreSQL cluster that some services in your SAS Viya deployment may want to utilize, providing a second database that can be configured separately from the default PostgreSQL cluster.

## Pgcluster CustomResource

You can add PostgreSQL servers to SAS Viya via the Pgcluster.webinfdsvr
[CustomResource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).
This CustomResouce can be configured to create an internal PostgreSQL cluster,
managed by SAS via
[Crunchy Data](https://www.crunchydata.com/)
or an external PostgreSQL cluster (such as an Azure Database or Amazon RDS)
managed by the customer.

The default PostgreSQL cluster (used by most micro-services) in SAS Viya is
called `sas-crunchy-data-postgres` and is an internally managed PostgreSQL
cluster. SAS Viya can handle multiple PostgreSQL servers at once but only
specific micro-services can make use of servers besides the default. Consult the
documentation for your order to see if you have products that require their own
PostgreSQL in addition to the default.

The `$deploy/sas-bases/examples/postgres/configure` directory contains example
files used to manage external PostgreSQL servers via the Pgcluster
CustomResource.

To view the Pgcluster.webinfdsvr CustomResources in your SAS Viya deployment,
you may run the following command.

```bash
kubectl get pgcluster.webinfdsvr.sas.com -n {{ NAMESPACE }}
```

If you have configured a Pgcluster.webinfdsvr CustomResource to create an
internal PostgreSQL cluster, there will also be a Pgcluster.crunchydata
CustomResource provided by Crunchy Data. Run the following command to view the
Pgcluster.crunchydata CustomResources in your SAS Viya deployment.

```bash
kubectl get pgcluster.crunchydata.com -n {{ NAMESPACE }}
```

## Internal PostgreSQL

Internal instances of PostgreSQL use the
[PostgreSQL Operator and Containers](https://github.com/crunchydata)
provided by [Crunchy Data](https://www.crunchydata.com/)
behind the scenes to create the PostgreSQL cluster. The Crunchy Data operator is
*not* included in your deployment by default (to save resources in case you
use an external instance of PostgreSQL), so it will need to be added via a Kustomize
overlay.

1. Go to the base kustomization.yaml file (`$deploy/kustomization.yaml`). In the
resources block of that file, add the following content, including adding the
block if it doesn't already exist:

   ```yaml
   resources:
   - sas-bases/overlays/internal-postgres
   ```

2. Copy the content of `$deploy/sas-bases/examples/configure-postgres/internal/pgo-client` into a new subdirectory in `$deploy/site-config`, such as `$deploy/site-config/configure-postgres/internal/pgo-client`. Add the sub-directory that you've just copied to the resources block of your base kustomization.yaml file. For instance, if you copied the file to $deploy/site-config/configure-postgres/internal/pgo-client, your kustomization.yaml file would look like this:

   ```yaml
   resources:
   ...
   - site-config/configure-postgres/internal/pgo-client
   ```

3. Evaluate the pgo command string in the configMapGenerator block of the kustomization file in the folder you just copied (not the base kustomization.yaml file 
but `$deploy/site-config/configure-postgres/internal/pgo-client/kustomization.yaml` in the example above). 
The pgo command string in the block sets up a scheduled PostgreSQL pgBackRest backup that executes
every Sunday at 06:00 UTC. The string backs up both sas-crunchy-data-postgres and
sas-crunchy-data-cdspostgres clusters and includes a retention policy. If you want to
change the backup time, specify your own time in UTC. If your deployment does not include
sas-crunchy-data-cdspostgres, remove the function call sched_bkup sas-crunchy-data-cdspostgres
from the string.

This customization includes the Crunchy Data operator, as well as the
CustomResource for the default `sas-crunchy-data-postgres` cluster, in your
SAS Viya deployment. The default cluster has been tuned to work well with SAS
Viya, but it can be adjusted via Kustomize transformers if desired.

Continue your SAS Viya deployment as documented in the
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm)

### Customize Internal PostgreSQL

If you want to customize your internal PostgreSQL clusters, follow the steps in
the "Configuration Settings for PostgreSQL Database Cluster" README located at
`$deploy/sas-bases/examples/postgres/custom-config/README.md` (for Markdown
format) or `$deploy/sas-bases/docs/configuration_settings_for_postgresql_database_cluster.htm`
(for HTML format).

## External PostgreSQL

If you decide to use an external instance of PostgreSQL, you must provide a Pgcluster
CustomResource describing your external cluster to SAS. This can be done using
the base kustomization.yaml file (`$deploy/kustomization.yaml`).

1. Copy `$deploy/sas-bases/examples/postgres/configure/external-postgres.yaml`
to a new directory, such as `$deploy/site-config/external-postgres.yaml`.

2. Adjust the values in the copied file as necessary for your external
PostgreSQL instance.

3. Update the base kustomization.yaml file (`$deploy/kustomization.yaml`) by
adding the following content to the resources and transformers blocks of that
file, including adding the blocks if they do not already exist:

   ```yaml
   resources:
   - site-config/external-postgres.yaml
   ```

   ```yaml
   transformers:
   - sas-bases/overlays/external-postgres/external-postgres-transformer.yaml
   ```

4. Continue your SAS Viya deployment as documented in the
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm)

### Additional External PostgreSQL Clusters

If you want to include additional external PostgreSQL clusters besides the
default created above, follow the same steps performed
in the previous section, using a new file for each external cluster.

Ensure that *only one* external PostgreSQL resource has the
`sas.com/default-database` annotation. Otherwise you will have multiple external
PostgreSQL fighting to be considered the "default" database, which can cause
issues.

### Setting a Custom Database Name for an External Database

By default, the database name is set to `SharedServices` in the Pgcluster
Custom Resource files, `$deploy/sas-bases/examples/postgres/configure/external-postgres.yaml`
and `$deploy/sas-bases/examples/postgres/configure/external-cdspostgres.yaml`.

```yaml
spec:
...
  database: SharedServices
```

Custom names for external databases are supported, but if you have an instance of
CDS PostgreSQL, then the database name must match the PostgreSQL
database name. For example, if you change the name of the CDS PostgreSQL
database in the external-cdspostgres.yaml file to
"vmartSharedServicesProd", you must change the name of the PostgreSQL database
to "vmartSharedServicesProd" in external-postgres.yaml.

**Note:** Ensure you name the databases correctly, when you create them up front.

### Google Cloud Platform Cloud SQL for PostgreSQL Prerequisites

SAS requires that you access your Cloud SQL for PostgreSQL server via the Cloud SQL Proxy. For information regarding the configuration of a Cloud SQL Proxy, see the relevant Google documentation.

All SAS Viya database communication should be directed to a Cloud SQL Proxy client that is deployed in the same namespace that hosts SAS Viya. This ensures that data is encrypted prior to traveling outside the virtual network in the namespace. The Cloud SQL Proxy client is reachable via its service name.

### Security Considerations

SAS strongly recommends the use of SSL/TLS to secure data in transit. You should follow the documented best practices provided by your cloud platform provider for securing access to your database using SSL/TLS. Securing your database server with SSL/TLS entails the use of certificates. Upon securing your database server, your cloud platform provider may provide you with a server CA certificate. In order for SAS Viya to connect directly to a secure database server, you must provide the server CA certificate to SAS Viya prior to deployment. Failing to configure SAS Viya to trust the database server CA certificate results in "Connection refused" errors or in communications falling back to insecure modes. For instructions on how to provide CA certificates to SAS Viya, see the section labeled "Incorporating Additional CA Certificates into the SAS Viya Deployment" in the README file at `$deploy/sas-bases/examples/security/README.md` (for Markdown format) or at `$deploy/sas-bases/docs/configure_network_security_and_encryption_using_sas_security_certificate_framework.htm` (for HTML format).

When using an SQL proxy for database communication, it might be possible to secure database communication in accordance with the cloud platform vendor's best practices without the need to import your database server CA certificate. Some cloud platforms, such as the Google Cloud Platform, allow the use of a proxy server to connect to the database server indirectly in a manner similar to a VPN tunnel. These platform-provided SQL proxy servers obtain certificates directly from the cloud platform. In this case, a database server CA certificate is obtained automatically by the proxy and you do not need to provide it during deployment. To find out more about SQL proxy connections to the database server, consult your cloud provider's documentation.

#### Security Considerations on Google Cloud Platform

If you are using Google Cloud SQL for PostgreSQL, the following steps are required.

1. Copy the file `$deploy/sas-bases/examples/postgres/configure/cloud-sql-proxy.yaml`
to your `$deploy/site-config/resources/` directory. Follow the instructions provided in the file's comments to insert the necessary values.

2. Include the `cloud-sql-proxy.yaml` file in the resources block of your base kustomization.yaml file (`$deploy/kustomization.yaml`). Here is an example:

   ```yaml
   resources:
   - site-config/resources/cloud-sql-proxy.yaml
   ```

3. The Google Cloud SQL Proxy requires a Google Service Account Key. It retrieves this key from a Kubernetes Secret. To create this secret you must place the Service Account Key required by the Google sql-proxy in the file `$deploy/site-config/ServiceAccountKey.json` (in JSON format).

4. Add `$deploy/sas-bases/overlays/external-postgres/service-account-key-secret.yaml` to the generators block of your base kustomization.yaml file (`$deploy/kustomization.yaml`). Create the generators block if it does not already exist. Here is an example:

   ```yaml
   generators:
   ...
   - sas-bases/overlays/external-postgres/service-account-key-secret.yaml
   ```

5. The file `$deploy/sas-bases/overlays/external-postgres/googlecloud-full-stack-tls-transformer.yaml` allows database clients and the sql-proxy pod to communicate in clear text. This transformer must be added after all other security transformers.

   ```yaml
   transformers:
   ...
   - sas-bases/overlays/external-postgres/googlecloud-full-stack-tls-transformer.yaml
   ```

## Common Data Store (CDS) PostgreSQL

The CDS PostgreSQL cluster is configured in a similar approach to the default PostgreSQL cluster described above. While it may be deployed either internally or externally, SAS does not support a hybrid of internal and external PostgreSQL. Follow the instructions below to setup CDS PostgreSQL, following the same decision you made for the default PostgreSQL cluster.

### Internal CDS PostgreSQL

Go to the base kustomization.yaml file (`$deploy/kustomization.yaml`). In the resources block of that file, add the following content, including adding the block if it doesn't already exist:

```yaml
resources:
- sas-bases/overlays/internal-postgres/cdspostgres
```

### External CDS PostgreSQL

1. Copy `$deploy/sas-bases/examples/postgres/configure/external-cdspostgres.yaml` to a new directory, such as `$deploy/site-config/external-cdspostgres.yaml`.

2. Adjust the values in the copied file as necessary for your external CDS PostgreSQL instance.

3. Update the base kustomization.yaml file (`$deploy/kustomization.yaml`) by adding the following content to the resources and transformers blocks of that file, including adding the blocks if they do not already exist:

```yaml
resources:
- site-config/external-cdspostgres.yaml
```

## Pgcluster CustomResourceDefinition

The following are all the fields accepted by the Pgcluster.webinfdsvr
CustomResource. Note that many fields are conditionally required based on
whether you are using internal or external instances of PostgreSQL. These
fields are called out in the comments.

The definition below contains a 'default-database' annotation. If you add
additional PostgreSQL clusters, take care to *NOT* set this value for
any of them. By default, SAS Viya comes with a database marked with this
annotation. Having multiple Pgcluster resources with this annotation will
cause them to fight over which is the default and could result in your data
getting split between two PostgreSQL clusters.

Additionally, while the internal/external PostgreSQL flag can be set on each
Pgcluster individually, SAS only supports all clusters being internal
or all clusters being external. SAS does *not* support mixing external and
internal PostgreSQL clusters in the same deployment.

```yaml
apiVersion: webinfdsvr.sas.com/v1
kind: Pgcluster
metadata:
  annotations:
    sas.com/default-database: "bool"   # Declares this is the default cluster. Only
                                       # used for sas-crunchy-data-postgres.
  name: string                         # Name of this cluster.
spec:
  internal: bool         # true: provision internal cluster, false: import external cluster
  connection:
    host: string         # Required for external, default to metadata.name for internal
    port: int            # default to 5432
    ssl: bool            # Should/does service require SSL. Default is false
  rolesecret: string     # Required for external (name of secret with keys username and password
                         # that SAS should use as credentials)
  database: string       # Optional: name of sas database. 'SharedServices' is default
  storage:               # Required for internal, ignored for external
    accessmode: string   # Kubernetes accessmode for PVC, default is ReadWriteOnce
    size: string         # Initial size of data PVC. Default is 128Gi. (Total space taken is
                         # (size * 2) * [replicaCount * size])
    storageclass: string # Crunchy Data access mode. Default is nfs-client
  replicas: int          # Ignored for external, number of replica PostgreSQL clusters to create
  resources:             # Ignored for external
    postgres:            # How much CPU and memory to initially request for PostgreSQL pods
      cpu: string        # default is 150m
      memory: string     # default 2Gi
    backrest:            # How much CPU and memory to intially request for backrest pods
      cpu: string        # default is 0.01
      memory: string     # default is 256Mi
  limits:                # Ignored for external
    postgres:            # Limit how much CPU and memory each PostgreSQL pod can increase to
      cpu: string        # default is 8
      memory: string     # default is 8Gi
    backrest:            # Limit how much CPU and memory each backrest pod can increase to
      cpu: string        # default is 1
      memory: string     # default is 500Mi
  postgresconf: string   # Ignored external, optional internal: name of configmap with key/values
                         # to replace in postgresql.conf
  pghbaconf: string      # Ignored external, optional internal: name of configmap with key/values
                         # to add to pg_hba.conf
  patroniconf: string    # Ignored external, optional internal: name of configmap with key/values
                         # to update the patroni bootstrap config section of postgres-ha-bootstrap.yaml
  shutdown: bool         # ignored external, place in shutdown state but do not delete
```
