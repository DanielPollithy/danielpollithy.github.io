---
layout: post
published: true
categories:
  - personal
  - python
  - django
mathjax: false
featured: false
comments: false
title: 'Django migration: Add through="..." to a ManyToManyField'
tags: manytomany through migration runpython
---
## Django migration for through model to a ManyToMany

I recently had the problem that a m2n relation in a django application should be sortable.
So I wanted to add a through model to the relation but unfortunately as of now (django 2.0)
django won't solve this migration on its own.

These were the steps I have done to accomplish this:
1. Add a new m2n relation with the through model
2. Build a migration and extend it with orm code that copies the existing data
3. Delete the old relation
4. Rename the new relation

### Add the new relation

Create the through model:

```
class ThroughModel(models.Model):
    left = models.ForeignKey('Left')
    right = models.ForeignKey('Right')
    order = models.PositiveSmallIntegerField()

    class Meta:
        ordering = ['order', ]
```

Go to the place where you defined your old `ManyToManyField`. It might look something like this:

```
class Left(models.Model):
    ...

    the_old_relation = models.ManyToManyField(
        'Right',
        blank=True,
        related_name='lefts'
    )
```

And replace it with new one:

```
    the_new_relation = models.ManyToManyField(
        'Right',
        blank=True,
        through='ThroughModel',
        related_name='new_lefts'
    )
```

Keep an eye on the `related_name`. It should not be the same.

### Build a migration and extend it manually

Now run `python manage.py makemigrations` and open the newly generated migration.

It will contains something like this:

```
from django.db import migrations, models

# space for two methods

class Migration(migrations.Migration):

    dependencies = [
        ('test', '00...'),
    ]

    operations = [
        migrations.CreateModel(
            name='ThroughModel',
            ...
        ),
        migrations.AddField(
            model_name='left',
            name='the_new_relation',
            field=models.ManyToManyField(blank=True, related_name='new_lefts', to='test.Right', through='test.ThroughModel'),
        ),

        # ToDo: Add RunPython here

        # ToDo: Add RemoveField here

        # ToDo: Add RenameField here
    ]

```

So far so good. Let's tackle the ToDos that I added to the code.

**ToDo: Add RunPython**

The RunPython part will take care of the old relation. We cannot loose them. There would have been the option
to do this in SQL but django ORM will be alright for this small piece of migration.

We have to write two methods. One to apply the migrations (`forward_func`) and the other one to roll them back (`backward_func`).
The code is generic. If you have the same problem you can use it, replace `left` and `right` with your models and you should be good to go.

```
def forwards_func(apps, schema_editor):
    # We get the model from the versioned app registry;
    # if we directly import it, it'll be the wrong version
    Left = apps.get_model("test", "Left")
    ThroughModel = apps.get_model("test", "ThroughModel")
    db_alias = schema_editor.connection.alias

    for left in Left.objects.using(db_alias).iterator():
        for right in left.rights.all():
            ThroughModel.objects.create(left=left, right=right, order=0)


def reverse_func(apps, schema_editor):
    ThroughModel = apps.get_model("test", "ThroughModel")
    db_alias = schema_editor.connection.alias

    for througModel in ThroughModel.objects.using(db_alias).iterator():
        left = throughModel.left
        right = throughModel.right
        left.the_old_relation.add(right)
```

You can replace the comment `# space for two methods` with the methods.

And then we replace the `# ToDo: Add RunPython here` with `migrations.RunPython(forwards_func, reverse_func),` in order to add the execution of the code to the migration.

**# ToDo: Add RemoveField**
After copying over the data we can remove the old field by replacing the corresponding todo comment with the following snippet:

```
        migrations.RemoveField(
            model_name='Left',
            name='the_old_relation',
        ),
```

**# ToDo: Add RenameField**

Lastly I rename the new field to the old field's name in order to avoid changes in the code.

```
        migrations.RenameField(
            'left',              # model
            'the_old_relation',  # old field name
            'the_new_relation'   # new field name
        )
```
(Same procedure with the `# ToDo: Add RenameField here`)
