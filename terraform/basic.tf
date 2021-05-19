terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.41.0"
    }
  }
}

resource "openstack_networking_secgroup_v2" "jacktrip" {
    name = "jacktrip"
    description = "Security group for allowing Jacktrip in P2P and Hub"
}

# Allow TCP for P2P data or Hub Mode Negotiation
resource "openstack_networking_secgroup_rule_v2" "rule_jacktrip_primary" {
    direction = "ingress"
    ethertype = "IPv4"
    protocol  = "tcp"
    port_range_min = 4464
    port_range_max = 4464
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.jacktrip.id}"
}

# Allow UDP for Hub Mode Data
resource "openstack_networking_secgroup_rule_v2" "rule_jacktrip_secondary" {
    direction = "ingress"
    ethertype = "IPv4"
    protocol  = "udp"
    port_range_min = 61002
    port_range_max = 62000
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.jacktrip.id}"
}

resource "openstack_networking_secgroup_v2" "instance_access" {
    name = "ssh-and-icmp"
    description = "Security group for allowing SSH and ICMP access"
}

# Allow ssh from IPv4 net
resource "openstack_networking_secgroup_rule_v2" "rule_ssh_access_ipv4" {
    direction = "ingress"
    ethertype = "IPv4"
    protocol  = "tcp"
    port_range_min = 22
    port_range_max = 22
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.instance_access.id}"
}

# Allow icmp from IPv4 net
resource "openstack_networking_secgroup_rule_v2" "rule_icmp_access_ipv4" {
    direction = "ingress"
    ethertype = "IPv4"
    protocol  = "icmp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = "${openstack_networking_secgroup_v2.instance_access.id}"
}

provider "openstack" {}

resource "openstack_compute_instance_v2" "instance" {
    name = "test"
    image_name = "GOLD Ubuntu 18.04 LTS"
    flavor_name = "m1.xlarge"

    key_pair = "mct"
    security_groups = [ "default", "ssh-and-icmp", "jacktrip"]

    network {
        name = "dualStack"
    }

    lifecycle {
        ignore_changes = [image_name]
    }
}
