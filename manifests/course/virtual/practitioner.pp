# typing the parameters doesn't actually gain us anything, since the
# Console doesn't provide any hinting. Subclasses validate types.
class classroom_legacy::course::virtual::practitioner (
  $event_id           = undef,
  $event_pw           = undef,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  $offline            = $classroom_legacy::params::offline,
  $version            = undef,
) inherits classroom_legacy::params {
  class { 'classroom_legacy::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
    control_repo       => 'classroom-control-vp.git',
    event_id           => $event_id,
    event_pw           => $event_pw,
  }

  if $role == 'master' {
    File {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    include classroom_legacy::master::reporting_tools

    class { 'classroom_legacy::facts':
      coursename => 'practitioner',
    }

    class { 'classroom_legacy::master::showoff':
      course             => 'VirtualPractitioner',
      event_id           => $event_id,
      event_pw           => $event_pw,
      variant            => 'virtual',
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

}
