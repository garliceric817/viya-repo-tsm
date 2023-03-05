---
category: dataServer
tocprty: 36
---

# Administrative Tool for an Internal Instance of PostgreSQL

## Overview

If you have an internal instance of PostgreSQL, SAS Viya provides a web-based
administration tool, [pgAdmin](https://www.pgadmin.org/). The pgAdmin tool is
optional and only provides additional functionality.

## Installation

To use this tool, add the following overlay to
your base kustomization.yaml (`$deploy/kustomization.yaml`):

```yaml
resources:
- sas-bases/overlays/crunchydata_pgadmin
```

## Additional Resources

For information about how to use pgAdmin and the YAML file associated with it,
see "sas-crunchy-data-pgadmin" in
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=dplyml0phy0dkr&docsetTarget=p1wcj9amr4g8rfn1ko78an3cbe3n.htm&locale=en#p10nrpab7kuxufn1u5z8soh3ba4r)

For more information about internal and external instances of PostgreSQL, see
"Internal versus External PostgreSQL Instances" in
[SAS Viya Deployment Guide](http://documentation.sas.com/?cdcId=itopscdc&cdcVersion=default&docsetId=itopssr&docsetTarget=n1rbbuql9epqa0n1pg3bvfx3dmvc.htm&locale=en)
