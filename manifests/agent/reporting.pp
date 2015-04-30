class classroom::agent::reporting {
  file { '/usr/local/bin/process_reports.rb':
    ensure  => file,
    mode    => 755,
    source  => 'puppet:///modules/classroom/process_reports.rb',
    replace => false,
  }
}
