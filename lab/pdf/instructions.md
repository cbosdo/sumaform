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

# Setup hypervisor

* Accept Salt keys of KVM minion
* Add Virtualization entitlement in the properties
* See that the registration key dialog has Virtualization entitlement box

## Setup libvirt

* Add Virtualization host formula
* Edit the formula value
* Apply the highstate

## Install exporter for hypervisor

# Create VM from UI

# Create VM from Salt State

