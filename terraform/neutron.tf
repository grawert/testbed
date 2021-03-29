###################
# Security groups #
###################

resource "openstack_compute_secgroup_v2" "security_group_management" {
  name        = "${var.prefix}-management"
  description = "management security group"

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "tcp"
    from_port   = 1
    to_port     = 65535
  }

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "udp"
    from_port   = 1
    to_port     = 65535
  }

  rule {
    cidr        = "0.0.0.0/0"
    ip_protocol = "icmp"
    from_port   = -1
    to_port     = -1
  }
}

resource "openstack_networking_secgroup_rule_v2" "security_group_rule_vrrp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "112" # vrrp
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_compute_secgroup_v2.security_group_management.id
}

############
# Networks #
############

resource "openstack_networking_network_v2" "net_management" {
  name = "net-${var.prefix}-management"
}

resource "openstack_networking_subnet_v2" "subnet_management" {
  name            = "subnet-${var.prefix}-management"
  network_id      = openstack_networking_network_v2.net_management.id
  cidr            = "192.168.16.0/20"
  ip_version      = 4
  dns_nameservers = var.dns_nameservers

  allocation_pool {
    start = "192.168.31.200"
    end   = "192.168.31.250"
  }
}

resource "openstack_networking_network_v2" "net_provider" {
  name = "net-${var.prefix}-provider"
}

resource "openstack_networking_subnet_v2" "subnet_provider" {
  name        = "subnet-${var.prefix}-provider"
  network_id  = openstack_networking_network_v2.net_provider.id
  cidr        = "192.168.112.0/20"
  ip_version  = 4
  gateway_ip  = null
  enable_dhcp = var.enable_dhcp

  allocation_pool {
    start = "192.168.127.200"
    end   = "192.168.127.250"
  }
}

###################
# Router          #
###################

data "openstack_networking_network_v2" "public" {
  name = var.public
}

resource "openstack_networking_router_v2" "router" {
  name                = var.prefix
  external_network_id = data.openstack_networking_network_v2.public.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet_management.id
}
