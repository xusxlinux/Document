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

```
yum groupinstall -y "base" "Development tools"
```
