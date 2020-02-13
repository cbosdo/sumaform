# Instructions

This folder contains the SUSECon Hands-on specific files.
The workflow is the following:

* Run `git submodule init; git submodule update` to pull the installer
* Copy `main.tf.hol1313` as `main.tf` in the parent folder
* Run the `prepare-vms` script. Ensure the terminal has a light background to read all the output.
  So far this file only contains manual steps to run and will hopefully be automated later.
* Do any manual change that is needed on the virtual machines
* Run the `package.sh` script to create the installer package

Note that creating the installer package compresses the disk images.
It takes time and CPU to do it!

# Dependencies

* Pandoc with LaTeX converter to generate the PDF documentation from Markdown
* All sumaform dependencies, including libvirt and QEMU/KVM
