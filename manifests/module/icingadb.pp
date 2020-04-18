# == Class: icingaweb2::module::icingadb
#
# Manage the icingadb module.
#
# === Parameters
#
# [*ensure*]
#   Enable or disable module. Defaults to `present`
#
# [*protected_customvars*]
#   Custom variables in Icinga 2 may contain sensible information. Set patterns for custom variables that should be
#   hidden in the web interface. Defaults to `*pw*,*pass*,community`
#
# [*db_type*]
#   Type of your IcingaDB database. Either `mysql` or `pgsql`. Defaults to `mysql`
#
# [*db_host*]
#   Hostname of the cingaDB database.
#
# [*db_port*]
#   Port of the IcingaDB database. Defaults to `3306`
#
# [*db_db_name*]
#   Name of the IcingaDB database.
#
# [*db_username*]
#   Username for IcingaDB connection.
#
# [*db_password*]
#   Password for IcingaDB connection.
#
# [*ido_db_charset*]
#   The character set to use for the database connection.
#
# [*commandtransports*]
#   A hash of command transports.
#
class icingaweb2::module::icingadb(
  Enum['absent', 'present']      $ensure               = 'present',
  String                         $git_repository       = 'https://github.com/Icinga/icingadb-web.git',
  Optional[String]               $git_revision         = undef,
  Variant[String, Array[String]] $protected_customvars = ['*pw*', '*pass*', 'community'],
  Enum['mysql', 'pgsql']         $db_type              = 'mysql',
  Optional[String]               $db_host              = undef,
  Integer[1,65535]               $db_port              = 3306,
  Optional[String]               $db_name              = undef,
  Optional[String]               $db_username          = undef,
  Optional[String]               $db_password          = undef,
  Optional[String]               $db_charset           = undef,
  Hash                           $commandtransports    = undef,
  Struct[{
    Optional[redis1] => Icingaweb2::Redis,
    Optional[redis2] => Icingaweb2::Redis,
  }]                             $redis                = {},
){

  $conf_dir        = $::icingaweb2::params::conf_dir
  $module_conf_dir = "${conf_dir}/modules/icingadb"

  icingaweb2::config::resource { 'icinga_db':
    type        => 'db',
    db_type     => $db_type,
    host        => $db_host,
    port        => $db_port,
    db_name     => $db_name,
    db_username => $db_username,
    db_password => $db_password,
    db_charset  => $db_charset,
  }

  $database_settings = {
    'type'     => 'db',
    'resource' => 'icinga_db',
  }

  $security_settings = {
    'protected_customvars' => $protected_customvars ? {
      String        => $protected_customvars,
      Array[String] => join($protected_customvars, ','),
    }
  }

  unless $redis['redis1'] {
    $redis1 = { host => 'localhost' }
  } else {
    $redis1 = $redis['redis1']
  }

  unless $redis['redis2'] {
    $redis2 = {}
  } else {
    $redis2 = $redis['redis2']
  }

  $settings = {
    'module-icingadb-database' => {
      'section_name' => 'icingadb',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($database_settings)
    },
    'module-icingadb-redis-1' => {
      'section_name' => 'redis1',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($redis1),
    },
    'module-icingadb-redis-2' => {
      'section_name' => 'redis2',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => delete_undef_values($redis2),
    },
    'module-icingadb-security' => {
      'section_name' => 'security',
      'target'       => "${module_conf_dir}/../monitoring/config.ini",
      'settings'     => delete_undef_values($security_settings),
    },
  }

  create_resources('icingaweb2::module::monitoring::commandtransport', $commandtransports)

  icingaweb2::module { 'icingadb':
    ensure         => $ensure,
    git_repository => $git_repository,
    git_revision   => $git_revision,
    settings       => $settings,
  }
}
