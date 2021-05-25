
``` shell
cat /etc/keepalived/keepalived.conf 

global_defs {
   router_id LVS_DEVEL
}
vrrp_instance VI_1 {
    state BACKUP
    nopreempt
    interface eth0
    virtual_router_id 80
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass just0kk
    }
    virtual_ipaddress {
        10.4.7.10
    }
}
virtual_server 10.4.7.10 6443 {
    delay_loop 6
    lb_algo loadbalance
    lb_kind DR
    net_mask 255.255.255.0
    persistence_timeout 0
    protocol TCP
    real_server 10.4.7.11 6443 {
        weight 1
        SSL_GET {
            url {
              path /healthz
              status_code 200
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 10.4.7.12 6443 {
        weight 1
        SSL_GET {
            url {
              path /healthz
              status_code 200
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
    real_server 10.4.7.21 6443 {
        weight 1
        SSL_GET {
            url {
              path /healthz
              status_code 200
            }
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
        }
    }
}
```
