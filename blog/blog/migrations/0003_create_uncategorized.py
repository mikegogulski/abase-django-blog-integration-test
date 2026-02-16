from django.db import migrations


def create_uncategorized(apps, schema_editor):
    Category = apps.get_model("blog", "Category")
    Category.objects.get_or_create(
        slug="uncategorized",
        defaults={"name": "Uncategorized"},
    )


def noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    dependencies = [
        ("blog", "0002_category_post_comment"),
    ]

    operations = [
        migrations.RunPython(create_uncategorized, noop),
    ]
