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
* `kvm1.hol1313.net` with IP `192.168.15.12` is the first KVM virtual host
* `kvm2.hol1313.net` with IP `192.168.15.13` is the second KVM virtual host
* `monitoring.hol1313.net` with IP `192.168.15.14` is the Monitoring server

The machines can be accessed using their IPs from the laptop, and using their hostnames from another of the lab virtual machine.

The SUSE Manager web interface can be reached at the `https://srv.hol1313.net` address.
The `admin` user has `admin` for password.

**All machines have a root user with 'linux' password**

# Setup hypervisor

## Accept Salt keys of KVM minion

Go to the **Salt** menu to list the systems that have not been accepted yet.
Click the **Accept** button for the *kvm1.hol1313.net* machine, and only that one.

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
By adding an Addon system type to the activation key, this type will be added to every new system activated using this key.

Now accept the key for the *kvm2.hol1313.net* and check its properties.

Since we don't want the *monitoring.hol1313.net* system to also have the **Virtualization host** property, remove it from the activation key.
Check the *kvm1* and *kvm2* properties to ensure the property is still applied on those machines.

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

*Applying the highstate may take time!*

Note that when selecting a Xen hypervisor in the formula, a reboot of the virtualization host is needed after applying the highstate.

** Prepare *kvm2.hol1313.net* using the same method.**

## Install exporter for hypervisor

TODO To be moved to the monitoring section

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
* *Graphics type*: VNC

Once the VM is showing in the list which may take time, click the **Graphical Console** button.
In the newly opened tab, follow the JeOS first start wizard.

Login to the VM and set its hostname to *vm01.hol1313.net*.
To register the virtual machine on SUSE Manager:

* Add the following to `/etc/salt/grains`:

```yaml
susemanager:
  activation_key: 1-SLE-15-SP1
```

* Add a `/etc/salt/minion.d/master.conf` file containing this line:

```yaml
master: srv.hol1313.net
```

* Run `systemctl enable --now salt-minion`
* Accept the Salt key either using the `salt-key` tool on `srv.hol1313.net` or as previously done using the web interface.

## Using a Salt State

While managing virtual machines from the web user interface is convenient, automating this is even better.
The next exercise will guide you through Salt to create states to define virtual machines.

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
```

Apply the state using the `salt 'kvm1*' state.apply vms` command on `srv.hol1313.net`.

Check that the `vm02` virtual machine is actually running on the *kvm1* virtual host by either using the `virsh` command on `kvm1.hol1313.net` or by running `salt 'kvm*' virt.list_active_vms` on `srv.hol1313.net`.

Here too we need to go through the JeOS first boot wizard.
We may want to enhance the state to disable it using the `virt-customize` tool.
Before that, the `vm02` virtual machine can be deleted by applying the `virt.deleted` state shipped by SUSE Manager.

```
salt 'kvm1*' state.apply virt.deleted pillar='{"domain_name": "vm02"}'
```

```yaml
image-cached:
  file.managed:
    - name: /tmp/SLES15-SP1-kvm-and-xen.qcow2
    - source: https://srv.hol1313.net/pub/images/SLES15-SP1-JeOS.x86_64-15.1-kvm-and-xen.qcow2
    - skip_verify: True

image-updated:
  cmd.run:
    - name: |
        virt-customize --root-password password:linux \
                       --run-command "rpm -e jeos-firstboot" \
                       --hostname vm02.hol1313.net \
                       -a /tmp/SLES15-SP1-kvm-and-xen.qcow2
    - require:
      - file: image_cached

vm02-running:
  ...
  - require:
    - cmd: image-updated
```

For more details on the Salt states dependencies system, consult the [requisites Salt page](https://docs.saltstack.com/en/latest/ref/states/requisites.html#requisites).

We may want to have the VMs automatically register with the proper activation key.
As an exercise, extend the `vms.sls` state to add the minion configuration as done manually on `vm01` to the disk image using `virt-customize`.

A working solution can be found in the `${HOME}/course_files/HOL-1313/SPOILERS` folder, the `vms-simple.sls` file.

*Note:* setting the seed parameter to True will still lead to some bugs while applying the state.
The correction of those problems is currently pending upstream review.

### Bringing the state to the next level

The `vms.sls` state can only be used for a `vm02` virtual machine so far.
State files can be made reusable by introducing templating and pillar data.

Once again, delete the previously created `vm02` since it will created again using a modification of the existing state.

The goal here is to change the `vms.sls` state to handle multiple virtual machines with different parameters.
Let's assume each VM could have different CPU and memory allocation, use different virtual network or storage pools and have different activation keys.

The [pillar](https://docs.saltstack.com/en/latest/topics/tutorials/pillar.html) data could look like the following:

```yaml
vms:
  - name: vm02
    cpu: 2
    mem: 700
    net: default
    pool: default
    activation_key: 1-SLE-15-SP1
