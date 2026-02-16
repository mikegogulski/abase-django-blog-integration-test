from django.conf import settings
from django.contrib.syndication.views import Feed

from .models import Post


class PostFeed(Feed):
    title = getattr(settings, "BLOG_TITLE", "Blog Posts")
    link = "/"
    description = "Most recent blog posts"

    def items(self):
        return Post.objects.filter(status=Post.STATUS_PUBLISHED).order_by("-published_at")[:10]

    def item_title(self, item):
        return item.title

    def item_description(self, item):
        return item.content

    def item_link(self, item):
        return item.get_absolute_url()
