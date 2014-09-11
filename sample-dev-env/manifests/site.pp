package { 'httpd':
          name   => "httpd",
          ensure => present,
        }

service { "httpd":
  ensure  => "running",
  require => Package["httpd"],
}

exec{'clear_iptables':
  command => "/sbin/iptables -F",
}

exec{'download_latest_wordpress':
  command => "/usr/bin/wget -q http://wordpress.org/latest.tar.gz -O /var/www/html/latest.tar.gz",
  creates => "/var/www/html/latest.tar.gz",
  require => Package["httpd"],
  before => Exec["unpack_latest.tar.gz"],
}

exec {'unpack_latest.tar.gz':
  command => "tar xf /var/www/html/latest.tar.gz",
  cwd => "/var/www/html",
  path => "/bin",
}

package { "java-1.6.0-openjdk":
    ensure => "installed"
}

exec{'download_latest_jenkins_repo':
  command => "/usr/bin/wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
  creates => "/etc/yum.repos.d/jenkins.repo",
  require => Package["java-1.6.0-openjdk"],
  before => Exec["import_jenkins_key"],
}

exec {'import_jenkins_key':
  command => "/bin/rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key",
  cwd => "/home/vagrant",
  before => Package["jenkins"]
}

package { "jenkins":
    ensure => "installed"
}

service { "jenkins":
  ensure  => "running",
  require => Package["jenkins"],
}

exec{'download_PHP_unit':
  command => "/usr/bin/wget -O /usr/bin/phpunit.phar https://phar.phpunit.de/phpunit.phar",
  creates => "/usr/bin/phpunit.phar",
  before => Exec["run_phpunit_phar_commands"],
}

exec{'run_phpunit_phar_commands':
  command => "/bin/chmod +x /usr/bin/phpunit.phar && /bin/mv /usr/bin/phpunit.phar /usr/local/bin/phpunit",
  cwd => "/usr/bin",
}

package { "php-mysql":
  ensure => "installed",
  require => Exec["run_phpunit_phar_commands"],
}

package { "php":
  ensure => "installed",
  require => Exec["run_phpunit_phar_commands"],
}

package { "mysql-server":
  ensure => "installed",
  require => Package["httpd"],
}

service { "mysqld":
    enable => true,
    ensure => running,
    require => Package["mysql-server"],
    before => Exec["wait-for-mysqld"]
}

exec {"wait-for-mysqld":
  require => Service["mysqld"],
  command => "/usr/bin/mysql -u root --password= -e \"create database wp_test_database;grant all on wp_test_database.* to 'wptestuser'@'localhost' identified by 'vagrant';\"",
}

package { "php-cli":
  ensure => "installed",
  require => Package["php-mysql"],
}

package { "mod_dav_svn":
  ensure => "installed",
  require => Package["php-cli"]
}

file { "/home/vagrant/svn":
    ensure => "directory"
}

file { "/home/vagrant/svn/wordpress-dev":
    ensure => "directory"
}

exec {"checkout-svn-wordpress-test":
  command => "/usr/bin/svn co http://develop.svn.wordpress.org/trunk/",
  cwd => "/home/vagrant/svn/wordpress-dev/",
  before => Exec["copy-wp-tests-config-sample"]
}

exec {"copy-wp-tests-config-sample":
  command => "/bin/cp wp-tests-config-sample.php wp-tests-config.php",
  cwd => "/home/vagrant/svn/wordpress-dev/trunk",
  before => Exec["configure-wp-tests-config-sample"]
}

exec {"configure-wp-tests-config-sample":
  command => "/bin/sed -i 's%youremptytestdbnamehere%wp_test_database%g' wp-tests-config.php && sudo sed -i 's%yourusernamehere%wptestuser%g' wp-tests-config.php && sudo sed -i 's%yourpasswordhere%vagrant%g' wp-tests-config.php && svn up",
  cwd => "/home/vagrant/svn/wordpress-dev/trunk",
  before => Package["php-xml"]
}

package { "php-xml":
  ensure => "installed",
  require => Exec["configure-wp-tests-config-sample"]
}


