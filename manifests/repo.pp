# @summary
#   Manages the packages.icinga.com repository based on the operating system.
#
# @api private
#
class icingaweb2::repo {

  assert_private("You're not supposed to use this defined type manually.")

  if $::icingaweb2::manage_repo and $::icingaweb2::manage_package {

    case $::facts['os']['family'] {
      'redhat': {
        case $::facts['os']['name'] {
          'centos', 'redhat': {
            yumrepo { 'icinga-stable-release':
              baseurl  => "http://packages.icinga.com/epel/${::facts['os']['release']['major']}/release/",
              descr    => 'ICINGA (stable release for epel)',
              enabled  => 1,
              gpgcheck => 1,
              gpgkey   => 'http://packages.icinga.com/icinga.key',
            }
          }
          'fedora': {
            yumrepo { 'icinga-stable-release':
              baseurl  => "http://packages.icinga.com/fedora/${::facts['os']['release']['major']}/release/",
              descr    => 'ICINGA (stable release for fedora)',
              enabled  => 1,
              gpgcheck => 1,
              gpgkey   => 'http://packages.icinga.com/icinga.key',
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
      }
      'debian': {
        case $::facts['os']['name'] {
          'debian': {
            include ::apt, ::apt::backports
            apt::source { 'icinga-stable-release':
              location => 'http://packages.icinga.com/debian',
              release  => "icinga-${::facts['lsbdistcodename']}",
              repos    => 'main',
              key      => {
                id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
                source => 'http://packages.icinga.com/icinga.key',
              };
            }
          }
          'ubuntu': {
            include ::apt
            apt::source { 'icinga-stable-release':
              location => 'http://packages.icinga.com/ubuntu',
              release  => "icinga-${::facts['lsbdistcodename']}",
              repos    => 'main',
              key      => {
                id     => 'F51A91A5EE001AA5D77D53C4C6E319C334410682',
                source => 'http://packages.icinga.com/icinga.key',
              };
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
        contain ::apt::update
      }
      'suse': {

        file { '/etc/pki/GPG-KEY-icinga':
          ensure => present,
          source => 'http://packages.icinga.com/icinga.key',
        }

        exec { 'import icinga gpg key':
          path      => '/bin:/usr/bin:/sbin:/usr/sbin',
          command   => 'rpm --import /etc/pki/GPG-KEY-icinga',
          unless    => 'rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < /etc/pki/GPG-KEY-icinga) | cut --characters=11-18 | tr [A-Z] [a-z]',
          require   => File['/etc/pki/GPG-KEY-icinga'],
          logoutput => 'on_failure',
        }

        case $::facts['os']['name'] {
          'SLES': {
            zypprepo { 'icinga-stable-release':
              baseurl  => "http://packages.icinga.com/SUSE/${::facts['os']['release']['full']}/release/",
              enabled  => 1,
              gpgcheck => 1,
              require  => Exec['import icinga gpg key']
            }
          }
          default: {
            fail('Your plattform is not supported to manage a repository.')
          }
        }
      }
      default: {
        fail('Your plattform is not supported to manage a repository.')
      }
    }
  } # if $::icinga::manage_repo
}
