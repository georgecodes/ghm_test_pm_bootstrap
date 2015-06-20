class puppetmaster {

  package { 'git':
    ensure => present,
  }

  package { 'r10k_package':
    name  => 'r10k',
    provider => 'gem',
    ensure   => present,
  }

  file { 'r10k':
    path => '/etc/r10k.yaml',
    owner => 'root',
    mode  => '0600',
    source => 'puppet:///modules/puppetmaster/r10k.yaml',
    require => Package['r10k_package'],
  }

  file { 'hiera':
    path   => '/etc/puppet/hiera.yaml',
    ensure => present,
    owner  => 'puppet',
    mode   => '0600',
    source => 'puppet:///modules/puppetmaster/hiera.yaml'
  }

  exec { 'r10kinit':
    command => 'r10k deploy environment',
    path  => ['/usr/local/bin', '/usr/bin'],
    cwd   => '/etc/',
    creates => '/etc/puppet/environment',
    require => [ Package['r10k_package'], File['r10k']],
    user  => 'root'
  }

  file { 'env':
    ensure => present,
    path => '/etc/puppet/environments/GHM_develop/environment.conf',
    owner => 'puppet',
    mode  => '0664',
    source => 'puppet:///modules/puppetmaster/environment.conf',
    require => Exec['r10kinit'],
  }



  file { 'enc':
    ensure => directory,
    path   => '/etc/puppet/enc',
    owner  => 'puppet',
    mode   => '0700',
    source => 'puppet:///modules/puppetmaster/enc',
    recurse => true
  }

  file { 'puppetconf':
    path   => '/etc/puppet/puppet.conf',
    ensure => present,
    owner  => 'puppet',
    mode   => '0600',
    source => 'puppet:///modules/puppetmaster/puppet.conf'
  }

  file {'manifest_dir':
    path => '/etc/puppet/environments/GHM_develop/manifests',
    ensure => directory,
    owner  => 'puppet',
    mode   => '0700',
    require => Exec['r10kinit']
  }

  file { 'sitepp':
    ensure => present,
    path   => '/etc/puppet/environments/GHM_develop/manifests/site.pp',
    owner  => 'puppet',
    mode   => '0600',
    source => 'puppet:///modules/puppetmaster/site.pp',
    require => File['manifest_dir']
  }

  file { 'autosign':
    ensure  => present,
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    mode    => '0600',
    source  => 'puppet:///modules/puppetmaster/autosign.conf'
  }

  file { 'initscript':
    ensure   => present,
    path     => '/etc/init.d/puppetmaster',
    owner    => 'root',
    mode     => '0700',
    source   => 'puppet:///modules/puppetmaster/initscript'
  }

  service { 'puppetmaster':
    ensure  => running,
    enable  => true,
    hasrestart => true,
    require   => [File['initscript'], Exec['r10kinit']]
  }

}