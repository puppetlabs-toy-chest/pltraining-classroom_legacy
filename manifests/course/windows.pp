# This is a wrapper class to include all the bits needed for Fundamentals
#
class classroom_legacy::course::windows (
  $offline            = $classroom_legacy::params::offline,
  $manage_yum         = $classroom_legacy::params::manage_yum,
  $time_servers       = $classroom_legacy::params::time_servers,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  $event_id           = undef,
  $event_pw           = undef,
  $version            = undef,
) inherits classroom_legacy::params {
  class { 'classroom_legacy::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-we.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    class { 'classroom_legacy::master::showoff':
      course             => 'WindowsEssentials',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }

  if $::osfamily == 'Windows' {
    include classroom_legacy::windows
  }
}
