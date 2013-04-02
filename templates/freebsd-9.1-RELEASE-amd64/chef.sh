#!/bin/sh -x

# Note: This is the RideCharge build of omnibus Chef. It is only for freebsd.
INSTALLER=https://dist.ridecharge.com/pub/omnibus/chef/install.sh

fetch -q -o- ${INSTALLER} | sudo bash
