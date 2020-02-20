image_cached:
  file.managed:
    - name: /tmp/SLES15-SP1-kvm-and-xen.qcow2
    - source: https://srv.hol1313.net/pub/images/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen.qcow2
    - skip_verify: True

image_updated:
  cmd.run:
    - name: |
        virt-customize --root-password password:linux \
                       --run-command "rpm -e jeos-firstboot" \
                       --hostname vm02.hol1313.net \
                       --append-line '/etc/salt/grains:susemanager:' \
                       --append-line '/etc/salt/grains:  activation_key: 1-SLE-15-SP1' \
                       --append-line '/etc/salt/minion.d/master.conf:master: srv.hol1313.net' \
                       --run-command 'systemctl enable salt-minion' \
                       -a /tmp/SLES15-SP1-kvm-and-xen.qcow2
    - require:
      - file: image_cached

vm02-running:
  virt.running:
    - name: vm02
    - cpu: 1
    - mem: 512
    - disks:
      - name: system
        format: qcow2
        image: /tmp/SLES15-SP1-kvm-and-xen.qcow2
        pool: default
        size: 122880
    - interfaces:
      - name: eth0
        type: network
        source: default
    - graphics:
        type: vnc
    - seed: False
    - require:
      - cmd: image_updated