```

Salt states allow [Jinja2 templating](https://docs.saltstack.com/en/latest/topics/jinja/index.html) with some Salt-specific helpers.
The pillar data can be accessed using the `pillar` dictionary as a variable.
For instance `{{ pillar['vms'] }}` or `{{ pillar.get('vms', []) }}` would hold the array of virtual machines of the previously defined pillar.
Thus looping over the virtual machines pillar data would look like the following:

```
{% for vm in pillar.get('vms', []) %}
  {{ vm['name'] }}:
    ...
{% endfor %}
```

Modify the `vms.sls` state to handle the pillar data as defined above.
`cpu`, `mem`, `net` and `pool` can all have default values if not provided.
If the `activation_key` is not defined, then simply omit the registration part of the state.

A working solution can be found in the `SPOILERS` folder, the `vms-templated.sls` file.

Once modified, the state can be applied using the following command:

```
salt 'kvm1*' state.apply vms pillar="{'vms': [{'name': 'vm02', 'activation_key': '1-SLE-15-SP1', 'cpu': 2, 'mem': 700}]}"
```

Note that the pillar parameter contains the string representation of a Python dicitionary.

Check that the created VM has the expected CPU and memory using `salt 'kvm1*' virt.get_xml vm02`.

Optional complementary exercise: use encrypted pillar data to store the root password.

### Create VMs as part of the highstate

In the previous exercise the virtual machine state needed to be applied manually.
The virtual machines creation can be included in the virtual host configuration using the highstate.

This exercise will enforce a `web` and a `db` virtual machines on the `kvm2.hol1313.net` server.

Edit the `/srv/salt/top.sls` file to add the following:

```yaml
  'kvm*':
    - vms
```

This will load the `vms.sls` state file for all the Salt minions with an id starting with `kvm`.
Note that the `.sls` extension of the file is not typed.
This alone is not enough since the `vms.sls` state needs pillar data for the virtual machine definitions.

To store pillar data, create the `/srv/pillar/` folder and create a `top.sls` file in it with the following content:

```yaml
base:
  'kvm*':
    - vms_data
```

This will indicate Salt to load the `/srv/pillar/vms_data.sls` file in the pillar data of all minions with an id starting with `kvm`.
Then create this file with the virtual machines definitions as described in the previous exercise.
Don't forget to register the virtual machines since this will help automating their setup using Salt states later on.

Like for the previous exercises, a solution can be found in the `SPOILERS` folder.

The highstate can be verified before applying either using the web interface in the **States** tab of the system or by running this command on `srv.hol1313.net`:

```
salt 'kvm2*' state.show_highstate
```

To apply the highstate, either apply it from the SUSE Manager web interface or by running this command on the server:

```
salt 'kvm2*' state.apply
```

### Virtual storage pools and networks using Salt

Virtual machines are using storage pools to store their disks.
They are also using virtual networks.
Both of these can be defined using Salt states too, but since they are still work in progress there are a few limitations.

The `virt.pool_running` state covers all the possible pool configurations.
However the `virt.network_running` only allows creating bridged networks.
Patches to handle natted networks have been integrated in upcoming versions, but handling all network options and types still remains to be done.
Simple states calling the `virsh` command line tool can be written as a temporary workaround.

Create a `/srv/salt/test_pool.sls` file containing the following YAML code:

```
test_pool:
  virt.pool_running:
    - name: test
    - ptype: dir
    - target: /srv/pools/test
    - autostart: True
    - require:
      - service: libvirtd_service
