# This class configures the agent with
#  * root sshkey
#  * git source repository
#  * git pre-commit hook
#  * hiera configuration
#  * time synchronization with the classroom master
class classroom_legacy::agent {
  assert_private('This class should not be called directly')

  # A valid clientcert is not necessarily a valid Puppet environment name!
  validate_re($classroom_legacy::machine_name, '^(?=.*[a-z])\A[a-z0-9][a-z0-9._]+\z', "The classroom environment supports lowercase alphanumeric hostnames only. '${classroom_legacy::machine_name}' is an invalid hostname. Please ask your instructor for assistance.")

  # windows goodies
  if $::osfamily  == 'windows' {
    include classroom_legacy::windows
  }
  else {
    # /etc/puppet/ssl is confusing to have around. Sloppy. Kill.
    file {'/etc/puppet':
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }

  # ensure all nodes have this user, since it's used for file ownership in places
  user { 'pe-puppet':
    ensure => present,
  }

  # make sure our git environment is set up and usable
  include classroom_legacy::agent::git

  # Make sure that Hiera is configured for all nodes so that we
  # can work through the hiera sections without teaching them
  # how to configure it.
  include classroom_legacy::agent::hiera

  # Ensure that the time is always synced with the classroom master
  include classroom_legacy::agent::time

  # Configure basemodulepath for online or offline instruction
  include classroom_legacy::agent::modulecache

  # export a classroom_legacy::user with our ssh key.
  #
  # !!!! THIS MAY EXPORT AN EMPTY KEY ON THE FIRST RUN !!!!
  #
  # On the second run, the ssh key will exist and so this fact will be set.
  @@classroom_legacy::user { $::classroom_legacy::params::machine_name:
    key         => $::root_ssh_key,
    password    => $classroom_legacy::password,
    consolepw   => $classroom_legacy::consolepw,
    manage_repo => $classroom_legacy::manage_repos,
  }

  # if we are managing git repositories, then build out all this
  if $classroom_legacy::manage_repos {

    classroom_legacy::agent::workdir { $classroom_legacy::workdir:
      ensure   => present,
      username => $classroom_legacy::params::machine_name,
      require  => Class['classroom_legacy::agent::git'],
    }
  }
}
