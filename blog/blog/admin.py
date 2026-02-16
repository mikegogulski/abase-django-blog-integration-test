from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import Category, Comment, CustomUser, Post


@admin.register(CustomUser)
class CustomUserAdmin(BaseUserAdmin):
    pass


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ["name", "slug"]
    prepopulated_fields = {"slug": ("name",)}
    search_fields = ["name"]


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ["title", "author", "category", "status", "published_at"]
    list_filter = ["status", "category"]
    search_fields = ["title", "content"]
    prepopulated_fields = {"slug": ("title",)}
    raw_id_fields = ["author"]
    date_hierarchy = "published_at"


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ["post", "author", "created_at"]
    list_filter = ["created_at"]
    search_fields = ["content"]
    raw_id_fields = ["post", "author"]
