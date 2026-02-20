<!-- markdownlint-disable MD033 -->
<h1 align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png">
  <img alt="Shows a black logo in light color mode and a white one in dark color mode." src="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
</picture><br/>
  EKS Installer
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v3.4.0-blue)
![License](https://img.shields.io/github/license/sighupio/installer-eks?label=License)
[![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)](https://kubernetes.slack.com/archives/C0154HYTAQH)

<!-- <SD-DOCS> -->

**EKS Installer** deploys a production-grade SIGHUP Distribution on Amazon Elastic Kubernetes Services (EKS).

If you are new to SIGHUP Distribution please refer to the [official documentation][skd-docs] on how to get started.

## Modules

The installer is composed of three terraform modules:

|            Module             |                       Description                      |
| ----------------------------- | ------------------------------------------------------ |
| [VPC][vpc-module]             | Deploy the necessary networking infrastructure         |
| [VPN][vpn-module]             | Deploy the a VPN Server to connect to private clusters |
| [EKS][eks-module]             | Deploy the EKS cluster                                 |

Click on each module to see its full documentation.

> [!CAUTION]
> Starting from kubernetes 1.33 amy type `alinux2` will not be available anymore as specified in the chapter for kubernetes 1.33 in [Review release notes for Kubernetes versions on standard support][kubernetes-version-standard]

## Architecture

The [EKS module][eks-module] deploys an **EKS** cluster.

The [VPC module][vpc-module] setups all the necessary networking infrastructure.
The [VPN module][vpn-module] setups one or more bastion hosts with an OpenVPN server.

The bastion host includes an OpenVPN instance easily manageable by using [furyagent][furyagent] to provide access to the cluster.

> 🕵🏻‍♂️ [Furyagent][furyagent] is a tool developed by SIGHUP to manage OpenVPN and SSH user access to the bastion host.

## Usage

> ⚠️ **WARNING**:
> if you are upgrading from v1.9.x to v1.10.0, please read [the upgrade guide](docs/upgrades/v1.9-to-v1.10.0.md) first.

### Requirements

- **AWS Access Credentials** of an AWS Account with the following [IAM permissions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/iam-permissions.md).
- **OpenTofu** `>=1.10.0` or **Terraform** `>=1.3.0` .
- `ssh` or **OpenVPN Client** - [Tunnelblick][tunnelblick] (on macOS) or [OpenVPN Connect][openvpn-connect] (for other OS) are recommended.
- `curl` to download the binary from GitHub or set the variable `vpn_furyagent_path` in the [VPN module][vpn-module] to use a local furyagent binary.

### Create EKS Cluster

To create the cluster via the installers:

1. Use the [VPC module][vpc-module] to deploy the networking infrastructure

2. (optional) Use the [VPN module][vpn-module] to deploy the openvpn bastion host

3. (optional) Configure access to the OpenVPN instance of the bastion host via [furyagent][furyagent]

4. (optional) Connect to the OpenVPN instance

5. Use the [EKS module][eks-module] to deploy the EKS cluster

Please refer to each module documentation and the [examples](examples/) folder for more details.

> You can follow the [SD on EKS quick start guide][sd-eks-quickstart] for a more detailed walkthrough

> [!WARNING]
> The `installer-eks` versions prior to 3.2.1 are incompatible with `self-managed` nodes using the `alinux2023` AMI type. This issue occurs because Amazon Linux 2023-based EKS AMIs have [deprecated the `bootstrap.sh`](https://github.com/sighupio/installer-eks/issues/88) script in favor of the new `nodeadm` system for node initialization.
>
> **Temporary Workaround:** If you must use older `installer-eks` versions with `self-managed` nodes, we recommend using the `alinux2` AMI type instead.


## Useful links

- [EKS pricing](https://aws.amazon.com/eks/pricing/)
- [Reserved EC2 Instances](https://aws.amazon.com/ec2/pricing/reserved-instances/)
- [Managing users or IAM roles for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
- [Create a kubeconfig for Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
- [Tagging your Amazon EKS resources](https://docs.aws.amazon.com/eks/latest/userguide/eks-using-tags.html)

<!-- Links -->

[eks installer docs]: https://docs.sighup.io/docs/components/installers/eks-installer
[sd-eks-quickstart]: https://docs.sighup.io/docs/getting-started/distro-on-eks
[vpc-module]: https://github.com/sighupio/installer-eks/tree/master/modules/vpc
[vpn-module]: https://github.com/sighupio/installer-eks/tree/master/modules/vpn
[eks-module]: https://github.com/sighupio/installer-eks/tree/master/modules/eks
[skd-docs]: https://docs.kubernetesfury.com/docs/distribution/

[furyagent]: https://github.com/sighupio/furyagent
[tunnelblick]: https://tunnelblick.net/downloads.html
[openvpn-connect]: https://openvpn.net/vpn-client/

[kubernetes-version-standard]: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions-standard.html

<!-- </SD-DOCS> -->
<!-- <FOOTER> -->

### Reporting Issues

In case you experience any problem with the module, please [open a new issue](https://github.com/sighupio/installer-eks/issues/new).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)

<!-- </FOOTER> -->
