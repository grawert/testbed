#!/usr/bin/env bash

export INTERACTIVE=false

osism-kolla deploy testbed --tags openstack --skip-tags infrastructure

osism-kolla deploy barbican
osism-kolla deploy designate
osism-kolla deploy heat
osism-kolla deploy octavia

osism-run openstack bootstrap-basic
osism-run openstack bootstrap-ceph-rgw

osism-monitoring openstack-health-monitor
