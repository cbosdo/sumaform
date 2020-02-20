{% if grains['id'].startswith('kvm2') %}
vms:
  - name: web
    activation_key: 1-SLE-15-SP1
    pool: test
    networks:
     - default
     - private
  - name: db
    activation_key: 1-SLE-15-SP1
    pool: test
    networks:
     - default
     - private
{% endif %}
