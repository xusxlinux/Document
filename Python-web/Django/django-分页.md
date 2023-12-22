- [一、paginator对象的使用说明](#一)
- [二、Page对象对象的使用说明](#二)
- [三、分页代码示例 后端](#三)
- [四、分页代码示例 前端](#四)
  - [前端代码 - 上一页](#4.1)
  - [当前页显示页码](#4.2)
  - [前端代码 - 下一页](#4.3)

```
分页是指在web页面有大量数据需要显示, 为了阅读方便再每个页面中显示部分数据(方便阅读, 减少数据提取)
- Django 提供了 Paginator类 可以方便的实现分页功能
- Paginator类位于 "django.core.paginator" 模块中
```


<h3 id="一">一、paginator对象</h3>

```
负责分页数据整体管理:
	from django.core.paginator import Paginator
		
	对象的构造方法:
		paginator = Paginator(object_list, per_page)
			- 参数:
				- object_list 需要分页数据的对象列表(可以直接放QuerySet)
				- per_page 每页数据个数
				
			- 返回值:
				- Paginator的对象
			
	Paginator对象属性:
			- count: 需要分页数据的对象总数
			
			- num_pages: 分页后的页面总数
				page_number = request.GET.get('page', 1)
				
			- page_range: 从1开始的range对象, 用于记录当前页码数
				{% for p_number in paginator.page_range %}
				
			- per_page: 每页数据的个数
				paginator = Paginator(all_data, 10)
	
	Paginator对象方法:
		paginator.page(int(page_number))
			- 参数 number 为页码信息(从1开始)
				c_page = paginator.page(int(page_number))
				
			- 返回当前number页对应的页信息
			
			- 如果提供的页码不存在, 抛出InvalidPage异常
				InvalidPage: 总的异常基类, 包含以下两个异常子类:
					- PageNotAnInteger: 当向page()传入一个不是整数的值, 抛出异常
					- EmptyPage: 当向page提供一个有效值, 但是那个页面上没有任何对象时, 抛出异常
```


<h3 id="二">二、Page对象</h3>

```
负责具体某一页的数据管理

	创建对象:
		Paginator对象的page()方法返回Page对象
		page = paginator.page(页码)
		
	Page对象属性:
		- object_list: 当前页上所有数据对象的列表
		- number: 当前页的序号, 从1开始
		- paginator: 当前page对象相关的Paginator对象
		
	Page对象方法:
		has_next(): 如果有下一页返回True
		has_provious(): 如果有上一页返回True
		has_other_pages(): 如果有上一页或下一页返回True
		next_page_number(): 返回下一页码, 如果没有,抛出InvalidPage异常
		previous_page_number(): 返回上一页页码, 如果没有,抛出InvalidPage异常
```


<h3 id="三">三、后端代码示例</h3>

``` python
def list_note(request):
    # /list_note?page=1 使用查询字符串

    # 这个all_note 我可以使用ORM, 取数据库中的表数据
    from .models import Notes
    all_notes = Notes.objects.get_queryset().all()

    # 导入类库 paginator类
    from django.core.paginator import Paginator, Page, PageNotAnInteger, EmptyPage
    paginator = Paginator(all_notes, 3)

    # 初始化 具体页码的 page对象
    page_number = request.GET.get('page', 1)
    c_page = paginator.page(int(page_number))

    return render(request, 'notes/list_note.html', locals())
```

<h3 id="四">前端代码示例</h3>

``` html
{% for note in c_page %}
    <p>
        {{ note.title }}
        {{ note.content }}
        <a href="">查看</a>
        <a href="">删除</a>
    </p>
{% endfor %}
```

<h4 id="4.1">前端代码示例 - 上一页</h4>

``` html
{% if c_page.has_previous %}
    <a href="/notes/list_note?page={{ c_page.previous_page_number }}">上一页</a>
{% else %}
    上一页
{% endif %}
```

<h4 id="4.2">当前页显示页码</h4>

``` html
{% for p_number in paginator.page_range %}
    {% if p_number == c_page.number %}
        {{ p_number }}
    {% else %}
        <a href="/notes/list_note?page={{ p_number }}">{{ p_number }}</a>
    {% endif %}
{% endfor %}
```

<h4 id="4.3">前端代码示例 - 下一页</h4>

``` html
{% if c_page.has_next %}
    <a href="/notes/list_note?page={{ c_page.next_page_number }}">下一页</a>
{% else %}
    下一页
{% endif %}
```
