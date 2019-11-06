node default {

##### NGINX
    ## installing nginx package
    package {'nginx':
        ensure => 'installed'}

    ## we will update index.html file with curernt node's hostname for easier spotting in loadbalancer for tests
    exec { 'run-html-update':
        command  => 'echo "<h1>$(hostname)</h1>" > /usr/share/nginx/html/index.html',
        provider => 'shell'}

    ## make sure nginx is installed and enable after restart
    service { 'nginx':
        ensure => 'running',
        enable =>  true }


# ##### NODE EXPORTER 
#     ## Create user for node_exporter
#      user { 'node_exporter':
#         ensure     => 'present',
#         comment    => 'node_exporter user',
#         shell      => '/bin/false'
#       }

#     ## Deploy node_exporter
#     file { '/usr/sbin/node_exporter':
#         ensure  => file,
#         source  => 'puppet:///modules/node_exporter/node_exporter'}

#     ## Deploy node_exporter service file
#     file { '/etc/systemd/system/node_exporter.service':
#         ensure  => file,
#         source  => 'puppet:///modules/node_exporter/node_exporter.service'}
 
#     ## Deploy node_exporter sysconfig file
#     file { '/etc/sysconfig/node_exporter':
#         ensure  => file,
#         source  => 'puppet:///modules/node_exporter/sysconfig.node_exporter'}

#     service { 'node_exporter':
#         ensure => 'running',
#         enable =>  true }
}
