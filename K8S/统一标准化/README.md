```
hostnamectl set-hostname k8s-master-01
hostnamectl set-hostname k8s-node-01
hostnamectl set-hostname k8s-node-02
hostnamectl set-hostname k8s-node-03
```

```
yum groupinstall -y "base" "Development tools"
```

```
echo 'export HISTTIMEFORMAT="%y-%m-%d %H:%M:%S "' >> /etc/profile
sed -i "s#HISTSIZE=1000#HISTSIZE=5000#g" /etc/profile
source /etc/profile
```

```
echo "* soft noproc 65535" >> /etc/security/limits.conf
echo "* hard noproc 65535" >> /etc/security/limits.conf
```

```
sed -i "s#4096#65535#g" /etc/security/limits.d/20-nproc.conf
```

```
cp /etc/systemd/system.conf /etc/systemd/system.conf.bak
sed -i '/^#DefaultLimitNOFILE=/aDefaultLimitNOFILE=655350' /etc/systemd/system.conf
sed -i '/^#DefaultLimitNPROC=/aDefaultLimitNPROC=655350' /etc/systemd/system.conf
reboot
```
