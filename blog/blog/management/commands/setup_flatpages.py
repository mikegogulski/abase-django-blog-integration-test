"""Create About and Contact flatpages. Run after migrate."""

from django.contrib.flatpages.models import FlatPage
from django.contrib.sites.models import Site
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Create About and Contact flatpages"

    def handle(self, *args, **options):
        site, _ = Site.objects.get_or_create(id=1, defaults={"domain": "example.com", "name": "Blog"})
        site.domain = "127.0.0.1:8765"
        site.name = "Blog"
        site.save()
        pages = [
            ("/about/", "About", "<h1>About</h1><p>This is the about page.</p>"),
            ("/contact/", "Contact", "<h1>Contact</h1><p>Get in touch.</p>"),
        ]
        for url, title, content in pages:
            fp, created = FlatPage.objects.get_or_create(
                url=url,
                defaults={"title": title, "content": content},
            )
            fp.sites.add(site)
            if not created:
                fp.title = title
                fp.content = content
                fp.save()
            self.stdout.write(self.style.SUCCESS(f"Created/updated {url}"))
