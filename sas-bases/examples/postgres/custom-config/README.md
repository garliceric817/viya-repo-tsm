---
category: dataServer
tocprty: 8
---

# Configuration Settings for PostgreSQL Database Cluster

## Overview

If you deploy an internal instance of PostgreSQL, you can configure the PostgreSQL Server Parameters and Client Host Based Authentication (HBA) Rules you would like to use for your SAS Viya deployment. These changes are managed by the Data Server Operator via the Pgcluster custom resource.

The default PostgreSQL cluster (used by most micro-services) is named `sas-crunchy-data-postgres`. Some of the SAS Viya products and solutions require their own PostgreSQL cluster in addition to the default. The following examples include a Common Data Store (CDS) PostgreSQL cluster named `sas-crunchy-data-cdspostgres`.

Copy the files as needed from `$deploy/sas-bases/examples/postgres/custom-config` to the `$deploy/site-config` directory. The following are files for configuring the PostgreSQL clusters via the Pgcluster custom resource.

* Default PostgreSQL: `sas-crunchy-data-postgres`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-patroni-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-patroni-custom-config.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-pghba-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-pghba-custom-config.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-postgres-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-postgres-custom-config.yaml`

* CDS PostgreSQL: `sas-crunchy-data-cdspostgres`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspatroni-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspatroni-custom-config.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspghba-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspghba-custom-config.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspostgres-custom-config-transformer.yaml`
  - `$deploy/sas-bases/examples/postgres/custom-config/sas-cdspostgres-custom-config.yaml`

## Installation

There are three configuration options:

* Customize PostgreSQL Server Configuration File (`postgresql.conf`) Parameters
* Customize PostgreSQL Client Authentication File (`pg_hba.conf`) Parameters
* Customize Crunchy Data Patroni Configuration Settings (Wait Times)

**Note:** These are all optional. You can choose any combination of the configuration options or choose to not configure any of them.

You must pay attention to PostgreSQL and HBA Conf Rules syntax, parameter names, and accepted values and units. Failure to do so may cause the cluster not to start. In case cluster start fails, check PostgreSQL server log file for errors.

When you are done configuring PostgreSQL, continue your SAS Viya deployment
as documented in the
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm&locale=en)

### Customize PostgreSQL Server Configuration File (postgresql.conf) Parameters

To configure `postgresql.conf`, go to the base kustomization.yaml file (`$deploy/kustomization.yaml`). Add the following content to the resources and transformers blocks of that file, including adding the blocks if they do not already exist:

```yaml
resources:
- site-config/sas-postgres-custom-config.yaml
```

```yaml
transformers:
- site-config/sas-postgres-custom-config-transformer.yaml
```

### Customize PostgreSQL Client Authentication File (pg_hba.conf) Parameters

To configure `pg_hba.conf`, go to the base kustomization.yaml file (`$deploy/kustomization.yaml`). Add the following content to the resources and transformers blocks of that file, including adding the blocks if they do not already exist:

```yaml
resources:
- site-config/sas-pghba-custom-config.yaml
```

```yaml
transformers:
- site-config/sas-pghba-custom-config-transformer.yaml
```

### Customize Crunchy Data Patroni Configuration Settings (Wait Times)

The Patroni option is used in case the Kubernetes cluster experiences delays in response times due to issues such as limited resources or network latency. The Patroni option attempts to address those failures by increasing the wait times.

To configure Patroni Conf, go to the base kustomization.yaml file (`$deploy/kustomization.yaml`). Add the following content to the resources and transformers blocks of that file, including adding the blocks if they do not already exist:

```yaml
resources:
- site-config/sas-patroni-custom-config.yaml
```

```yaml
transformers:
- site-config/sas-patroni-custom-config-transformer.yaml
```

### CDSPostgreSQL Cluster

You can configure the CDSPostgreSQL cluster (`sas-crunchy-data-cdspostgres`) in the same way you configure the `sas-crunchy-data-postgres` cluster. If your order contains CDS, you can add the `sas-crunchy-data-cdspostgres` contents to the resources and transformers sections.

Here is an example with all three CDS transformers.

```yaml
resources:
- site-config/sas-cdspatroni-custom-config.yaml
- site-config/sas-cdspostgres-custom-config.yaml
- site-config/sas-cdspghba-custom-config.yaml
```

```yaml
transformers:
- site-config/sas-cdspatroni-custom-config-transformer.yaml
- site-config/sas-cdspostgres-custom-config-transformer.yaml
- site-config/sas-cdspghba-custom-config-transformer.yaml
```

## Additional Resources

For more information, see
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm&locale=en).

[PostgreSQL Server Configuration](https://www.postgresql.org/docs/12/config-setting.html)

[PostgreSQL Client Host Based Authentication (HBA)](https://www.postgresql.org/docs/12/auth-pg-hba-conf.html)

[Crunchy Data Patroni Configuration Settings](https://access.crunchydata.com/documentation/patroni/latest/settings/index.html#settings)
