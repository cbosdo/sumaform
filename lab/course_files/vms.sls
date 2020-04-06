vm02-running:
  virt.running:
    - name: vm02
    - cpu: 1
    - mem: 512
    - disks:
      - name: system
        format: qcow2
        image: https://srv.hol1313.net/pub/images/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen.qcow2
        pool: default
        size: 122880
    - interfaces:
      - name: eth0
        type: network
        source: default
    - graphics:
        type: vnc
    - seed: False
