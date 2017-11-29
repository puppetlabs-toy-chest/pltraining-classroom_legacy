# This is a wrapper class to include all the bits needed for Practitioner
#
class classroom_legacy::course::practitioner (
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
    # master gets reporting scripts
    include classroom_legacy::master::reporting_tools
    include classroom_legacy::master::sudoers

    class { 'classroom_legacy::master::showoff':
      course             => 'Practitioner',
      event_id           => $event_id,
      event_pw           => $event_pw,
      version            => $version,
    }
  }
  elsif $role == 'agent' {
    puppet_enterprise::mcollective::client { 'peadmin':
      activemq_brokers => ['master.puppetlabs.vm'],
      keypair_name     => 'pe-internal-peadmin-mcollective-client',
      create_user      => true,
      logfile          => '/var/lib/peadmin/.mcollective.d/client.log',
      stomp_password   => chomp(file('/etc/puppetlabs/mcollective/credentials','/dev/null')),
      stomp_port       => 61613,
      stomp_user       => 'mcollective',
    }
  }

  class { 'classroom_legacy::facts':
    coursename => 'practitioner',
  }
}
