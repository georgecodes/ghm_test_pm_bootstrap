class puppetmaster {
  
  file { '/tmp/test':
    ensure => present,
    content => "this is a test files"
  }

}