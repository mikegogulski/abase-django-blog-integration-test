from django.urls import path

from . import views

app_name = "blog"

urlpatterns = [
    path("", views.PostListView.as_view(), name="post_list"),
    path("category/<slug:slug>/", views.CategoryPostListView.as_view(), name="category_list"),
    path("post/<str:date>/<slug:slug>/", views.PostDetailView.as_view(), name="post_detail"),
]
