#### python3的卸载
``` shell
rpm -qa|grep python3|xargs rpm -ev --allmatches --nodeps
whereis python3 |xargs rm -rfv
whereis python
```
