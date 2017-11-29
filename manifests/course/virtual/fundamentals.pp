# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom_legacy::course::virtual::fundamentals (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  $offline            = $classroom_legacy::params::offline,
  $version            = undef,
) inherits classroom_legacy::params {
  class { 'classroom_legacy::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-vf.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom_legacy::facts':
      coursename => 'fundamentals',
    }

    class { 'classroom_legacy::master::showoff':
      course             => 'VirtualFundamentals',
      event_id           => $event_id,
      event_pw           => $event_pw,
      variant            => 'virtual',
      version            => $version,
    }
  }
}
