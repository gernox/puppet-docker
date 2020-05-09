# @summary
#   Manages Docker Swarm installation
#
# @param manager_ip
#   IP of swarm manager
#
# @param join_token
#   Swarm join token
#
# @param join
#   Join a swarm?
#
# @param init
#   Init a swarm?
#
class gernox_docker::swarm (
  String $manager_ip,
  # join token determines if this node
  # will be a manager or worker
  String $join_token,
  String $ipaddress       = $::ipaddress,
  String $hostname        = $::hostname,
  # only for cluster initialization, you have been warned!
  Optional[Boolean] $join = true,
  Optional[Boolean] $init = false,
) {
  contain gernox_docker

  docker::swarm { "swarm_${hostname}":
    init           => $init,
    join           => $join,
    advertise_addr => $ipaddress,
    listen_addr    => $ipaddress,
    manager_ip     => $manager_ip,
    token          => $join_token,
    require        => Service['docker'],
  }
}
