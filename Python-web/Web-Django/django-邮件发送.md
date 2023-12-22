在settings.py文件中添加如下配置:
``` python
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.163.com'
EMAIL_POST = 25
EMAIL_HOST_USER = 'xusxlinux@163.com'
EMAIL_HOST_PASSWORD = 'KPVLNVZTDCTPWORF'
# 是否启动TLS链接, 默认关闭
# EMAIL_USE_TLS = False
# 设置收件人列表
EX_EMAIL = ['295782805@11.com']
```


程序报错追踪:
``` python
import traceback
print(traceback.format_exc())
```


注册middleware:
``` python
'middleware.mymiddleware.ExceptionMW',
```


邮件发送: (一般这样程序报错告警放在 middleware中)
``` python
class ExceptionMW(MiddlewareMixin):

    def process_exception(self, request, exception):

        from django.conf import settings
        from django.core import mail
        import traceback
        
        mail.send_mail(subject='test', message=traceback.format_exc()
                       , from_email='xusxlinux@163.com', recipient_list=settings.EX_EMAIL)

        return HttpResponse('---对不起 当前网页开小差---')
```
