from django.db.models import Count, Q
from django.shortcuts import get_object_or_404, redirect
from django.urls import reverse
from django.utils import timezone
from django.views.generic import DetailView, ListView
from django.views.generic.edit import FormMixin

from .forms import CommentForm
from .models import Category, Post


class PostListView(ListView):
    model = Post
    template_name = "blog/post_list.html"
    context_object_name = "posts"
    paginate_by = 10

    def get_queryset(self):
        return Post.objects.filter(status=Post.STATUS_PUBLISHED).select_related(
            "author", "category"
        )

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["categories"] = Category.objects.annotate(
            post_count=Count("posts", filter=Q(posts__status=Post.STATUS_PUBLISHED))
        )
        return context


class CategoryPostListView(PostListView):
    template_name = "blog/post_list.html"

    def get_queryset(self):
        qs = super().get_queryset()
        self.category = get_object_or_404(Category, slug=self.kwargs["slug"])
        return qs.filter(category=self.category)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["category"] = self.category
        return context


class PostDetailView(FormMixin, DetailView):
    model = Post
    template_name = "blog/post_detail.html"
    context_object_name = "post"
    form_class = CommentForm

    def get_queryset(self):
        return Post.objects.filter(status=Post.STATUS_PUBLISHED).select_related(
            "author", "category"
        ).prefetch_related("comments__author")

    def get_object(self, queryset=None):
        # Resolve by slug only (date in URL is for SEO)
        return get_object_or_404(Post, slug=self.kwargs["slug"])

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["form"] = self.get_form()
        return context

    def post(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            from django.contrib.auth.views import redirect_to_login
            return redirect_to_login(request.get_full_path())
        self.object = self.get_object()
        form = self.get_form()
        if form.is_valid():
            comment = form.save(commit=False)
            comment.post = self.object
            comment.author = request.user
            comment.save()
            return redirect(self.object.get_absolute_url())
        return self.form_invalid(form)
