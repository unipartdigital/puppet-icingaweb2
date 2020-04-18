package { 'git': }

class { 'mysql::server':
  override_options => {
    'mysqld' => {
      innodb_file_format => 'barracuda',   
      innodb_file_per_table => 1, 
      innodb_large_prefix => 1,
    },
  },
}

mysql::db { 'icingaweb2':
  user     => 'icingaweb2',
  password => 'icingaweb2',
  host     => 'localhost',
  grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
}

class { 'icinga::repos':
  manage_release => false,
  manage_testing => true,
  manage_epel    => true,
  configure_scl  => true,
}

class { '::php::globals':
  php_version => 'rh-php73',
  rhscl_mode  => 'rhscl',
}

class { '::php':
  ensure        => installed,
  manage_repos  => false,
  apache_config => false,
  fpm           => true,
  extensions    => {
    mbstring => { ini_prefix => '20-' },
    json     => { ini_prefix => '20-' },
    ldap     => { ini_prefix => '20-' },
    gd       => { ini_prefix => '20-' },
    xml      => { ini_prefix => '20-' },
    intl     => { ini_prefix => '20-' },
    mysqlnd  => { ini_prefix => '20-' },
    pgsql    => { ini_prefix => '20-' },
    redis    => { ini_prefix => '50-' },
  },
  dev           => false,
  composer      => false,
  pear          => false,
  phpunit       => false,
  require       => Class['::php::globals'],
}

class {'icingaweb2':
  manage_repo   => true,
  import_schema => true,
  db_type       => 'mysql',
  db_host       => 'localhost',
  db_port       => 3306,
  db_username   => 'icingaweb2',
  db_password   => 'icingaweb2',
  require       => Mysql::Db['icingaweb2'],
}

class { 'icingaweb2::module::ipl':
  git_revision => 'v0.5.0',
}

class { '::apache':
  default_mods  => false,
  default_vhost => false,
  mpm_module    => 'worker',
}

apache::listen { '80': }
  
include ::apache::mod::alias
include ::apache::mod::status
include ::apache::mod::dir
include ::apache::mod::env
include ::apache::mod::rewrite
include ::apache::mod::proxy
include ::apache::mod::proxy_fcgi
  
apache::custom_config { 'icingaweb2':
  ensure        => present,
  source        => 'puppet:///modules/icingaweb2/examples/apache2/for-mod_proxy_fcgi.conf',
  verify_config => false,
  priority      => false,
}

class {'icingaweb2::module::icingadb':
  db_host              => 'localhost',
  db_name              => 'icingadb',
  db_username          => 'icingadb',
  db_password          => 'icingadb',
  protected_customvars => ['*pw*', '*pass*', 'community', 'testabc'],
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'root',
      password  => 'icinga',
    }
  },
}
