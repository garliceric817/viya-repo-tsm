---
category: dataServer
tocprty: 12
---

# Configuration Settings for PostgreSQL Replicas Count

## Overview

PostgreSQL High Availability (HA) cluster deployments have one primary database
and one or more standby databases. Data is replicated from the primary database
to the standby database. In Kubernetes, a standby database is referred to as
a replica. This README describes how to configure the number of replicas in
a PostgreSQL HA cluster.

**Note**: The number of replicas can only be configured during the initial deployment 
of the HA PostgreSQL cluster. The replica count cannot be changed after the initial deployment.

## Installation

1. The example file contains comments to assist in revising the file
   appropriately.

2. Copy the example file to a new location before making modifications, such as
   `$deploy/site-config`.

3. The variable in the file is set off by curly braces and spaces, such as
   {{ REPLICAS-COUNT }}. Replace the entire variable string, including the
   braces, with the value you want to use.

4. After you have edited the copy, add a reference to it in the transformers
   block of the base kustomization.yaml file. For example:

   ```yaml
   transformers:
   - site-config/postgres-replicas-transformer.yaml
   ```

## Examples

The example file is located at
`sas-bases/examples/postgres/replicas/postgres-replicas-transformer.yaml`.

## Additional Resources

For more information, see
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm&locale=en).

For more information about pgo.yaml configuration, go
[here](https://access.crunchydata.com/documentation/postgres-operator/latest/configuration/pgo-yaml-configuration/).
