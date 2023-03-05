---
category: dataServer
tocprty: 20
---

# Configuration Settings for PostgreSQL Storage Size, Storage Class, Storage Type, and Storage Access Mode

## Overview

This README describes the settings available for deploying PostgreSQL with
custom size, storage class, storage type, and storage access mode. These
settings are available only if you are using a internal version of PostgreSQL.

## Installation

1. The example file contains comments to assist in revising the file
   appropriately.

2. Copy the template transformer,
   `postgres-storage-transformer.yaml`, into your
   site-config directory, `$deploy/site-config`.

3. In the copied transformer, a number of blocks are commented out. Each block
   will adjust a particular storage value, as described by another
   comment above each block. Uncomment sections as necessary and replace the
   `{{ CHANGEME }}` token with the desired new value. Comments are lines with a
   number sign (#) at the beginning of the line.

4. Each block has information about its content. The variables in the block are
   set off by curly braces and spaces, such as {{ STORAGE-SIZE-IN-GB }}.
   Replace the entire variable string, including the braces, with the value
   you want to use.

5. After you have edited the file, add a reference to it in the transformers
   block of the base kustomization.yaml file. For example:

   ```yaml
   transformers:
   - site-config/postgres-storage-transformer.yaml
   ```

## Examples

The example file is located at
`$deploy/sas-bases/examples/postgres/storage/postgres-storage-transformer.yaml`.
It includes content for configuring the following settings.

* Specify the PVC storage size, storage class, and access mode for all PVC's
  generated for the PostgreSQL cluster.

## Additional Resources

For more information, see
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm&locale=en).

For more information about pgo.yaml configuration, go
[here](https://access.crunchydata.com/documentation/postgres-operator/latest/configuration/pgo-yaml-configuration/).
