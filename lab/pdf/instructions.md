---
title: 'Tame your virtual machines using SUSE Manager'
author:
    - Cédric Bosdonnat
    - João Cavalheiro
geometry: margin=1in
header-includes: |
    \usepackage{graphicx}
    \usepackage{titling}
    \usepackage{fancyhdr}
    \pagestyle{fancyplain}
    \fancyhead{}
    \rhead{\fancyplain{}{\thetitle}}
    \lfoot{\raisebox{-0.5\height}{\includegraphics[width=1in]{pdf/suse-logo.png}}}
    \cfoot{}
    \rfoot{\thepage}

...

# Lab machines overview

The lab is composed of the following machines:

* `srv.hol1313.net` with IP `192.168.15.11` is the SUSE Manager server
* `kvm1.hol1313.net` with IP `192.168.15.12` is the KVM virtual host
* `kvm2.hol1313.net` with IP `192.168.15.13` is the KVM virtual host
* `monitoring.hol1313.net` with IP `192.168.15.14` is the Monitoring server

The machines can be accessed using their IPs from the laptop, and using their hostnames from another of the lab machine.

# Setup hypervisor

## Accept Salt keys of KVM minion

Go to the **Salt** menu to list the systems that have not been accepted yet.
Click the **Accept** button for the *kvm1.hol1313.net* and *kvm2.hol1313.net* machines.

## Add Virtualization entitlement in the properties

Navigate to the *kvm1.hol1313.net* system **Properties** tab.
Check the **Virtualization Host** add-on system type and validate by clicking the **Update Properties** button.

The system will now have the **Virtualization** tab.
However, due to a Salt limitation, the **salt-minion** daemon needs to be restarted to see live changes in the virtual machines list.
In order to do this `ssh` on `kvm1.hol1313.net` and run `systemctl restart salt-minion`.

**Important note**: for the need of the lab, the virtual host is also virtual machine.
However SUSE Manager does not handle nested virtualization.
Some dirty hacks have thus been performed to lure SUSE Manager into thinking the KVM virtual host is a physical machine.
**Never do this in production!**

Adding the **Virtualization Host** Add-on type can also be performed at the registration key level.

Navigate to the **Systems > Activation Keys** menu and click on the *SLE* key to edit it.
See the **Add-on System Types** listed at the bottom of the page.
By adding an Addon system type to the activation key, this type will be added to every system where this key is applied.

## Setting the virtualization host

The system now has the **Virtualization Host** Add-on type, but this did not setup the virtualization host.
This should be done in a separate step, either before or after adding the Add-on system type.
There are multiple ways to setup a virtualization host. As a reference, consult the SUSE [Virtualization Guide](https://documentation.suse.com/sles/15-SP1/html/SLES-all/book-virt.html) and the [Virtualization Best Practices](https://documentation.suse.com/sles/15-SP1/html/SLES-all/article-vt-best-practices.html).

This exercise will leverage a Salt formula to ease the KVM and libvirt installation.

### Adding the virtualization host formula

A formula in SUSE Manager is an easy way to modify the Salt high state of the system.
First the formula needs to be enabled on the system.

Navigate to the *kvm1.hol1313.net* system's **Formulas** tab.
Select the **Virtualization Host** formula and click the **Save** button

### Edit the formula value

Adding the formula does not alter the system, it simply modifies the Salt high state.
The formula offers to modify some values to adapt the configuration.

In the **Formulas** tab of the *kvm1.hol1313.net* system click on the **Virtualization Host** subtab.
The default values are perfectly acceptable for the exercise.
Take a look at these values to figure out what can be changed.
Click the **Save Formula** button after making changes.

### Apply the high state

The high state is the aggregation of all the Salt states that will be applied on the system.

Navigate to the **States** tab of the *kvm1.hol1313.net* system.
The computed highstate is displayed and can be reviewed.

The highstate can first be applied in test mode to ensure there is no problem.
Click the link in the message at the top of the page to follow the status of the state apply action.
Even though the test has been successful, this does not mean that nothing can go wrong when applying the state in normal mode after.

Then apply the highstate in normal mode to actually install and configure both the hypervisor and libvirt.
Again follow the link in the message at the top of the page to check the action status.

Note that when selecting a Xen hypervisor in the formula, a reboot of the virtualization host is needed after applying the highstate.

** Prepare *kvm2.hol1313.net* using the same method.**

## Install exporter for hypervisor

# Creating a Virtual Machine

## Preparing an image template

Run the `mkdir /srv/www/htdocs/pub/images` command on `srv.hol1313.net`.
Copy the JeOS image provided in `/home/images/HOL1313/` in the newly created folder.

## Using the web UI

Since all the virtual machines management takes place in the **Virtualization** tab, navigate to this tab.

Click the **Create Guest** button to create a new virtual machine with the following properties:

* *Name*: vm01
* *Memory*: 512 MiB
* vCPUs: 1
* *Disk image template*: the JeOS image in `https://srv.hol1313.net/pub/images/`

Once the VM is showing in the list, click the **Graphical Console** button.
In the newly opened tab, follow the JeOS first start wizard.

## Using a Salt State

While managing virtual machines from the web user interface is convenient, automating this is even better.
The next exercise will guide you through Salt to create states to define virtual machines.

TODO: We may want to have the VMs automatically register with the proper activation key.

### Basic Salt state

Create `/srv/salt/vms.sls` with the following content:

```yaml
vm02-running:
  virt.running:
    - name: vm02
    - cpu: 1
    - mem: 512
    - disks:
      - name: system
        format: qcow2
        image: https://srv.hol1313.net/pub/images/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen-QU2.qcow2
        pool: default
        size: 122880
    - interfaces:
      - name: eth0
        type: network
        source: default
    - graphics:
        type: vnc
    - seed: False
```

Apply the state using the `salt 'kvm1*' state.apply vms` command on `srv.hol1313.net`.

Check that the `vm02` virtual machine is actually running on the *kvm1* virtual host by either using the `virsh` command on `kvm1.hol1313.net` or by running `salt 'kvm*' virt.list_active_vms` on `srv.hol1313.net`.

TODO Here too we need to go through the JeOS first boot wizard. We may want to disable it using virt-customize.

*Note:* setting the seed parameter to True will still lead to some bugs while applying the state.
The correction of those problems is currently pending upstream review.

### Create VMs as part of the highstate

TODO Exercise using the previous state in `top.sls`

### Bringing the state to the next level

TODO Add variables, pillar and templating to the previous state

### Virtual storage pools and networks using Salt

TODO Explain the existing Salt states and how to workaround the limitations
