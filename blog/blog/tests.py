from django.contrib.auth import get_user_model
from django.test import Client, TestCase
from django.urls import reverse

from .models import Category, Comment, Post

User = get_user_model()


class CategoryModelTests(TestCase):
    def test_str(self):
        cat = Category.objects.create(name="Tech", slug="tech")
        self.assertEqual(str(cat), "Tech")

    def test_slug_unique(self):
        Category.objects.create(name="Tech", slug="tech")
        with self.assertRaises(Exception):
            Category.objects.create(name="Tech2", slug="tech")


class PostModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="test", password="test")
        Category.objects.get_or_create(slug="uncategorized", defaults={"name": "Uncategorized"})

    def test_slug_auto_generated(self):
        post = Post.objects.create(
            author=self.user,
            title="My First Post",
            content="Content",
            status=Post.STATUS_PUBLISHED,
        )
        self.assertEqual(post.slug, "my-first-post")

    def test_slug_unique_append_suffix(self):
        Post.objects.create(
            author=self.user,
            title="Update",
            content="Content",
            status=Post.STATUS_PUBLISHED,
        )
        post2 = Post.objects.create(
            author=self.user,
            title="Update",
            content="Content 2",
            status=Post.STATUS_PUBLISHED,
        )
        self.assertEqual(post2.slug, "update-2")

    def test_get_absolute_url(self):
        post = Post.objects.create(
            author=self.user,
            title="Test",
            slug="test",
            content="Content",
            status=Post.STATUS_PUBLISHED,
        )
        url = post.get_absolute_url()
        self.assertIn("post/", url)
        self.assertIn("test", url)


class PostListViewTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="test", password="test")
        Category.objects.get_or_create(slug="uncategorized", defaults={"name": "Uncategorized"})
        self.client = Client()

    def test_empty_list(self):
        resp = self.client.get(reverse("blog:post_list"))
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "No posts yet")

    def test_published_only(self):
        Post.objects.create(
            author=self.user,
            title="Draft",
            slug="draft",
            content="Draft",
            status=Post.STATUS_DRAFT,
        )
        Post.objects.create(
            author=self.user,
            title="Published",
            slug="published",
            content="Published",
            status=Post.STATUS_PUBLISHED,
        )
        resp = self.client.get(reverse("blog:post_list"))
        self.assertContains(resp, "Published")
        self.assertNotContains(resp, "Draft")


class PostDetailViewTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="test", password="test")
        Category.objects.get_or_create(slug="uncategorized", defaults={"name": "Uncategorized"})
        self.post = Post.objects.create(
            author=self.user,
            title="Test Post",
            slug="test-post",
            content="Content here",
            status=Post.STATUS_PUBLISHED,
        )
        self.client = Client()

    def test_detail_by_slug(self):
        url = self.post.get_absolute_url()
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "Test Post")
        self.assertContains(resp, "Content here")

    def test_detail_wrong_date_still_works(self):
        # URL resolution uses slug only
        resp = self.client.get("/post/2000-01-01/test-post/")
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "Test Post")


class CommentFormTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="test", password="test")
        Category.objects.get_or_create(slug="uncategorized", defaults={"name": "Uncategorized"})
        self.post = Post.objects.create(
            author=self.user,
            title="Test",
            slug="test",
            content="Content",
            status=Post.STATUS_PUBLISHED,
        )
        self.client = Client()

    def test_comment_requires_login(self):
        url = self.post.get_absolute_url()
        resp = self.client.post(url, {"content": "My comment"})
        self.assertIn(resp.status_code, (302, 200))
        self.assertFalse(Comment.objects.filter(content="My comment").exists())

    def test_authenticated_comment(self):
        self.client.login(username="test", password="test")
        url = self.post.get_absolute_url()
        resp = self.client.post(url, {"content": "My comment"}, follow=True)
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(Comment.objects.filter(content="My comment").exists())


class AuthTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_register(self):
        resp = self.client.get(reverse("register"))
        self.assertEqual(resp.status_code, 200)
        resp = self.client.post(
            reverse("register"),
            {"username": "newuser", "password1": "testpass123!", "password2": "testpass123!"},
            follow=True,
        )
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(User.objects.filter(username="newuser").exists())

    def test_login_redirect_home(self):
        User.objects.create_user(username="u", password="p")
        resp = self.client.post(reverse("login"), {"username": "u", "password": "p"}, follow=True)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.wsgi_request.user.username, "u")

    def test_logout(self):
        User.objects.create_user(username="u", password="p")
        self.client.login(username="u", password="p")
        resp = self.client.post(reverse("logout"), follow=True)
        self.assertEqual(resp.status_code, 200)
        self.assertFalse(resp.wsgi_request.user.is_authenticated)


class FlatpageTests(TestCase):
    def setUp(self):
        from django.contrib.flatpages.models import FlatPage
        from django.contrib.sites.models import Site

        site = Site.objects.get(id=1)
        site.domain = "testserver"
        site.save()
        for url, title, content in [
            ("/about/", "About", "<h1>About</h1>"),
            ("/contact/", "Contact", "<h1>Contact</h1>"),
        ]:
            fp, _ = FlatPage.objects.get_or_create(url=url, defaults={"title": title, "content": content})
            fp.sites.add(site)
        self.client = Client()

    def test_about(self):
        resp = self.client.get("/about/")
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "About")

    def test_contact(self):
        resp = self.client.get("/contact/")
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "Contact")
