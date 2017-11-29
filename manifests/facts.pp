# This class writes out some moderately interesting external facts. These are
# useful for demonstrating structured facts.
#
# Their existence also serves as a marker that initial provisioning has taken
# place, for the small handful of items that we only want to manage once.
#
class classroom_legacy::facts (
  $coursename,
  $role = $classroom_legacy::params::role,
) inherits classroom_legacy::params {

  $dot_d = "${classroom_legacy::params::factdir}/facts.d/"

  file { [ $classroom_legacy::params::factdir, $dot_d ]:
    ensure => directory,
  }

  file { "${dot_d}/puppetlabs.txt":
    ensure  => file,
    content => template('classroom_legacy/facts.txt.erb'),
  }
}
