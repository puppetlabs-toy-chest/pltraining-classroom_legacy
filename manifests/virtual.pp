# common configuration for all virtual classes
class classroom_legacy::virtual (
  String                                  $control_repo,
  Optional[Pattern[/\A(?:\w*-)+(\w*)\Z/]] $event_id           = undef,
  Optional[String]                        $event_pw           = undef,
  Variant[Enum['reduced'], Boolean]       $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
  Boolean                                 $offline            = $classroom_legacy::params::offline,
  Array                                   $plugin_list        = $classroom_legacy::params::plugin_list,
) inherits classroom_legacy::params {
  assert_private('This class should not be called directly')

  if $classroom_legacy::params::role == 'master' {
    include showoff
    include classroom_legacy::master::dependencies::rubygems
    include classroom_legacy::master::dependencies::dashboard

    # Configure Hiera and install a Hiera data file to tune PE
    class { 'classroom_legacy::master::tuning':
      jvm_tuning_profile => $jvm_tuning_profile,
    }

    # make sure we have a deployment user
    include classroom_legacy::master::deployer

    # Configure performance logging
    include classroom_legacy::master::perf_logging

    # Set up gitea server
    include classroom_legacy::master::gitea

    $session_id = pick($event_pw, regsubst(String($event_id), '^(?:\w*-)+(\w*)$', '\1'), $classroom_legacy::params::session_id)

    class { 'puppetfactory':
      controlrepo      => $control_repo,
      plugins          => $plugin_list,
      gitserver        => $classroom_legacy::params::gitserver,
      repomodel        => $classroom_legacy::params::repo_model,
      usersuffix       => $classroom_legacy::params::usersuffix,
      dashboard_path   => "${showoff::root}/courseware/_files/tests",
      session          => $session_id,
      master           => $fqdn,
      privileged       => false,
    }

    class { 'classroom_legacy::master::codemanager':
      control_repo => $control_repo,
    }

  } elsif $classroom_legacy::params::role == 'proxy' {
    include classroom_legacy::proxy

  } else {
    # ensure all nodes have this user, since it's used for file ownership in places
    user { 'pe-puppet':
      ensure => present,
    }

    # if we ever have universal classification for virtual agents, it will go here
    include classroom_legacy::agent::hiera
    include classroom_legacy::agent::packages
    include classroom_legacy::agent::rubygems

    unless $osfamily == 'windows' {
      include classroom_legacy::agent::postfix_ipv4

      # enable the local yum cache configured by puppetfactory
      yumrepo { 'local':
        ensure   => 'present',
        baseurl  => 'file:///var/yum/mirror',
        enabled  => '1',
        gpgcheck => '0',
        priority => '1',
      }

    }
  }

  # configure gem installs
  class { 'classroom_legacy::gemrc':
    offline => $offline,
  }

  if $::osfamily == 'windows' {
    # TODO: copied from classroom_legacy::windows; we should refactor both classes for reusability
    user { 'Administrator':
      ensure => present,
      groups => ['Administrators'],
    }

    chocolateyfeature { 'allowEmptyChecksums':
      ensure => enabled,
    }
    Chocolateyfeature['allowEmptyChecksums'] -> Package<| provider == 'chocolatey' |>

    # Windows Agents
    class {'chocolatey':
      chocolatey_download_url => 'https://chocolatey.org/api/v2/package/chocolatey/0.10.3',
    }

    include classroom_legacy::windows::disable_esc
    include classroom_legacy::windows::enable_rdp
    include classroom_legacy::windows::geotrust
    windows_env { 'PATH=C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin': }
  }

  # fix augeas lens until it's updated in PE
  include classroom_legacy::agent::augeas
}
