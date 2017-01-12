# Completely ignore non-RHEL based systems
{% if grains['os_family'] == 'RedHat' %}
# A lookup table for EPEL GPG keys & RPM URLs for various RedHat releases
{% if grains['osmajorrelease'][0] == '5' %}
  {% set pkg = {
    'key': 'https://getfedora.org/static/217521F6.txt',
    'key_hash': 'md5=895459095f6dda788e022bb15a177a73',
    'rpm': 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm',
  } %}
{% elif grains['osmajorrelease'][0] == '6' %}
  {% set pkg = {
    'key': 'https://getfedora.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  } %}
{% elif grains['osmajorrelease'][0] == '7' %}
  {% set pkg = {
    'key': 'https://getfedora.org/static/352C64E5.txt',
    'key_hash': 'md5=2bab86176f606dc3a89deb55c8fbb41a',
    'rpm': 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
  } %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2014' %}
  {% set pkg = {
    'key': 'https://getfedora.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  } %}
{% elif grains['os'] == 'Amazon' and grains['osmajorrelease'] == '2015' %}
  {% set pkg = {
    'key': 'https://getfedora.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  } %}
{% endif %}


install_pubkey_epel:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
    - source: {{ salt['pillar.get']('epel:pubkey', pkg.key) }}
    - source_hash:  {{ salt['pillar.get']('epel:pubkey_hash', pkg.key_hash) }}


epel_release:
  pkg.installed:
    - sources:
      - epel-release: {{ salt['pillar.get']('epel:rpm', pkg.rpm) }}
    - require:
      - file: install_pubkey_epel

set_pubkey_epel:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL'
    - require:
      - pkg: epel_release

set_gpg_epel:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/epel.repo
    - pattern: 'gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: epel_release

{% if salt['pillar.get']('epel:disabled', False) %}
disable_epel:
  file.replace:
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=0'
{% else %}
enable_epel:
  file.replace:
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=1'
{% endif %}

{% if salt['pillar.get']('epel:testing', False) %}
enable_epel_testing:
  file.replace:
    - name: /etc/yum.repos.d/epel-testing.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=1'
{% else %}
disable_epel_testing:
  file.replace:
    - name: /etc/yum.repos.d/epel-testing.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=0'
{% endif %}
{% endif %}
