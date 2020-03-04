---
title: 'Tame your virtual machines using SUSE Manager'
author:
    - Cédric Bosdonnat
    - João Cavalheiro
titlepage: true
titlepage-text-color: 0D2C40
titlepage-background: pdf/title.png
titlepage-rule-height: 0
logo: pdf/suse-logo.png
footer-left: \raisebox{-0.5\height}{\includegraphics[width=1in]{pdf/suse-logo.png}}
footer-center: \thepage
footer-right: \raisebox{-0.5\height}{\includegraphics[width=1in]{pdf/susecon20-logo.png}}

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

# Virtualization hosts setup

## Activating virtualization features in SUSE Manager

Before being able to create and manage virtual machines, a virtualization host needs to be set up with an hypervisor.
The exercise aims at setting up both `kvm1.hol1313.net` and `kvm2.hol1313.net`.
In order to show two different ways of proceeding, first `kvm1.hol1313.net` will be setup, then the other one.


### Exercise 1.1: register `kvm1.hol1313.net` as virtualization host

**Step 1:** accept Salt keys of `kvm1.hol1313` minion

Go to the **Salt** menu to list the systems that have not been accepted yet.
Click the **Accept** button for the *kvm1.hol1313.net* machine, and only that one.

**Step 2:** add Virtualization entitlement

In this part of the exercise, add the **Virtualization Host** entitlement by using the system **Properties** tab.

Navigate to the *kvm1.hol1313.net* system **Properties** tab.
Check the **Virtualization Host** add-on system type and validate by clicking the **Update Properties** button.

**Step 3:** restart the **salt-minion** service

The system will now have the **Virtualization** tab.
However, due to a Salt limitation, the **salt-minion** daemon needs to be restarted to see live changes in the virtual machines list.
In order to do this `ssh` on `kvm1.hol1313.net` and run `systemctl restart salt-minion`.


### Exercise 1.2: register `kvm2.hol1313.net` as virtualization host

Adding the **Virtualization Host** Add-on type can also be performed at the registration key level.
In this exercise, first add the add-on type on the registration key, and then perform all the other tasks from the previous excercise.

**Step 1:** Add the **Virtualization Host** add-on type to **SLE** registration key

Navigate to the **Systems > Activation Keys** menu and click on the *SLE* key to edit it.
See the **Add-on System Types** listed at the bottom of the page.
By adding an Addon system type to the activation key, this type will be added to every new system activated using this key.

**Step 2:** accept the key for the *kvm2.hol1313.net*

**Step 3:** check `kvm2.hol1313.net` properties

We don't want the *monitoring.hol1313.net* system to also have the **Virtualization host** property but there is no need to remove it from the activation key.
The **Virtualization host** add-on type can only be added to physical machines.

**Important note**

For the need of the lab, the virtualization hosts are also virtual machines.
However SUSE Manager does not handle nested virtualization.
Some dirty hacks have thus been performed to lure SUSE Manager into thinking the KVM virtual hosts are physical machines.

**Never do this in production!**

## Configuring the virtualization host

