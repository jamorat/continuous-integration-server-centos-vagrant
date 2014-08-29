package { 'httpd':
          name   => "httpd",
          ensure => present,
        }

service { "httpd":
  ensure  => "running",
  require => Package["httpd"],
}

exec{'retrieve_leiningen':
  command => "/usr/bin/wget -q http://wordpress.org/latest.tar.gz -O /var/www/html/latest.tar.gz",
  creates => "/var/www/html/latest.tar.gz",
}

exec {'unpack_latest.tar.gz':
  command => "tar xf /var/www/html/latest.tar.gz",
  cwd => "/var/www/html",
  path => '/bin',
}
