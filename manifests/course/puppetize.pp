# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom_legacy::course::puppetize (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  $offline            = $classroom_legacy::params::offline,
  $version            = undef,
) inherits classroom_legacy::params {
  class { 'classroom_legacy::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-pi.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
    plugin_list        => flatten([$classroom_legacy::params::plugin_list, "Gitviz" ]),
  }

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom_legacy::master::hiera

    class { 'classroom_legacy::facts':
      coursename => 'puppetizing',
    }

    class { 'classroom_legacy::master::showoff':
      course             => 'Puppetize',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }

    file { '/usr/local/bin/validate_classification.rb':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/classroom_legacy/validation/puppetize.rb',
    }
  }

  # All nodes
  include classroom_legacy::agent::git
}
