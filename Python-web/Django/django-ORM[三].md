#### 映射关系

`on_delete` - 级联删除  
  - models.CASCADF: 级联删除. Django模拟SQL约束 `ON DELETE CASCADE` 的行为, 并且删除包含`ForeignKey`的对象  
  - models.PROTECT: 抛出`ProtectedError` 以阻止被引用对象的删除; (等同于mysql默认的RESTRICT)  
  - SET_NULL: 设置`ForeignKey` null了需要指定null=True  
  - SET_DEFAULT: 将`ForeignKey`设置为其默认值; 必须设置 `ForeignKey` 的默认值  

- [一对一模型类创建](#一)
  - [代码演示](#1.1)
  - [外键](#1.2)
  - [查询方式](#1.3)
- [一对多模型类创建](#二)
  - [代码演示](#2.1)
  - [外键属性](#2.2)
  - [查询方式](#2.3)
- [多对多模型类创建](#三)
  - [代码演示](#3.1)
  - [MangToManyField](#3.2)
  - [查询方式](#3.3)


<h3 id="一">一对一模型类创建</h3>

<h4 id='1.1'>代码演示</h4>

``` python
class Author(models.Model):
    name = models.CharField('作者', max_length=11, null=False, default='')
    age = models.IntegerField('年龄', default='20')
    email = models.EmailField('邮箱', null=True, default='')
    
class Wife(models.Model):
    '''作家妻子模型'''
    name = models.CharField('妻子', max_length=50)
    # 增加一对一属性, on_delete是级联删除显性的规则, 要告诉django
    # 通常外键属性对应类名的小写
    # author_id 外键关联 author.id主键
    author = models.OneToOneField(Author, on_delete=models.CASCADE)
```
<h4 id='1.2'>外键</h4>

无外键的模型类[Author]:  
&ensp; &ensp; `author1 = Author.objects.create(name='王老师')`  
  
有外键的类型类[Wife]:  
&ensp; &ensp; 使用类属性名去创建数据做关联的时候, 必须给一个实例化对象 obj(author1)  
&ensp; &ensp; `wife1 = Wife.objects.create(name='王夫人', author=author1)`  
  
&ensp; &ensp; 外键字段名, 需要告诉它这个值是多少  
&ensp; &ensp; `author2 = Author.objects.create(name='王老师')`  
&ensp; &ensp; `wife2 = Wife.objects.create(name='王夫人', author_id=2)`  
&ensp; &ensp; `wife2 = Wife.objects.create(name='王夫人', author_id=author2.id)`   

<h4 id='1.3'>查询方式</h4>

查询方式:  
&ensp; &ensp; 正向查询: (`有外键属性`的查询是属于`正向查询`的)  
&ensp; &ensp; &ensp; &ensp; `wife1.author.name`  
&ensp; &ensp; 反向查询:  
&ensp; &ensp; &ensp; &ensp; `author1.wife.name`  

<h3 id="二">一对多模型类创建</h3>

<h4 id='2.1'>代码演示</h4>

``` python
class Publisher(models.Model):
    name = models.CharField(verbose_name='出版社名称', max_length=50)

class Book(models.Model):
    title = models.CharField(verbose_name='书名', max_length=50, unique=True, default='')
    '''publisher 一对多 一个出版社,出版多本书'''
    publisher = models.ForeignKey(Publisher, on_delete=models.CASCADE)
```

<h4 id='2.2'>外键属性</h4>


<h4 id='2.3'>查询方式</h4>


<h3 id="三">多对多模型类创建</h3>

<h4 id='3.1'>代码演示</h4>

``` python
class Author(models.Model):
    name = models.CharField('作者', max_length=11, null=False, default='')
    age = models.IntegerField('年龄', default='20')
    email = models.EmailField('邮箱', null=True, default='')

class Book(models.Model):
    title = models.CharField(verbose_name='书名', max_length=50, unique=True, default='')
    '''authors 多对多 多个作者可以写多本书 django帮助创建第三张表 关系表 "book_authors" '''
    authors = models.ManyToManyField(Author)
```

<h4 id='3.2'>外键属性</h4>


<h4 id='3.3'>查询方式如图所示</h4>

![Image text](https://raw.githubusercontent.com/xusxlinux/Document/master/Django/images/ORM%E6%93%8D%E4%BD%9C%20%E4%BA%8C.jpg)
