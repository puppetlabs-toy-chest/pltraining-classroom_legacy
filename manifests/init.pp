# Configure the training classroom environment.
#
# classroom_legacy::agent
#   * set up the agent with an sshkey for root
#   * set up a git working directory for the user
#   * point a git remote to the repo on the puppet master
#   * export a classroom_legacy::user account
#       * this depends on a root_ssh_key fact so this user
#         account won't be exported properly on first run
#
# classroom_legacy::master
#   * prepares the master's environment
#   * creates a git repository root
#   * creates an environment root for checking out working copies
#   * instantiate all exported classroom_legacy::users
#       * creates a shell user with ssh key
#       * creates a puppet.conf environment fragment
#       * creates a bare repository in repo root
#       * checks out a working copy in the environments root
#
#
# $offline   : Configure NTP (and other services) to run in standalone mode
#              Sets up local gitea git service.
# $role      : What classroom role this node should play
#
class classroom_legacy (
  $offline            = $classroom_legacy::params::offline,
  $role               = $classroom_legacy::params::role,
  $manage_yum         = $classroom_legacy::params::manage_yum,
  $manage_repos       = $classroom_legacy::params::manage_repos,
  $manage_selinux     = $classroom_legacy::params::manage_selinux,
  $time_servers       = $classroom_legacy::params::time_servers,
  $repositories       = $classroom_legacy::params::repositories,
  $jvm_tuning_profile = $classroom_legacy::params::jvm_tuning_profile,
) inherits classroom_legacy::params {
  validate_bool($offline)
  validate_bool($manage_yum)
  validate_bool($manage_repos)
  validate_bool($manage_selinux)
  validate_array($time_servers)

  case $role {
    'master'   : { class { 'classroom_legacy::master':
                     jvm_tuning_profile => $jvm_tuning_profile,
                   }
                 }
    'agent'    : { include classroom_legacy::agent      }
    'adserver' : { include classroom_legacy::agent      }
    'proxy'    : { include classroom_legacy::proxy      }
    default    : { fail("Unknown role: ${role}") }
  }

  include classroom_legacy::repositories

  # configure gem installs
  class { 'classroom_legacy::gemrc':
    offline => $offline,
  }

  # trust classroom CA so students can download from the master
  include classroom_legacy::cacert

  # fix augeas lens until it's updated in PE
  include classroom_legacy::agent::augeas
}
