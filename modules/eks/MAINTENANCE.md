# EKS Package Maintenance Guide

To update the eks package, follow the next steps.

Update the `eks` version in `installer-eks/furyfile.yaml` with the new tag version.

```yaml
  - name: terraform-aws-eks
    url: git@github.com:terraform-aws-modules/terraform-aws-eks.git
    version: v17.24.0
```

Run the following command:

```bash
furyctl legacy vendor
rm -rf ./modules/eks/vendor/modules && mkdir -p ./modules/eks/vendor/modules/
mv ./vendor/external/terraform-aws-eks ./modules/eks/vendor/modules

rm -rf ./modules/vpc/vendor/modules && mkdir -p ./modules/vpc/vendor/modules/
mv ./vendor/external/terraform-aws-vpc ./modules/vpc/vendor/modules
rm -rf ./vendor
```

Do the necessary modifications to the terraform files in this directory and then commit.