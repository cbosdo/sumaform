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

Introduction slides:

* How Virt SUMA works
* Monitoring
* Agenda
* Virt Slides

* Setup hypervisor
  * Setup libvirt
  * Install exporter for hypervisor
* Create VM from UI
* Create VM from Salt State

Monitoring Slides

* Create Prometheus and Grafana using formula
* Create activation key
* Onboard VM with activation key -> automatically monitored
* Prepare dashboard
