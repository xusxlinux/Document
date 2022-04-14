

上传规范 - 前端[HTML]  
  表单 `<form>` 文件上传时必须有带有 `enctype="multipart/form-data"` 时才会包含文件内容数据  

上传规范 - 后端[Django]  
  视图函数中, 用`request.FILES`取文件框的内容  
	  file = request.FILES['xxx']  

  说明:  
	  1. FILES的key对应 页面中 file框 的name值  
	  2. file 绑定文件流对象  
	  3. file.name 文件名  
	  4. file.file 文件的字节流数据  
    
配置 文件的 `访问路径` 和 `存储路径`  
  在settings.py中设置`MEDIA`相关配置; Django把用户上传的文件, 统称为media资源, Django把用户上传的文件, 统称为media资源  

这些资源能访问, 需要配置路由, 路由来了 去哪里找资源(什么样的请求来了, 需要加载用户上传的什么静态请求)  
	MEDIA_URL = '/media/'  

指定上传到哪个文件夹(以下是绝对路径)  
	MEDIA_ROOT = os.path.join(BASE_DIR, 'media')  

  
需要在主路由(urls.py)中进行配置, 上面的配置才会生效:  
	from django.conf import settings  
	from django.conf.urls.static import static  
	urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)  
  

文件写入: (借助ORM)  
	字段: FileField(upload='子目录名称') 实现用户头像功能  
  ``` python
  from django.db import models

  # Create your models here.

  class Content(models.Model):
      title = models.CharField(verbose_name='文章名', max_length=11)
      picture = models.FileField(upload_to='picture')
  ```
  
前端代码:
``` html
<form action="test_upload.html" method="post" enctype="multipart/form-data">
    {% csrf_token %}
    <p>
        <input type="text" name="title">
    </p>
    <p>
        <input type="file" name="myfile">
    </p>
    <p>
        <input type="submit" value="上传">
    </p>
</form>
```

后端代码:
``` python
# @csrf_exempt  使用csrf验证
def test_upload(request):

    if request.method == 'GET':
        return render(request, 'test_upload.html')
    elif request.method == 'POST':
        title = request.POST['title']
        myfile = request.FILES['myfile']

        Content.objects.create(title=title, picture=myfile)

        return HttpResponse('--- 文件 {} 上传成功 ---'.format(title))
```
