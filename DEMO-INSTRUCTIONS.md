Preparing
=========

Virtualization and image building
---------------------------------

* Add SLES 12 SP4 products
* Create HEAD SLE 12 Manager tools channel
    * name: `head-manager-tools-sle12`
    * summary: `HEAD SLE 12 manager tools`
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

| name                       | summary                            | url                                                                      |
| -------------------------- | ---------------------------------- | ------------------------------------------------------------------------ |
| ubuntu-18.04-main          | Ubuntu 18.04 main channel          | http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/         |
| ubuntu-18.04-main-update   | Ubuntu 18.04 main updates channel  | http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/binary-amd64/ |
| ubuntu-18.04-main-security | Ubuntu 18.04 main security channel | http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/         |

If using a sumaformed mirror of the Ubuntu repositories, replace the `http://archive.ubuntu.com`
parts of the URLs by `http://mirror.tf.local/archive.ubuntu.com`.

Now, create the Ubuntu activation key with the following input:

* 1-UBUNTU-KEY
* Base channel: ubuntu-18.04-pool for amd64
* Include all children channels

Create Ubuntu bootstrap repo

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
    * Activation key: SLES_12_SP3
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
        * hwinfo –disk
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
* `bash ./bootstrap.sh`
* Accept the Salt key
* Show the registered system

Monitoring
----------

* Show the server dashboard
* Check the `Monitoring` box in `demo-git.tf.local` properties and submit
* Apply the hightstate on `demo-git.tf.local`
* Show the client systems dashboard

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
* on demo-srv.tf.local, only leave the following image in /srv/www/os-images/1
    * SLES12-SP2-JeOS-for-kvm-and-xen.x86_64-1.3.0-build67.qcow2 
* Delete demo-min-ubuntu.tf.local system
