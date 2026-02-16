from django.contrib.sitemaps import Sitemap
from django.urls import reverse

from .models import Post


class PostSitemap(Sitemap):
    changefreq = "weekly"
    priority = 0.8

    def items(self):
        return Post.objects.filter(status=Post.STATUS_PUBLISHED)

    def lastmod(self, obj):
        return obj.updated_at
