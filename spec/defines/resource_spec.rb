require 'spec_helper'

describe('icingaweb2::config::resource', :type => :define) do
  let(:title) { 'myresource' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with type db" do
        let(:params) { {
            :type => 'db',
            :host => 'localhost',
            :port => 3306,
            :db_type => 'mysql',
            :db_name => 'foo',
            :db_username => 'bar',
            :db_password => 'secret' } }

        it { is_expected.to contain_icingaweb2__inisection('resource-myresource')
          .with_target('/etc/icingaweb2/resources.ini')
          .with_settings({'type'=>'db', 'db'=>'mysql', 'host'=>'localhost', 'port'=>'3306', 'dbname'=>'foo', 'username'=>'bar', 'password'=>'secret'}) }

      end

      context "#{os} with db_type mysql and ssl enabled" do
        let(:params) { {
            :type => 'db',
            :host => 'localhost',
            :port => 3306,
            :db_type => 'mysql',
            :db_name => 'foo',
            :db_username => 'bar',
            :db_password => 'secret',
            :db_use_ssl => true,
            :db_ssl_cert => '/tmp/cert',
            :db_ssl_key => '/tmp/key',
            :db_ssl_ca => '/tmp/ca',
            :db_ssl_capath => '/tmp/capath',
            :db_ssl_cipher => 'MY-CIPHER'
        }}

        it { is_expected.to contain_icingaweb2__inisection('resource-myresource')
          .with_target('/etc/icingaweb2/resources.ini')
          .with_settings({'type'=>'db', 'db'=>'mysql', 'host'=>'localhost', 'port' => '3306', 'dbname'=>'foo', 'username'=>'bar', 'password'=>'secret',
                         'use_ssl'=>'true', 'ssl_cert'=>'/tmp/cert', 'ssl_key'=>'/tmp/key', 'ssl_ca'=>'/tmp/ca', 'ssl_capath'=>'/tmp/capath', 'ssl_cipher'=>'MY-CIPHER'})
        }

      end

      context "#{os} with type ldap" do
        let(:params) { {
            :type => 'ldap',
            :host => 'localhost',
            :port => 389,
            :ldap_root_dn => 'cn=foo,dc=bar',
            :ldap_bind_dn => 'cn=root,dc=bar',
            :ldap_bind_pw => 'secret' } }

        it { is_expected.to contain_icingaweb2__inisection('resource-myresource')
          .with_target('/etc/icingaweb2/resources.ini')
          .with_settings({'type'=>'ldap', 'hostname'=>'localhost', 'port'=>'389', 'root_dn'=>'cn=foo,dc=bar', 'bind_dn'=>'cn=root,dc=bar', 'bind_pw'=>'secret', 'encryption'=>'none'})}

      end

      context "#{os} with invalid type" do
        let(:params) { {
            :type => 'foobar',
            :host => 'localhost',
            :port => 3306 } }

        it { is_expected.to raise_error(Puppet::Error, /expects a match for Enum\['db', 'ldap'\]/) }
      end
    end
  end
end