The systems now have the **Virtualization Host** Add-on type, but this did not install the hypervisor and the needed tools.
This should be done in a separate step, either before or after adding the Add-on system type.
There are multiple ways to setup a virtualization host. As a reference, consult the SUSE [Virtualization Guide](https://documentation.suse.com/sles/15-SP1/html/SLES-all/book-virt.html) [^1] and the [Virtualization Best Practices](https://documentation.suse.com/sles/15-SP1/html/SLES-all/article-vt-best-practices.html)[^2].


### Exercise 1.3: install `kvm1.hol1313.net` and `kvm2.hol1313.net` hypervisor and tools

This exercise will leverage a Salt formula to ease the KVM and libvirt installation.
The steps will go through the systems one by one, but there is a way to do it on the two of them in one shot.
Advanced SUSE Manager users can try to find it.

**Step 1:** add the virtualization host formula

A formula in SUSE Manager is an easy way to modify the Salt high state of the system.
This step will add the **Virtualization Host** formula to both KVM systems.

First the formula needs to be enabled on the system.

Navigate to the *kvm1.hol1313.net* system's **Formulas** tab.
Select the **Virtualization Host** formula and click the **Save** button

Do the same for `kvm2.hol1313.net`.

**Step 2:** check the formula values

Adding the formula does not alter the system, it simply modifies the Salt high state.
The formula offers to modify some values to adapt the configuration.
In this step, review the **Virtualization host** formula values.

In the **Formulas** tab of the *kvm1.hol1313.net* system click on the **Virtualization Host** subtab.
The default values are perfectly acceptable for the exercise.
Take a look at these values to figure out what can be changed.
Click the **Save Formula** button after making changes.

Do the same for `kvm2.hol1313.net`.

**Step 3:** apply the high state

The high state is the aggregation of all the Salt states that will be applied on the system.
It is affected by the system channels, packages, configuration, but also by the formulas.

1. Navigate to the **States** tab of the *kvm1.hol1313.net* system.
The computed highstate is displayed and can be reviewed.

2. The highstate can first be applied in test mode to ensure there is no problem.
3. Click the link in the message at the top of the page to follow the status of the state apply action.

Even though the test has been successful, this does not mean that nothing can go wrong when applying the state in normal mode after.

4. Then apply the highstate in normal mode to actually install and configure both the hypervisor and libvirt.
5. Again follow the link in the message at the top of the page to check the action status.

*Applying the highstate may take time!*

Note that when selecting a Xen hypervisor in the formula, a reboot of the virtualization host is needed after applying the highstate.

Do the same for `kvm2.hol1313.net`.

**SPOILER: ** in order to apply all these actions to multiple systems, add them into a *System Group*.

# Creating Virtual Machines

This hands on will explore two ways of creating virtual machines.
The first one using the SUSE Manager web interface and one using Salt states.

A prerequisite of both ways is to have a template disk image to use.
In the following exercises, the SLES 15 SP1 JeOS image will be used for this, but custom images could also be build using the SUSE Manager Kiwi image building feature.
The latter feature is not explained in this hands on.

**Step 0:** prepare an image template

Run the `mkdir /srv/www/htdocs/pub/images` command on `srv.hol1313.net`.
Copy the JeOS image provided in `/home/images/HOL1313/` in the newly created folder.

## Discovering the web interface

### Exercise 1.4: using the web interface

All the virtual machines management takes place in the **Virtualization** tab of the virtualization host system.

**Step 1:** create `vm01`

In this step create a `vm01` virtual machine on `kvm1.hol1313.net` with the folllowing properties:

* *Name*: vm01
* *Memory*: 512 MiB
* vCPUs: 1
* *Disk image template*: the JeOS image in `https://srv.hol1313.net/pub/images/`
* *Graphics type*: VNC

In the **Virtualization** tab of the `kvm1.hol1313.net`, click the **Create Guest** button and complete the opened dialog.

The VM should be showing up in the list.
Note that this may take some time, but the status of the creation can be checked in the **Events** history of the system.

**Step 2:** go through the JeOS first boot wizard

Since this exercise uses the SLES 15 SP1 JeOS image as template for the virtual machine, a first boot wizard needs to be walked through.

1. click the **Graphical Console** button.
2. in the newly opened tab, follow the JeOS first start wizard.

**Step 3:** register VM on SUSE Manager

By default virtual machines are simply listed in the **Virtualization** tab.
However it is useful to register them in SUSE Manager to allow managing them with other systems.
In this step, the VM will be provided a hostname and will be registered on the SUSE Manager instance.

1. in the graphical console, login to the VM and set its hostname to *vm01.hol1313.net*.
2. add the following to the virtual machine's `/etc/salt/grains`:

```yaml
susemanager:
  activation_key: 1-SLE-15-SP1
```

3. add a `/etc/salt/minion.d/master.conf` file containing this line:

```yaml
master: srv.hol1313.net
```

4. run `systemctl enable --now salt-minion`
5. accept the Salt key either using the `salt-key` tool on `srv.hol1313.net` or as previously done using the web interface.

As a result, the systems list should now include a `vm01.hol1313.net` entry.

## Using Salt States

While managing virtual machines from the web user interface is convenient, automating this is even better.
The following exercises will progressively show how to write Salt states to define virtual machines.


### Exercise 1.5: simple Salt state

**Step 1:** copy the state file

A Salt state file is a YAML file with an `.sls` extension and they are usually living in the `/srv/salt/` folder on the SUSE Manager server.

1. copy the `${HOME}/course_files/HOL-1313/simple-vms.sls` file as `vms.sls` in `srv.hol1313.net` `/srv/salt` folder.
2. read the file to understand what this is supposed to do.
Note that the Salt documentation is available in the `salt-doc` package.

**Step 2:** apply the state

Writing the Salt state does not create the virtual machine: the state needs to be applied on the virtual host for this.

1. run the `salt 'kvm1*' state.apply vms` command on `srv.hol1313.net`.
2. check that the `vm02` virtual machine is actually running on the *kvm1* virtual host by either using the `virsh` command on `kvm1.hol1313.net` or by running the following command on `srv.hol1313.net`:

```sh
salt 'kvm*' virt.list_active_vms
```


### Exercise 1.6: customize the template disk image

Here too the JeOS first boot wizard needs to be completed.
The goal of this exercise is to enhance the previously created state to use the `virt-customize` tool to disable it.

**Step 1:** delete the previously created `vm02`

Since the exercise will enhance the previous state, the `vm02` virtual machine needs to be deleted.

Apply the `virt.deleted` state shipped by SUSE Manager:

```
salt 'kvm1*' state.apply virt.deleted pillar='{"domain_name": "vm02"}'
```

**Step 2:** modify the `vms.sls` state file

Check the `virt-customize` help or [man page](http://libguestfs.org/virt-customize.1.html)[^3] and the [requisites Salt documentation](https://docs.saltstack.com/en/latest/ref/states/requisites.html#requisites)[^4] to change the Salt state to:

1. copy the template image locally
2. remove the `jeos-firstboot` package from the image
3. set the hostname to `vm02.hol1313.net` in the image
4. set a root password in the image
5. use the customized image for `vm02`

We may want to have the VMs automatically register with the proper activation key.
If time permits, also add the minion configuration as done manually on `vm01` to the disk image using `virt-customize`.

A working solution can be found in the `${HOME}/course_files/HOL-1313/SPOILERS` folder, the `vms-simple.sls` file.

*Note:* setting the seed parameter to True will still lead to some bugs while applying the state.
The correction of those problems is currently pending upstream review.

**Step 3:** test the state changes

Apply the `vms.sls` state again and verify that the newly created `vm02` works as expected.


### Exercise 1.7: make the state reusable 

The `vms.sls` state can only be used for a `vm02` virtual machine so far.
State files can be made reusable by introducing templating and pillar data.

The goal here is to change the `vms.sls` state to handle multiple virtual machines with different parameters.
Let's assume each VM could have different CPU and memory allocation, use different virtual network or storage pools and have different activation keys.

The [pillar](https://docs.saltstack.com/en/latest/topics/tutorials/pillar.html)[^5] data could look like the following:

```yaml
vms:
  - name: vm02
    cpu: 2
    mem: 700
    net: default
    pool: default
    activation_key: 1-SLE-15-SP1
```

Salt states allow [Jinja2 templating](https://docs.saltstack.com/en/latest/topics/jinja/index.html)[^6] with some Salt-specific helpers.
The pillar data can be accessed using the `pillar` dictionary as a variable.
For instance `{{ pillar['vms'] }}` or `{{ pillar.get('vms', []) }}` would hold the array of virtual machines of the previously defined pillar.
Thus looping over the virtual machines pillar data would look like the following:

```yaml
{% for vm in pillar.get('vms', []) %}
  {{ vm['name'] }}:
    ...
{% endfor %}
```

**Step 1:** once again, delete the previously created `vm02` since it will be created again using a modification of the existing state.

**Step 2:** modify the `vms.sls` state to handle the pillar data as defined above.

`cpu`, `mem`, `net` and `pool` can all have default values if not provided.
If the `activation_key` is not defined, then simply omit the registration part of the state.

A working solution can be found in the `SPOILERS` folder, the `vms-templated.sls` file.

**Step 3:** apply the state using the following command:

```sh
salt 'kvm1*' state.apply vms \
     pillar="{'vms': [{'name': 'vm02', \
                       'activation_key': '1-SLE-15-SP1', \
                       'cpu': 2, 'mem': 700}]}"
```

Note that the pillar parameter contains the string representation of a Python dicitionary.

**Step 4:** check that the created VM has the expected CPU and memory by running the following command.

```sh
salt 'kvm1*' virt.get_xml vm02
```


**Step 5 (*optional*):** use encrypted pillar data to store the root password.


### Exercise 1.8: create VMs as part of the highstate

In the previous exercise the virtual machine state needed to be applied manually.
The virtual machines creation can be included in the virtual host configuration using the highstate.

This exercise will enforce a `web` and a `db` virtual machines on the `kvm2.hol1313.net` server.

**Step 1:** edit the `/srv/salt/top.sls` file to add the following:

```yaml
  'kvm*':
    - vms
```

This will load the `vms.sls` state file for all the Salt minions with an id starting with `kvm`.
Note that the `.sls` extension of the file is not typed.

**Step 2:** add the pillar data

This alone is not enough since the `vms.sls` state needs pillar data for the virtual machine definitions.

Create the `/srv/pillar/vms_data.sls` file with the virtual machines definitions as described in the previous exercise.

Don't forget to add the activation key to the virtual machines since this will help automating their setup using Salt states later on.

**Step 3:** add pillar `top.sls`

This alone is not enough, Salt will look for a `/srv/pillar/top.sls` file as the entry point to load the pillar data.

Create the `/srv/pillar/top.sls` file with the following content:

```yaml
base:
  'kvm*':
    - vms_data
```

This will indicate Salt to load the `/srv/pillar/vms_data.sls` file in the pillar data of all minions with an id starting with `kvm`.

Like for the previous exercises, a solution can be found in the `SPOILERS` folder.

**Step 4:** verify the highstate before applying either using the web interface in the **States** tab of the system or by running this command on `srv.hol1313.net`:

```sh
salt 'kvm2*' state.show_highstate
```

**Step 5:** apply the highstate, either from the SUSE Manager web interface or by running this command on the server:

```sh
salt 'kvm2*' state.apply
```


### Exercise 1.9: virtual storage pools and networks using Salt

Virtual machines are using storage pools to store their disks.
They are also using virtual networks.
Both of these can be defined using Salt states too, but since they are still work in progress there are a few limitations.

The `virt.pool_running` state covers all the possible pool configurations.
However the `virt.network_running` only allows creating bridged networks.
Patches to handle natted networks have been integrated in upcoming versions, but handling all network options and types still remains to be done.
Simple states calling the `virsh` command line tool can be written as a temporary workaround.

**Step 1:** create a `/srv/salt/test_pool.sls` file containing the following YAML code:

```yaml
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

**Step 2:** copy the `private_network.sls` from the `course_files` folder into `/srv/salt/`.

This file defines a libvirt private network.
Take a moment to read this state; the important parts to notice are the dependencies definitions using both `require` and `watch`.
The `onlyif` parameter of the `cmd.run` state is also worth noting.
For more details on this parameter, check the Salt [`cmd.run` state documentation](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#salt.states.cmd.run)[^7].

[`libvirt` documentation](https://libvirt.org/formatnetwork.html)[^8] is also worth reading to understand the various options of a network configuration.

The next steps will use the newly added test storage pool and private network states to the `kvm2.hol1313.net` highstate.

**Step 3:** change the pillar to use the `test` pool instead of the `default` one for the `db` and `web` virtual machines.

**Step 4:** add interfaces using the `private` network

Using the `private` network requires a little more work since the existing `vms` state also needs to be extended to handle multiple network interfaces.

Modify the `db` and `web` virtual machines to have two interfaces: one using the `default` network, and one using the `private` one.

Again a solution can be found in the `SPOILERS` folder with the `*-final.sls` files.

**Step 5 (*optional*)**: add highstates for the `db` and `vms` virtual machines to install `postgresql` and `apache2` packages on them.

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

[^1]: https://documentation.suse.com/sles/15-SP1/html/SLES-all/book-virt.html
[^2]: https://documentation.suse.com/sles/15-SP1/html/SLES-all/article-vt-best-practices.html
[^3]: http://libguestfs.org/virt-customize.1.html
[^4]: https://docs.saltstack.com/en/latest/ref/states/requisites.html#requisites
[^5]: https://docs.saltstack.com/en/latest/topics/tutorials/pillar.html
[^6]: https://docs.saltstack.com/en/latest/topics/jinja/index.html
[^7]: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#salt.states.cmd.run
[^8]: https://libvirt.org/formatnetwork.html
