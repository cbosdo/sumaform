private-net.xml:
  file.managed:
    - name: /root/private-net.xml
    - contents: |
        <network>
          <name>private</name>
          <bridge name="virbr-private"/>
          <ip address="192.168.124.1" netmask="255.255.255.0">
            <dhcp>
              <range start="192.168.124.2" end="192.168.124.254"/>
            </dhcp>
          </ip>
        </network>

private-net_destroyed:
  cmd.run:
    - name: 'virsh net-destroy private'
    - onlyif: 'virsh net-info private | grep Active | grep yes'
    - require:
      - service: libvirtd_service
    - watch:
      - file: private-net.xml

private-net_undefined:
  cmd.run:
    - name: 'virsh net-undefine private'
    - onlyif: 'virsh net-dumpxml private'
    - require:
      - cmd: private-net_destroyed

private-net_defined:
  cmd.run:
    - name: 'virsh net-define /root/private-net.xml'
    - require:
      - cmd: private-net_undefined
    - watch:
      - file: private-net.xml

private-net_autostart:
  cmd.run:
    - name: 'virsh net-autostart private'
    - require:
      - cmd: private-net_defined

private_virt_net_start:
  cmd.run:
    - name: 'virsh net-start private' 
    - onlyif: 'virsh net-info private | grep Active | grep no'
    - require:
      - cmd: private-net_defined
