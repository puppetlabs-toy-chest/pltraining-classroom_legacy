# This is a wrapper class to include all the bits needed for Architect
#
class classroom_legacy::course::architect (
  $offline            = $classroom_legacy::params::offline,
  $manage_yum         = $classroom_legacy::params::manage_yum,
  $time_servers       = $classroom_legacy::params::time_servers,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  $event_id           = undef,
  $event_pw           = undef,
  $version            = undef,
) inherits classroom_legacy::params {
  # just wrap the classroom class
  class { 'classroom_legacy':
    offline            => $offline,
    role               => $role,
    manage_yum         => $manage_yum,
    time_servers       => $time_servers,
    manage_repos       => false,
    jvm_tuning_profile => $jvm_tuning_profile,
  }

  if $role == 'master' {
    # Collect all hosts
    include classroom_legacy::agent::hosts

    # set up graphite/grafana on the classroom master
    include classroom_legacy::master::graphite

    # include metrics tools for labs & demos
    include classroom_legacy::master::metrics

    # Host docker registiry on master
    include classroom_legacy::master::docker_registry

    class { 'classroom_legacy::master::showoff':
      course             => 'Architect',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }
  elsif $role == 'agent' {
    # tools used in class
    include classroom_legacy::master::reporting_tools

    # Collect all hosts
    include classroom_legacy::agent::hosts

    # include metrics tools for labs & demos
    include classroom_legacy::master::metrics

    # The student masters should export a balancermember
    include classroom_legacy::master::balancermember

    # The autoscaling seems to assume that you'll sync this out from the MoM
    include classroom_legacy::master::student_environment

    # Set up agent containers on student masters
    include classroom_legacy::containers

  }

  class { 'classroom_legacy::facts':
    coursename => 'architect',
  }
}
