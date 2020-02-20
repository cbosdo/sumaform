{% for vm in pillar.get('vms', []) %} 
{{ vm['name'] }}_image_cached:
  file.managed:
    - name: /tmp/{{ vm['name'] }}-SLES15-SP1-kvm-and-xen.qcow2
    - source: https://srv.hol1313.net/pub/images/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen.qcow2
    - skip_verify: True

{{ vm['name'] }}_image_updated:
  cmd.run:
    - name: |
        virt-customize --root-password password:linux \
                       --run-command "rpm -e jeos-firstboot" \
                       --hostname {{ vm['name'] }}.hol1313.net \
        {% if vm.get('activation_key', None) %} \
                       --append-line '/etc/salt/grains:susemanager:' \
                       --append-line '/etc/salt/grains:  activation_key: {{ vm['activation_key'] }}' \
                       --append-line '/etc/salt/minion.d/master.conf:master: srv.hol1313.net' \
                       --run-command 'systemctl enable salt-minion' \
        {% endif %} \
                       -a /tmp/{{ vm['name'] }}-SLES15-SP1-kvm-and-xen.qcow2
    - require:
      - file: {{ vm['name'] }}_image_cached

{{ vm['name'] }}-running:
  virt.running:
    - name: {{ vm['name'] }}
    - cpu: {{ vm.get('cpu', 1) }}
    - mem: {{ vm.get('mem', 512) }}
    - disks:
      - name: system
        format: qcow2
        image: /tmp/{{ vm['name'] }}-SLES15-SP1-kvm-and-xen.qcow2
        pool: {{ vm.get('pool', 'default') }}
        size: 122880
    - interfaces:
      - name: eth0
        type: network
        source: {{ vm.get('net', 'default') }}
    - graphics:
        type: vnc
    - seed: False
    - require:
      - cmd: {{ vm['name'] }}_image_updated
{% endfor %}
