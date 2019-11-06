node default {
    ## installing haproxy package
    package {'haproxy':
        ensure => 'installed'}
    
    ## Deploy config file from template for haproxy
    file { '/etc/haproxy/haproxy.cfg':
        ensure  => file,
        source  => 'puppet:///modules/haproxy-config/haproxy.cfg'}

    ## make sure haproxy is running
    service { 'haproxy':
        ensure  => 'running',
        enable  =>  true }

}
