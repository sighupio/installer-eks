# EKS Package Maintenance Guide

To update the eks package, follow the next steps.

Update the `eks` version in `installer-eks/vendor.yaml` with the new tag version.

```yaml
- component: "eks"
source: "github.com/terraform-aws-modules/terraform-aws-eks.git//?ref=v17.24.0"
targets:
- "vendor/modules/terraform-aws-modules/eks/aws"
```

Run the following command:

```bash
atmos vendor pull
rm -rf ./modules/eks/vendor/modules/terraform-aws-modules/eks/aws/.git
rm -rf ./modules/vpc/vendor/modules/terraform-aws-modules/vpc/aws/.git
```

Delete the `.git` directory in `

Do the necessary modifications to the terraform files in this directory and then commit.