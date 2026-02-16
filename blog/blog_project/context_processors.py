"""Custom template context processors."""

from django.conf import settings


def blog_settings(request):
    """Add BLOG_TITLE to template context."""
    return {"BLOG_TITLE": getattr(settings, "BLOG_TITLE", "Blog")}
