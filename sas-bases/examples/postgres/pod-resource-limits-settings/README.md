---
category: dataServer
tocprty: 28
---

# Configure Resource Settings for PostgreSQL Pods

## Overview

These settings are available only if you are using an internal version of
PostgreSQL.

This README describes how to adjust the CPU and memory usage of the PostgreSQL
pods. The minimum for each of these values is described by their **request** and
the maximum for each of these values is describe by their **limit**.

This directory includes a template kustomize transformer to adjust these values.

## Installation

1. The example transformer is almost entirely commented out. The uncommented
   sections are required and used to target the Pgcluster resources.

2. Copy the template transformer
   `$deploy/sas-bases/examples/postgres/pod-resource-limits-settings/postgres-pods-resource-limits-settings-transformer.yaml` into your
   site-config directory, `$deploy/site-config`.

3. In the copied transformer, a number of blocks are commented out. Each block
   will adjust a particular cpu/memory request/limit, as described by another
   comment above each block. Uncomment sections as necessary and replace the
   `{{ CHANGEME }}` token with the desired new value. Comments are lines with a
   number sign (#) at the beginning of the line.

   **Note:** As a best practice, SAS recommends that if you change one value,
   you change its companion value. For example, if you change the
   `{{ LIMITS-MEMORY-SIZE }}`, you should also change
   `{{ REQUEST-MEMORY-SIZE }}`.

4. Ensure the values are enclosed in double quotation marks and, if needed,
   with proper unit values. In Kubernetes, the units for megabytes is Mi
   (such as 512Mi), and the units for gigabytes is Gi (such as 4Gi).

5. The **Request** (minimum resource) value must be less then or equal to the
   **Limits** (maximum resource) value. Do not use zero (0) or negative values.

6. After you have edited the file, add a reference to it in the transformers
   block of the base kustomization.yaml (`$deploy/kustomization.yaml`) file.
   For example:

   ```yaml
   transformers:
   - site-config/postgres-pods-resource-limits-settings-transformer.yaml
   ```

## Examples

The example file is located at
`$deploy/sas-bases/examples/postgres/pods-resource-limits-settings/postgres-pods-resource-limits-settings-transformer.yaml`.
It includes content for configuring the following settings:

* Specify the PostgreSQL pods Limits (maximum resource) for CPU count
* Specify the PostgreSQL pods Limits (maximum resource) for memory size
* Specify the PostgreSQL pods Request (minimum resource) for CPU count
* Specify the PostgreSQL pods Request (minimum resource) for memory size
* Specify the Backrest pods Limits (maximum resource) for CPU count
* Specify the Backrest pods Limits (maximum resource) for memory size
* Specify the Backrest pods Request (minimum resource) for CPU count
* Specify the Backrest pods Request (minimum resource) for memory size

## Additional Resources

For more information, see
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=titlepage.htm&locale=en).

For more information about **Pod CPU resource** configuration, go
[here](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/).

For more information about **Pod memory resource** configuration, go
[here](https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/).
