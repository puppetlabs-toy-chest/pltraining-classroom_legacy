class classroom_legacy::windows {
  assert_private('This class should not be called directly')

  include classroom_legacy::windows::geotrust
  include classroom_legacy::windows::password_policy
  include classroom_legacy::windows::disable_esc
  include classroom_legacy::windows::alias

  include userprefs::npp

  package { ['console2', 'putty', 'unzip', 'devbox-common.extension']:
    ensure   => present,
    provider => 'chocolatey',
    require  => [ Class['chocolatey'], Package['chocolatey'] ],
  }

  package { 'chocolatey':
    ensure   => latest,
    provider => 'chocolatey',
    require  => Class['chocolatey'],
  }

  ini_setting { 'certname':
    ensure  => present,
    path    => "${classroom_legacy::params::confdir}/puppet.conf",
    section => 'main',
    setting => 'certname',
    value   => "${::hostname}.puppetlabs.vm",
  }

  # Symlink on the user desktop
  file { 'C:/Users/Administrator/Desktop/puppet_confdir':
    ensure => link,
    target => $classroom_legacy::params::confdir,
  }

  if $classroom_legacy::role == 'adserver' {
    class { 'classroom_legacy::windows::adserver':
      ad_domainname   => $classroom_legacy::ad_domainname,
      ad_dsrmpassword => $classroom_legacy::ad_dsrmpassword,
    }
    # Export AD server IP to be DNS server for agents
    @@classroom_legacy::windows::dns_server { 'primary_ip':
      ip => $::ipaddress,
    }
  }
  else {
    Classroom::Windows::Dns_server <<||>>
  }
}
