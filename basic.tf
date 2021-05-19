terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.41.0"
    }
  }
}

provider "openstack" {}

resource "openstack_compute_instance_v2" "instance" {
    name = "test"
    image_id = "87fbbafe-2e46-460c-b981-b7970ae3841a"
    flavor_id = "b128b802-3d12-401d-bf51-878122c0e908"

    key_pair = "mct"
    security_groups = [ "default", "Ping", "SSH", "Jacktrip"]

    network {
        name = "dualStack"
    }
}
