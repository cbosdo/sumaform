Preparing
=========

Libvirt network configuration
-----------------------------

Set the following hostnames in libvirt's `default` network.
This is mandatory for Kiwi and grafana to work properly.

    <network>
      <name>default</name>
      <forward mode='nat' />
      <bridge name='virbr0' stp='on' delay='0'/>
      <dns>
        <host ip='192.168.122.94'>
          <hostname>demo-srv.tf.local</hostname>
          <hostname>alternate.name.com</hostname>
        </host>
        <host ip='192.168.122.90'>
          <hostname>demo-builder.tf.local</hostname>
        </host>
        <host ip='192.168.122.89'>
          <hostname>demo-grafana.tf.local</hostname>
        </host>
      </dns>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
          <host mac='2a:c3:a7:a6:de:bf' name='demo-srv' ip='192.168.122.94'/>
          <host mac='2a:c3:a7:a6:de:bb' name='demo-builder' ip='192.168.122.90'/>
          <host mac='2a:c3:a7:a6:de:ba' name='demo-grafana' ip='192.168.122.89'/>
        </dhcp>
      </ip>
    </network>

Virtualization and image building
---------------------------------

* Add SLES 12 SP4 products
* Create HEAD SLE 12 Manager tools channel
    * name: `head-manager-tools-sle12`
    * summary: `HEAD SLE 12 manager tools`
    * parent: `SLES-12-SP4-Pool for x86_64`
    * repository url: http://mirror.tf.local/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-Beta-POOL-x86_64-Media1/
    * on demo-srv.tf.local, run `/usr/bin/spacewalk-repo-sync --channel head-manager-tools-sle12 --type yum`
* Create SLES 12 SP4 activation key
    * name: 1-SLE-12-SP4
    * Base channel: SLES-12-SP4-Pool for x86_64
    * Select all children channels
* Accept Salt keys for
    * demo-git.tf.local
    * demo-builder.tf.local
    * demo-min-kvm.tf.local
    * demo-minion-1.tf.local
    * demo-minion-2.tf.local
    * demo-minion-3.tf.local
    * demo-minion-4.tf.local
    * demo-minion-5.tf.local
    * demo-minion-6.tf.local
* Apply builder entitlement
    * On demo-builder.tf.local Details > properties page
        * Check OS Image Build Host
        * Click the Update button
    * Go to demo-builder.tf.local States > Highstate page
        * Apply the high state
* Create JeOS image
    * In Images > Profiles, click Create button
        * label: sles-12-jeos
        * type: kiwi
        * URL: http://demo-git.tf.local/jeos-12-manager#master
        * Activation key: 1-SLE-12-SP4
    * Build image on demo-builder.tf.local
* Apply Virtualization entitlement to demo-min-kvm.tf.local
* Create `vm01` on demo-min-kvm.tf.local as documented for vm02 further down.

Prepare Ubuntu channels
-----------------------

Follow these generic instructions by replacing the `${}` by the corresponding values in the table
below.

* Add channel
    * In Software > Manage > Channels click Create Channel
        * Name: `${name}`
        * Label: `${name}`
        * Parent Channel: ubuntu-18.04-pool for amd64
        * Architecture: AMD64 Debian
        * Summary: `${summary}`
    * Go to the Repositories > Add/Remove tab
        * Click the Create Repository button
            * label: `${name}`
            * url: `${url}`
            * type: deb
            * Click the Create button
        * Change to Sync tab and click Sync Now button

| name                       | summary                            | url                                                                       |
| -------------------------- | ---------------------------------- | ------------------------------------------------------------------------- |
| ubuntu-18.04-main          | Ubuntu 18.04 main channel          | http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/          |
| ubuntu-18.04-main-update   | Ubuntu 18.04 main updates channel  | http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/binary-amd64/  |
| ubuntu-18.04-main-security | Ubuntu 18.04 main security channel | http://archive.ubuntu.com/ubuntu/dists/bionic-security/main/binary-amd64/ |

If using a sumaformed mirror of the Ubuntu repositories, replace the `http://archive.ubuntu.com`
parts of the URLs by `http://mirror.tf.local/archive.ubuntu.com`.

Now, create the Ubuntu activation key with the following input:

* 1-UBUNTU-KEY
* Base channel: ubuntu-18.04-pool for amd64
* Include all children channels

