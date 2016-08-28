# vpc-peerimg

This Terraform Module creates [VPC Peering
Connections](http://docs.aws.amazon.com/AmazonVPC/latest/PeeringGuide/Welcome.html) between VPCs. Normally, VPCs are completely isolated from each other, but sometimes, you want to allow traffic to flow between them, such as allowing DevOps tools running in a *Global Admiral Management VPC* to talk to apps running in a *Stage* or *Prod VPC*. This module can create peering connections and route table entries that make this sort of cross-VPC communication possible.

## What's a VPC?

A [VPC](https://aws.amazon.com/vpc/) or Virtual Private Cloud is a logically isolated section of your AWS cloud. Each VPC defines a virtual network within which you run your AWS resources, as well as rules for what can go in and out of that network. This includes subnets, route tables that tell those subnets how to route inbound and outbound traffic, security groups, firewalls for the subnet (known as "Network ACLs"), and any other network components such as VPN connections.

## Why bother with peering and not just put everything in one VPC?

We intentionally keep VPCs as isolated as we can to reduce the chances that a problem in one VPC will affect the other VPCs. For example, our standard VPC deployment gives you an isolated staging VPC where you can test changes without having to worry that they might affect production. Similarly, if an attacker breaks into the staging VPC, they cannot easily access your production data without breaking through yet another layer of security. These multiple layers are known as "defense-in-depth."

The point of VPC peering is to allow limited, controlled cross-VPC communication. In particular, you may want to set up peering to allow a user logged into a management VPC to carry out maintenance tasks in the staging and production VPCs. However, VPC peering relationships are not "transitive": even though the management VPC can access both staging and production, someone in staging *cannot* access production.