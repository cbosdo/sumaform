{% if grains.get('role') == 'mirror' %}

# We need that repository for apt-mirror
tools_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: salt://repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja

{% endif %}

