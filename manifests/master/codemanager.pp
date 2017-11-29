# Configuration for PE code manager to avoid chicken -> egg -> chicken
class classroom_legacy::master::codemanager (
  $control_repo,
) inherits classroom_legacy::params {
  assert_private('This class should not be called directly')

  $control_owner = $classroom_legacy::params::control_owner
  $gitserver     = $classroom_legacy::params::gitserver

  pe_hocon_setting { 'enable code manager':
    ensure  => present,
    path    => '/etc/puppetlabs/enterprise/conf.d/common.conf',
    setting => '"puppet_enterprise::profile::master::code_manager_auto_configure"',
    value   => true,
  }

  pe_hocon_setting { 'production control repo':
    ensure  => present,
    path    => '/etc/puppetlabs/enterprise/conf.d/common.conf',
    setting => '"puppet_enterprise::master::code_manager::sources".main',
    value   => { 'remote' => "${gitserver}/${control_owner}/${control_repo}" },
  }


  # duplicated in a hiera datasource. because reasons.
  $hieradata = "${classroom_legacy::params::confdir}/hieradata"
  # we will likely never go back to the per-user fork model, but we should keep
  # this until we rip it out across the board.
  $replace   = $classroom_legacy::params::repo_model ? {
    'single'  => true,
    'peruser' => false, # the puppetfactory hook must be able to update this list!
  }
  file { "${hieradata}/sources.yaml":
    ensure  => file,
    content => epp('classroom_legacy/hiera/data/sources.yaml.epp', {
                                      'gitserver'     => $gitserver,
                                      'control_owner' => $control_owner,
                                      'control_repo'  => $control_repo }),
  }
}
