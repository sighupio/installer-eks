# VPC Package Maintenance Guide

To update the vpc package, follow the next steps.

Update the `vpc` version in `installer-eks/vendor.yaml` with the new tag version.

```yaml
- component: "vpc"
source: "github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.1.2"
targets:
- "vendor/modules/terraform-aws-modules/vpc/aws"
```

Run the following command:

```bash
atmos vendor pull
rm -rf ./modules/eks/vendor/modules/terraform-aws-modules/eks/aws/.git
rm -rf ./modules/vpc/vendor/modules/terraform-aws-modules/vpc/aws/.git
```

Do the necessary modifications to the terraform files in this directory and then commit.