在网站中, 实现CSV下载, 注意如下:  
  - 响应Content-Type类型需要修改为 text/csv 这告诉浏览器该文档是CSV文件, 而不是HTML文件  
  - 响应会获得一个额外的 Content-Disposition 标头, 其中包含CSV文件的名称. 浏览器开启 另存为 对话框  
  


python提供了内建库 - csv; 可以直接通过该库操作 CSV 文件  
  ``` python
	import csv
  
	with open('1.csv', 'w', newline'') as csvfile:
		writer = csv.writer(csvfile)
		writer.writerow(['a', 'b', 'c'])
  ```
  
  
使用django的方式下载 CSV 文件  
  ``` python
  def make_csv_view(request):
    from .models import Notes
    notes_info = Notes.objects.all().order_by('title')
    # all_notes = Notes.objects.get_queryset().all()

    # 导入类库 paginator类
    from django.core.paginator import Paginator, Page, PageNotAnInteger, EmptyPage
    paginator = Paginator(notes_info, 10)

    # 初始化 具体页码的 page对象
    page_number = request.GET.get('page', 1)
    c_page = paginator.page(int(page_number))

     
    response = HttpResponse(content_type='text/csv')
    # 在响应里, 给一个特殊的响应. (浏览器就知道需要触发下载)
    response['Content-Disposition'] = 'attachment;filename="mydata-%s.csv"'%(page_number)

    import csv
    writer = csv.writer(response)
    writer.writerow(['title', 'content'])

    for n in c_page:
        writer.writerow([n.title, n.content])
    return response
  ```
  
前端代码  
``` html
<a href="/notes/make_csv_view?page={{ c_page.number }}">导出CSV</a>
```
