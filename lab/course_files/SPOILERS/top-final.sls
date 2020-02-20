# This only calls no-op statement from
# /usr/share/susemanager/salt/util/noop.sls state
# Feel free to change it.

base:
  '*':
    - util.noop
  'kvm*':
    - vms
    - test_pool
    - private_network