```

This defines a `test` virtual storage pool targetting the `/srv/pools/test` folder.
This small state could obviously be improved to handle more pool types.
Even if the `virt.pool_running` handles all types of `libvirt` virtual storage pools, the `virt.running` state currently only handles file-based disks.

Copy the `private_network.sls` from the `course_files` folder into `/srv/salt/`.
This file defines a libvirt private network.
Take a moment to read this state; the important parts to notice are the dependencies definitions using both `require` and `watch`.
The `onlyif` parameter of the `cmd.run` state is also worth noting.
For more details on this parameter, check the Salt [`cmd.run` documentation](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#salt.states.cmd.run).

[`libvirt` documentation](https://libvirt.org/formatnetwork.html) is also worth reading to understand the various options of a network configuration.

Now use the newly added test storage pool and private network states to the `kvm2.hol1313.net` highstate.
Change the pillar to use the `test` pool instead of the `default` one for the `db` and `web` virtual machines.
Using the `private` network requires a little more work since the existing `vms` state also needs to be extended to handle multiple network interfaces.
Modify the `db` and `web` virtual machines to have two interfaces: one using the `default` network, and one using the `private` one.

Again a solution can be found in the `SPOILERS` folder with the `*-final.sls` files.

As an extra exercise, if time permits, add highstates for the `db` and `vms` virtual machines to install `postgresql` and `apache2` packages on them.

# Monitoring

On this exercise, you will use SUSE Manager to configure a Monitoring server with Prometheus and Grafana, configure SUSE Manager's self health, and add exporters to client systems.

Prometheus and Grafana packages are included in the SUSE Manager Client Tools for SLE12, SLE15 and openSUSE 15.x.

## Preparing the Monitoring Server 

**Installing Prometheus**

- In the SUSE Manager UI, open the details page of the system called 'monitoring', where Prometheus is to be installed, and navigate to the **Formulas** tab.
- Check the **Prometheus** checkbox and click **Save**
- Navigate to the **Prometheus** tab in the top menu.
- In the **SUSE Manager/Uyuni Server** section, enter valid API credentials (default: admin/admin). 
- Click on the **Save Formula** button.
- Apply the highstate and wait for it to complete.
- Once the highstate completes, check that the Prometheus interface loads correctly. In your browser, navigate to the URL of the server where Prometheus is installed, on port 9090 `http://monitoring.hol1313.local:9090`.

**Installing Grafana**

- In the SUSE Manager UI, open the details page of the system called 'monitoring', where Grafana is to be installed, and navigate to the **Formulas** tab.
- Check the **Grafana** checkbox and click **Save**
- Navigate to the **Grafana** tab in the top menu.
- In the **Enable and configure Grafana** section, enter the admin credentials you want to use to log in Grafana.
- On the **Datasources** section, make sure that the Prometheus URL field points to the system where Prometheus is running.
- Click on the **Save Formula** button.
- Apply the highstate and wait for it to complete.
- Once the highstate completes, check that the Grafana interface loads correctly. In your browser, navigate to the URL of the server where Grafana is installed, on port 3000 `http://monitoring.hol1313.local:3000`.

## Configuring SUSE Manager Self-health 

- In the SUSE Manager UI, navigate to menu:Admin[Manager Configuration > Monitoring].
- Click the **Enable services** button.
- Restart Tomcat and Taskomatic.
  * In order to do this `ssh` on `srv.hol1313.local` and run `spacewalk-service restart`.
- Navigate to the URL of your Prometheus server, on port 9090 `http://monitoring.hol1313.local:9090`
- In the Prometheus UI, navigate to menu:[Status > Targets] and confirm that all the endpoints on the **mgr-server** group are up.
- Navigate to the URL of your Grafana server, on port 3000 `http://monitoring.hol1313.local:3000`
- Check that the SUSE Manager Self-health dashboard on Grafana has live data.

## Monitoring Managed Systems 

Prometheus metrics exporters can be installed and configured on Salt clients using formulas. 

- Exporters are libraries that help with exporting metrics from third-party systems as Prometheus metrics. 
- Exporters are useful whenever it is not feasible to instrument a given application or system with Prometheus metrics directly. 
- Multiple exporters can run on a monitored host to export local metrics.

Once you have the exporters installed and configured, you can start using Prometheus to collect metrics from monitored systems. 

**Installing and configuring Node Exporter on client systems**

- In the SUSE Manager UI, open the details page of the client system to be monitored, and navigate to the menu:Formulas tab.
- Check the **Enabled** checkbox on the **Prometheus Exporters** formula and click **Save**.
- Navigate to the menu:Formulas[Prometheus Exporters] tab.
- Select the Node Exporter from the list
- Click on the **Save Formula** button.
- Apply the highstate and wait for it to complete.
- Confirm that the newly monitored system shows up on Prometheus UI and Grafana.
