# blueprint-network-aws

This *blueprint* contains modules that are used to set up a best practices network topology in your AWS account. This *blueprint* creates an isolated VPC for each environment (staging, production, mgmt), and within each environment, sets up multiple tiers of isolated subnets (public, private, persistence) network ACLs, security groups, NAT gateways, bastion host, and VPC peering connections.

- Network
  - VPC
  - Public subnets
  - Private subnets
  _ Private persistence subnets
  - NAT
  - OpenVPN
  - Bastion host

## What is a blueprint?

At Stakater, we've taken the thousands of hours we spent building infrastructure on AWS and condensed all that experience and code into pre-built blueprints or packages or modules. Each blueprint is a battle-tested, best-practices definition of a piece of infrastructure, such as a VPC, ECS cluster, or an Auto Scaling Group. Modules are versioned using Semantic Versioning to allow Stakater clients to keep up to date with the latest infrastructure best practices in a systematic way.

## Concepts

### What's a VPC?

A [VPC](https://aws.amazon.com/vpc/) or Virtual Private Cloud is a logically isolated section of your AWS cloud. Each
VPC defines a virtual network within which you run your AWS resources, as well as rules for what can go in and out of
that network. This includes subnets, route tables that tell those subnets how to route inbound and outbound traffic,
security groups, firewalls for the subnet (known as "Network ACLs"), and any other network components such as VPN connections.

#### Benefits of a VPC

Before VPCs existed in AWS, every EC2 Instance launched in AWS was addressable by the public Internet, or any other EC2
Instance launched in AWS, even from different customers! You could block network access using security groups or OS-managed
firewalls, but this still represented a security step backward from traditional data center setups where a given server would be physically unreachable from the Internet.

VPCs are fundamentally about isolating your resources so that they're only reachable by a limited set of other resources
you define. You can set granular isolation rules by defining Route Tables for each Subnet. You can allow a limited set
of outsiders to connect to your VPC, for example, using VPN, or just by exposing a single host accessible to the public.

The general point is that you have an isolated environment you can use to lock down access.

Given all the above, an intuitive way to leverage a VPC is to make each VPC represent a unique environment by having,
for example, a prod VPC and stage VPC.

### CIDR-Formatted IP Address Ranges

Because a VPC is an isolated world meant specially for your use, you can define a range of private IP addresses that the VPC
will allow. For example, we may wish to allow any IP address from 10.0.50.0 to 10.0.50.15.

But we need a more concise way to represent such an IP address range, and the de facto standard is the Classless Inter-
Domain Routing (CIDR) standard. The name is confusing but as [Wikipedia](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) explains, the concept works as follows:

1. Convert a base-10 IP like `10.0.50.0` to binary format: `00001010.00000000.00110010.00000000`

2. Decide how many binary digits (or bits) we will allow to "vary." For example, suppose I want the following range of IP
   addresses: `00001010.00000000.00110010.00000000` to `00001010.00000000.00110010.11111111` (`10.0.50.0` to `10.0.50.255`).
   Notice that the first three "octets" (group of 8 bits) are the same, but the last octet ranges from 0 to 255.

3. Express the number of varying bits in CIDR format: `<base-10-ip>/<leading-number-of-bits-which-are-fixed>`. For
   example, if we use the range in the previous step, we'd have `10.0.50.0/24`. The first 24 bits are fixed so that the
   remaining 8 bits can vary. In CIDR parlance, our "IP Address" is `10.0.50.0` and our "Network Mask" is `24`.

Sometimes CIDR Ranges are called CIDR Blocks. The CIDR Block `0.0.0.0/0` corresponds to any IP address. The CIDR Block
`1.2.3.4/32` corresponds to only `1.2.3.4`.

You'll notice that every VPC has a CIDR Block, and indeed this represents the range of private IP addresses
which can be assigned to resources in the VPC.

### Subnets

Subnets are "sub-networks", or a partition of the VPC. For example, a VPC might have the CIDR range `10.0.50.0/24`
(`10.0.15.0` - `10.0.15.255`) and a subnet might allow just IP addresses in the range `10.0.50.0/28` (`10.0.15.0` -
`10.0.15.16`). Note that subnets cannot have overlapping CIDR Ranges.

In addition, each subnet can have a unique Route Table.

### Route Tables

Each subnet needs a [Route Table](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Route_Tables.html) so that
it knows how to route traffic within that subnet. For example, a given subnet might route traffic destined for CIDR Block
`10.0.20.0/24` to a VPC Peering Connection, traffic for `10.0.10.0/24` within the VPC, and all the rest (`0.0.0.0/0`) to
to the Internet Gateway so it can reach the public Internet. The Route Table declares all this.

### The Internet Gateway

The best way to think of an [Internet Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html)
is that it's the destination that VPC traffic destined for the public Internet gets routed to. This configuration is
recorded in a Route Table.

### NAT Gateways

If you launch an EC2 Instance in one of the **Public Subnets** defined above, it will automatically be addressable from
the public Internet and have outbound Internet access itself.

But if you launch an EC2 Instance in one of the **Private Subnets** defined above, it will NOT be addressable from the
public Internet. This is a useful security property. For example, we generally don't want our databases directly addressable
on the public Internet.

But what if an EC2 Instance in a private subnet needs *outbound* Internet access? It could route its requests to the
Internet, but there's no way for the Internet to return the response since, as we just explained, the EC2 Instance isn't
addressable from the Internet.

To solve this problem, we need our private EC2 Instance to submit its public Internet requests through another EC2 Instance
that's located in a public subnet. That EC2 Instance should keep track of where it got its original request so that it
can redirect or "translate" the response it receives back to the original requestor.

Such an EC2 Instance is called a "Network Address Translation" instance, or NAT instance.

But what if the NAT Instance goes down? Now our private EC2 Instance can't reach the Internet at all. That's why it's
preferable to have a highly available NAT Instance service, and that's what Amazon's [NAT Gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html)
service is. Amazon runs more than one EC2 Instance behind the scenes, and automatically handles failover if one instance dies.

### VPC Endpoints

By default, when an EC2 Instance makes an AWS API call, that HTTPS request is still routed through the public Internet.
AWS customers complained that they didn't want their AWS API requests traveling outside the VPC, so AWS released a
[VPC Endpoint](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-endpoints.html) service.

VPC Endpoints cost nothing and provide a new destination for a Route Table so that when certain AWS API requests are made
instead of being routed to the public AWS API endpoint, they are routed directly within the VPC. Unfortunately, as of
June 10, 2016, the only AWS service supported for VPC Endpoints is S3.

### What's a Network ACL?

[Network ACLs](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_ACLs.html) provide an extra layer of network
security, similar to a [security group](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html).
Whereas a security group controls what inbound and outbound traffic is allowed for a specific resource (e.g. a single
EC2 instance), a network ACL controls what inbound and outbound traffic is allowed for an entire subnet.

### What's a bastion host?


### What's VPC Peering?


### Networking

![](./diagrams/networking.png)

By default, the Stackater will create a VPC in a single region, amongst multiple availability zones (AZs). The default mask for this VPC is

    10.30.0.0/16

The address was chosen to be internal, and to not conflict with other pieces of infrastructure you might run. But, it can also be configured with its own CIDR range.

Each availability zone will get its own external and internal subnets. Most of our infrastructure will live in the *internal* subnet so that they are not externally accessible to the internet.

If you'd like to scale to multiple regions, simply add one to the second octet.

    10.31.0.0/16 -- my new region

To span across availability zones, the regional 16-bit mask becomes 18-bits.

    10.30.0.0/18 - AZ A
    10.30.64.0/18 - AZ B
    10.30.128.0/18 - AZ C
    10.30.192.0/18 - Spare

To subdivide each availability zone into spaces for internal, external and to have spare room for growth; use a 19-bit mask for internal, and a 20-bit mask for external. The external space is smaller because only a few instances and load-balancers should be provisioned into it.

    10.30.0.0/18 - AZ A

      10.30.0.0/19 internal
      10.30.32.0/20 external
      10.30.48.0/20 spare

    10.30.64.0/18 - AZ B

      10.30.64.0/19 internal
      10.30.96.0/20 external
      10.30.112.0/20 spare

    10.30.128.0/18 - AZ C

      10.30.128.0/19 internal
      10.30.160.0/20 external
      10.30.176.0/20 spare

The VPC itself will contain a single network gateway to route traffic in and out of the different subnets. The Stackater terraform will automatically create separate [NAT Gateways][nat-gateway] in each of the different subnets.

Traffic from each internal subnet to the outside world will run through the associated NAT gateway.

For further reading, check out these sources:

- [Recommended Address Space](http://serverfault.com/questions/630022/what-is-the-recommended-cidr-when-creating-vpc-on-aws)
- [Practical VPC Design](https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc)
- [nat-gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html)

## Developing a module

### Versioning

We are following the principles of [Semantic Versioning](http://semver.org/). During initial development, the major
version is to 0 (e.g., `0.x.y`), which indicates the code does not yet have a stable API. Once we hit `1.0.0`, we will
follow these rules:

1. Increment the patch version for backwards-compatible bug fixes (e.g., `v1.0.8 -> v1.0.9`).
2. Increment the minor version for new features that are backwards-compatible (e.g., `v1.0.8 -> 1.1.0`).
3. Increment the major version for any backwards-incompatible changes (e.g. `1.0.8 -> 2.0.0`).

The version is defined using Git tags.  Use GitHub to create a release, which will have the effect of adding a git tag.

## Credits

1. https://github.com/terraform-community-modules/tf_aws_vpc
2. https://github.com/gruntwork-io/module-vpc-public
3. https://github.com/hashicorp/best-practices/tree/master/terraform/modules/aws/network
4. https://github.com/hashicorp/atlas-examples/tree/master/infrastructures
5. 