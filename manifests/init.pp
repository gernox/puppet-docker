# @summary
#   Manages basic Docker installation and configuration
#
# @param listen_address
#   Docker tcp bind address
#
# @param listen_port
#   Docker tcp bind port
#
# @param version
#   Version to pin docker ce version
#
# @param registries
#   List of custom docker registries
#
class gernox_docker (
  String  $listen_address,
  Integer $listen_port,
  String  $version,
  Boolean $iptables,
  Optional[Hash] $registries = {},
  Optional[Array] $dns       = undef,
) {
  file { '/etc/docker/':
    ensure => directory,
  }
  -> file { '/etc/docker/daemon.json':
    ensure  => present,
    content => file('gernox_docker/daemon.json'),
  }

  class { '::docker':
    tcp_bind => "tcp://${listen_address}:${listen_port}",
    version  => $version,
    iptables => $iptables,
    dns      => $dns,
    require  => File['/etc/docker/daemon.json']
  }

  class { '::docker::compose':
    ensure => present,
  }

  class { '::docker::registry_auth':
    registries => $registries,
  }

  # pin docker-ce version if specific version wanted
  if $version != 'present' {
    file { '/etc/apt/preferences.d/docker-ce.pref':
      ensure  => present,
      content => template('gernox_docker/docker-pin.erb'),
    }
  }

  # Job for cleaning up unused images
  file { '/etc/systemd/system/docker-system-prune.service':
    ensure  => present,
    content => template('gernox_docker/docker-system-prune.service.erb'),
    notify  => Service['docker-system-prune'],
  }

  file { '/etc/systemd/system/docker-system-prune.timer':
    ensure  => present,
    content => template('gernox_docker/docker-system-prune.timer.erb'),
    notify  => Service['docker-system-prune'],
  }

  service { 'docker-system-prune':
    ensure   => running,
    enable   => true,
    name     => 'docker-system-prune.timer',
    provider => 'systemd',
    require  => [
      File['/etc/systemd/system/docker-system-prune.timer'],
      File['/etc/systemd/system/docker-system-prune.service'],
    ],
  }
}
