- [一、环境链接配置](#一)
- [二、什么是模型](#二)
- [三、创建模型](#三)
  - [模型类 - 字段类型](#3.1)
  - [模型类 - 字段选项](#3.2)
  - [模型类 - 修改表名](#3.3)
- [四、ORM操作图](#四)

<h3 id="一">一、django settings.py 链接配置</h3>

Linux环境:  
``` shell
workon python3
pip install pymysql

# 在init.py文件中导入pymysql包
vim /home/xusx/apps/apps/__init__.py
import pymysql
pymysql.install_as_MySQLdb()
```

Win环境:  
``` shell
pip install mysqlclient
```

数据库迁移如果有冲突:
``` shell
# 测试环境
删除migrations
  find . -path "*/migrations/*.py" -not -name "__init__.py" -delete
  find . -path "*/migrations/*.pyc" -delete
从数据库中删除所有非0001_initial的migration history
  DELETE FROM django_migrations WHERE app IN ('your','app','labels') AND name != '0001_initial'
  
  
# 生成环境
从git入手, 配置 .gitignore文件
0*.py
```

<h3 id="二">二、什么是模型</h3>

什么是模型:
  - 模型是一个Python类, 它是由django.db.models,Model派生出的子类  
  - 一个`模型类`代表数据库中的一张`数据表`  
  - 模型类中每一个`类属性`都代表数据库中的一个`字段`  
  - 模型是数据交互的接口, 是表示和操作数据库的方法和方式  

定义:  
  - ORM(Object Releation Mapping) 对象关系映射, 它是一种程序技术, 它允许你使类和对象,对数据库进行操作, 从而避免通过SQL语句操作数据库  

作用:  
  - 建立模型类和表之间的对应关系, 允许我们通过面向对象的方式来操作数据库  
  - 根据设计的模型类生产数据库中的表格.  
  - 通过简单的配置就可以进行数据库的切换  


<h3 id="三">三、创建模型</h3>

1丶python manage.py startapp bookstore(记得注册app)  
2丶models.py  
``` shell
    from django.db import models
    # 一个类对应一张表, 成为django的模型类,就需要继承models.Model
    class Book(models.Model): 
        # 一个属性对应一个字段
        title = models.CharField('书名', max_length=50, default='')
        price = models.DecimalField('定价', max_digits=7, decimal_places=2, default=0.0)
        info = models.CharField('描述', max_length=100, default='')
```  
3丶生成迁移文件  
  - 执行: python manage.py migrate  
  - 执行迁移程序实现迁移. 将每个应用下的migrations目录中的中间文件同步回数据库

<h4 id="3.1">模型类 - 字段类型</h4>

**BooleanField()**  
 - 数据库类型: tinyint(1)  
 - 编程语言中: 使用True或False来表示值  
 - 在数据库中: 使用1或0来表示具体的值  


**CharField()**  
 - 数据库类型: varchar  
 - 注意: 必须要指定max_length参数值  


**DateField()**  
  - 数据库类型: date  
  - 作用: 表示日期  
  - 参数: (只能多选一)  
    - auto_now: 每次保存对象时, 自动设置该字段为当前时间(取值: True/False)  
    - auto_now_add: 当对象第一次被创建时自动设置当前时间(取值: True/False)  
    - defalut: 设置当前时间(取值: 字符串格式时间: 2019-6-1)  

    	
**DateTimeField()**  
  - 数据库类型: datetime(6)  
  - 同DateField  


**FloatField()**  
  - 数据库类型: double  
  - 编程语言中和数据库中都使用小时表示值  


**DecimalField()** [与钱相关的存储记录]   
  - 数据库类型: decimal(x,y)  
  - 编程语言中: 使用小数表示该列的值  
  - 在数据库中: 使用小数  
  - 参数:  
    - max_digits: 位数总数, 包括小数点后的位数, 该值必须大于等于decimal_places  
    - decimal_places: 小数点后的数字量  


**EmainField()**  
  - 数据库类型: varchar  
  - 作用: 能使用正则, 识别邮箱格式  
  - 编程语言和数据库中使用字符串  


**IntegerField()**  
  - 数据库类型: int  
  - 编程语言和数据库中使用整型  


**ImageFiled()**  
  - 数据库类型: varchar(100)  
  - 作用: 在数据库中为了保存图片的路径  
  - 编程语言和数据库使用字符串  


**TextField()**  
  - 数据库类型: longtext  
  - 作用: 表示不定长的字符数据  
    
<h4 id="3.2">模型类 - 字段选项</h4>

字段选项, 指定创建的列的额外信息. 允许出行多个字段选项, 多个选项之间使用 ',' 隔开  

**primary_key**  
  - 如果设置为True, 表示该列为主键, 如果指定一个字段为主键, 则此数据库不会创建id字段  

**blank**  
  - 设置为True时, 字段可以为空, 设置为False时,字段是必须填写的  

**null**  
  - 如果设置为True, 表示该列值允许为空  
  - 默认为False, 如果此选项为False建议加入default选项来设置默认值  

**default**  
  - 设置所在列的默认值, 如果字段选项null=False建议添加此项  

**db_index**  
  - 如果设置为True, 表示该列增加索引  

**unique**  
  - 如果设置为True, 表示该字段在数据库中的值必须是唯一  

**db_column**  
  - 指定列的名称, 如果不指定的话, 则采用属性名作为列名  

**verbose_name**  
  - 设置此字段在admin页面显示名称  

<h4 id="3.3">模型类 - 修改表名</h4>

使用内部Meta类 来给模型赋予属性, Meta类下有很多内建的类属性, 可对模型类做一些控制  
``` shell
class Author(modules.Model):
  pass
  
  class Meta:
    db_table = 'auto'
```

