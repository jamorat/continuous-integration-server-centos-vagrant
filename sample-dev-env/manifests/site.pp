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

package { "mysql-server":
  ensure => "installed",
  require => Package["httpd"],
}

package { "php-mysql":
  ensure => "installed",
  require => Package["mysql-server"],
}

package { "php-cli":
  ensure => "installed",
  require => Package["php-mysql"],
}


