- [一、中间件类需要继承](#一)
- [二、中间件类实现的五个方法](#二)
  - [代码实现](#2.1)
- [三、限制请求案例](#三)
- [四、跨站攻击 CSRF](#四)


<h2 id="一">一、中间件类需要继承</h2>

#### 中间件类需继承:
``` 
from django.utils.deprecation import MiddlewareMixin
```

<h2 id="二">二、中间件类实现的五个方法</h2>

#### 中间件类实现的五个方法:
```
执行路由之前被调用, 在每个请求上调用, 返回None或HttpResponse对象
process_request(self, request)

调用视图之前, 在每个请求上调用, 返回None或HttpResponse对象
process_view(self, request, callback, callback_args, callback_kwargs)

所有响应返回浏览器, 被调用, 在每个请求上调用, 返回HttpResponse对象
process_response(self, request, response)

当处理过程中抛出异常时调用, 返回一个HttpResponse
process_exception(self, request, exception)

在视图函数执行完成, 试图返回的对象包含render方法时被调用. 该方法需要返回实现render方法的响应对象
process_template_response(self, request, response)
```

<h3 id="2.1">代码实现</h3>

#### 代码实现:
``` py
# 初学者熟练掌握如下3种
class MyMW1(MiddlewareMixin):
    # 需要写多少方法, 看需求
    def process_request(self, request):
        print('MyMW1 process_request do ---')

    def process_view(self, request, callback, callback_args, callback_kwargs):
        print('MyMW1 process_view do ---')

    def process_response(self, request, response):
        print('MyMW1 process_response do ---')
        return response
        
# 测试执行顺序 - 按照注册顺序执行的
```

<h2 id="三">三、限制请求案例</h2>

#### 使用中间件实现强制某个IP地址只能向/test 开头的地址发生5次请求:
``` py
request.META['REMOTE_ADDR']可以得到远程客户端的IP地址
request.path_info 可以得到客户端访问的请求路由信息


class VisitLimit(MiddlewareMixin):
    visit_times = {}

    # 统计IP访问次数
    def process_request(self, request):
        ip_address = request.META['REMOTE_ADDR']
        path_url = request.path_info
        if not re.match(r'^/test', path_url):
            return
        count_times = self.visit_times.get(ip_address, 0)
        print('ip:', ip_address, '已访问', count_times, '次')
        self.visit_times[ip_address] = count_times + 1
        if count_times < 5:
            return
        return HttpResponse('兄弟您已经访问过' + str(count_times) + '次')
```

<h2 id="四">四、跨站伪造请求攻击 CSRF</h2>

#### CSRF - 跨站伪造请求攻击
```
settings.py中确认 MIDDLEWARE 中 
	django.middleware.csrf.CsrfViewMiddleware是否打开
	
模板中, form标签下 添加 django 的 认证 
	{% csrf_token %}

特殊说明:
	如果某个视图不需要django进行csrf保护, 可以用装饰器关闭对此视图的检查
	
	from django.views.decorators.csrf import csrf_exempt
	
	@csrf_exempt
	def my_view(request):
		return HttpResponse('hello world')
```