* Create bootstrap script
* Ensure all `apt-get` calls in the bootstrap scripts have `--yes` parameter (bsc#1137881)
* Create Ubuntu bootstrap repo

Prepare Content Staging
-----------------------

In Salt > Remote Commands, run the following on `demo-minion*` targets:

    wget http://demo-srv.tf.local/pub/sle12-gpg-pubkey-39db7c82.key && rpm --import sle12-gpg-pubkey-39db7c82.key

Changes in `/etc/rhn/rhn.conf`:

    java.salt_content_staging_advance = 1
    java.salt_content_staging_window = 1
    java.salt_batch_size = 2

Demo Steps
==========

Image building
--------------

* Go to Images > Image List
* Show existing image infos
    * Highlight Profile, Channels
    * Show Packages
* Go to Images > Profiles
* Create a new profile:
    * label: pos-graphical
    * type: Kiwi
    * URL: copy/pasted
    * Activation key: SLES_12_SP4
* Launch build of pos-graphical profile
* Show image building status

Virtualization
--------------

* Go to Systems > Overview
* Click on demo-min-kvm.tf.local
* Highlight Virtualization Host entitlement
* Go to Virtualization tab
* Show VM actions
    * Start vm01
    * Show graphical console
    * Login in the console
    * Suspend vm01 and show
    * Resume vm01 and show
    * Shutdown vm01
    * Close the console
    * Edit vm01
        * vCPU: 2
        * new disk (default values)
        * new vnet
        * VNC
    * Start vm01 and login in it
        * ip a
        * hwinfo –-disk
* Create Guest
    * name: vm2
    * Memory: 512MB
    * Disk URL: copy from os-images tab
* Talk about Salt virt
* Wait for new VM to start and display console

Ubuntu minions
--------------

* SSH on demo-min-ubuntu.tf.local
* wget http://demo-srv.tf.local/pub/bootstrap/bootstrap.sh
* Edit it to set the activation key to 1-UBUNTU-KEY
* `bash ./bootstrap.sh` **Takes a few minutes & needs network**
* Accept the Salt key
* Show the registered system (**packages list update takes time**)

Monitoring
----------

* Show the server dashboard
* Show Admin > Manager Configuration > Monitoring
* Check the `Monitoring` box in `demo-git.tf.local` properties and submit
* Apply the highstate on `demo-git.tf.local`
* Show the client systems dashboard

Content Staging (Batch Prefetching)
-----------------------------------

* Enable content staging GUI > Home > My Organization > Configuration
* Show `java.salt_content_staging_advance` and `java.salt_content_staging_window` in `rhn.conf`
* In UI upgrade cron rpm for `demo-minion-*` scheduled in H+1.
* On demo-srv, run `salt '*minion*' cmd.run 'find /var/ -name "*.rpm" -exec ls -al '{}' \;'`

Salt Batching
-------------

* Show `java.salt_batch_size` adjusted to `2` in `rhn.conf`
* Salt remote command in GUI

Alternate Endpoint Download
---------------------------

* Create `/srv/pillar/top.sls`

    base:
      '*':
        - pkg_download_points

* Create `/srv/pillar/pkg_download_points.sls`

    {% if grains['fqdn'] == 'demo-minion-1.tf.local' %}
          pkg_download_point_protocol: http
          pkg_download_point_host: alternate.name.com
          pkg_download_point_port: 444
    {% endif %}

* `salt 'demo-minion-1.tf.local' saltutil.refresh_pillar`
* `salt 'demo-minion-1.tf.local' state.apply channels`
* Show `zypper lr -d` on demo-minion-1

Opened tabs
===========

* https://demo-srv.tf.local
* https://github.com/SUSE/manager-build-profiles/tree/master/OSImage
* https://demo-srv.tf.local/os-images/1/
* https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.virt.html
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.virt.html
* http://demo-grafana.tf.local

Clean up
========

* Delete vm02
* Shutdown vm01
* Remove pos-graphical image build and profile
* on demo-srv.tf.local, only leave the following image in `/srv/www/os-images/1`
    * SLES12-SP2-JeOS-for-kvm-and-xen.x86_64-\*.qcow2
* Delete demo-min-ubuntu.tf.local system
* Taint demo-min-ubuntu disk
* Remove `/srv/pillar/*`
* Delete demo-minion-\* systems
* Taint minion's disks && terraform apply

    for i in {1..6}; do
        terraform state rm "module.minion.module.minion.libvirt_volume.main_disk[$i]";
        virsh destroy demo-minion-$i
        virsh undefine --remove-all-storage demo-minion-$i
    done
    terraform apply -auto-approve

* In Salt > Remote Commands, run the following on `demo-minion*` targets:

    wget http://demo-srv.tf.local/pub/sle12-gpg-pubkey-39db7c82.key && rpm --import sle12-gpg-pubkey-39db7c82.key

* Remove demo-git.tf.local Monitoring entitlement + apply the highstate
* Grafana: switch to server dashboard
