# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom_legacy::course::fundamentals (
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
    jvm_tuning_profile => $jvm_tuning_profile,
  }

  if $role == 'master' {
    class { 'classroom_legacy::master::showoff':
      course             => 'Fundamentals',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }

  class { 'classroom_legacy::facts':
    coursename => 'fundamentals',
  }
}
