# Manage yum (and maybe someday apt) repositories in the classroom.
class classroom_legacy::repositories {
  assert_private('This class should not be called directly')

  if $classroom_legacy::manage_yum and $::osfamily == 'RedHat' {

     $enabled = $classroom_legacy::offline ? {
      true  => '0',
      false => '1',
    }

    yumrepo { $classroom_legacy::repositories:
      enabled => $enabled,
    }
    # Don't choke if another module has "include epel"
    if ! defined(Class['epel']) {
      class { 'epel':
        epel_enabled => $enabled,
      }
    }
  }

}
