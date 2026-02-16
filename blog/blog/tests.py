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

    def test_pagination(self):
        for i in range(12):
            Post.objects.create(
                author=self.user,
                title=f"Post {i}",
                slug=f"post-{i}",
                content="Content",
                status=Post.STATUS_PUBLISHED,
            )
        resp = self.client.get(reverse("blog:post_list"))
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.context["page_obj"]), 10)
        resp2 = self.client.get(reverse("blog:post_list") + "?page=2")
        self.assertEqual(resp2.status_code, 200)
        self.assertEqual(len(resp2.context["page_obj"]), 2)

    def test_category_filter(self):
        tech = Category.objects.create(name="Tech", slug="tech")
        Post.objects.create(
            author=self.user,
            title="Tech Post",
            slug="tech-post",
            content="Tech",
            category=tech,
            status=Post.STATUS_PUBLISHED,
        )
        Post.objects.create(
            author=self.user,
            title="Other Post",
            slug="other-post",
            content="Other",
            status=Post.STATUS_PUBLISHED,
        )
        resp = self.client.get(reverse("blog:category_list", kwargs={"slug": "tech"}))
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "Tech Post")
        self.assertNotContains(resp, "Other Post")
        self.assertEqual(resp.context["category"].slug, "tech")

    def test_category_404(self):
        resp = self.client.get(reverse("blog:category_list", kwargs={"slug": "nonexistent"}))
        self.assertEqual(resp.status_code, 404)


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

    def test_comment_linebreaks_to_paragraphs(self):
        self.client.login(username="test", password="test")
        url = self.post.get_absolute_url()
        self.client.post(url, {"content": "Line one\n\nLine two"}, follow=True)
        resp = self.client.get(url)
        self.assertContains(resp, "Line one")
        self.assertContains(resp, "Line two")
        self.assertIn("<p>", resp.content.decode())


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


class FeedSitemapRobotsTests(TestCase):
    def setUp(self):
        self.client = Client()

    def test_feed(self):
        resp = self.client.get("/feed/")
        self.assertEqual(resp.status_code, 200)
        self.assertIn(b"<?xml", resp.content)

    def test_sitemap(self):
        resp = self.client.get("/sitemap.xml")
        self.assertEqual(resp.status_code, 200)
        self.assertIn(b"<?xml", resp.content)

    def test_robots(self):
        resp = self.client.get("/robots.txt")
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, "Sitemap")


class ManagementCommandTests(TestCase):
    def test_setup_flatpages(self):
        from django.core.management import call_command
        from io import StringIO

        out = StringIO()
        call_command("setup_flatpages", stdout=out)
        out.seek(0)
        self.assertIn("about", out.read().lower())

        from django.contrib.flatpages.models import FlatPage
        self.assertTrue(FlatPage.objects.filter(url="/about/").exists())
        self.assertTrue(FlatPage.objects.filter(url="/contact/").exists())

    def test_seed_posts(self):
        from django.contrib.auth import get_user_model
        from django.core.management import call_command
        from io import StringIO

        User = get_user_model()
        User.objects.create_user(username="admin", password="admin", is_superuser=True, is_staff=True)
        out = StringIO()
        call_command("seed_posts", "--count=5", stdout=out)
        out.seek(0)
        self.assertIn("Created", out.read())

        self.assertEqual(Post.objects.filter(status=Post.STATUS_PUBLISHED).count(), 5)

    def test_seed_posts_custom_count(self):
        from django.contrib.auth import get_user_model
        from django.core.management import call_command
        from io import StringIO

        User = get_user_model()
        User.objects.create_user(username="admin", password="admin", is_superuser=True, is_staff=True)
        call_command("seed_posts", "--count=3", stdout=StringIO())
        self.assertEqual(Post.objects.filter(status=Post.STATUS_PUBLISHED).count(), 3)
