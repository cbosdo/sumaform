include:
  - repos

git_packages:
  pkg.installed:
    - pkgs:
      - git-core
      - apache2
    - require:
      - sls: repos

apache_conf:
  file.managed:
    - name: /etc/apache2/conf.d/git.conf
    - source: salt://githost/apache.conf

apache_service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: git_packages
      - file: apache_conf

git_user:
  user.present:
    - name: git
    - shell: /usr/bin/git-shell
    - home: /srv/git/

git_shell:
  file.append:
    - name: /etc/shells
    - text: /usr/bin/git-shell

/srv/git/git-shell-commands:
  file.directory:
    - user: git
    - group: users
    - dir_mode: 755
    - require:
      - user: git_user

repo_init:
  cmd.run:
    - name: 'git -c http.sslVerify=false clone --mirror https://gitlab.suse.de/cbosdonnat/jeos-12-suma -b master /srv/git/jeos-12-manager'
    - runas: git
    - require:
      - user: git_user

post-update-hook:
  file.rename:
    - name: /srv/git/jeos-12-manager/hooks/post-update
    - source: /srv/git/jeos-12-manager/hooks/post-update.sample
    - require:
      - cmd: repo_init

git-update-server-info:
  cmd.run:
    - name: 'git update-server-info'
    - cwd: /srv/git/jeos-12-manager
    - runas: git
    - require:
      - file: post-update-hook
