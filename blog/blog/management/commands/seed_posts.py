"""Create 15 published test posts with Faker + cakeipsum-style prose."""

import random
from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.utils import timezone
from faker import Faker

from blog.models import Category, Post

User = get_user_model()

CAKE_WORDS = [
    "chocolate", "vanilla", "ganache", "cupcake", "frosting", "sprinkles",
    "buttercream", "layer", "confection", "pastry", "caramel", "marzipan",
    "bundt", "éclair", "macaron", "tiramisu", "mousse", "torte", "biscuit",
    "crème", "ganache", "whipped", "glaze", "fondant", "chiffon",
]


def cakeipsum_paragraph(fake: Faker, min_sentences=3, max_sentences=6) -> str:
    """Generate a paragraph with cake-themed words."""
    n = random.randint(min_sentences, max_sentences)
    sentences = []
    for _ in range(n):
        words = random.choices(CAKE_WORDS, k=random.randint(5, 12))
        sentences.append(" ".join(words).capitalize() + ".")
    return " ".join(sentences)


def cakeipsum_content(fake: Faker, min_paragraphs=2, max_paragraphs=5) -> str:
    """Generate HTML content with cake-themed paragraphs."""
    n = random.randint(min_paragraphs, max_paragraphs)
    paragraphs = [f"<p>{cakeipsum_paragraph(fake)}</p>" for _ in range(n)]
    return "\n".join(paragraphs)


class Command(BaseCommand):
    help = "Create 15 published test posts"

    def add_arguments(self, parser):
        parser.add_argument("--count", type=int, default=15, help="Number of posts to create")

    def handle(self, *args, **options):
        count = options["count"]
        fake = Faker()
        uncategorized = Category.objects.get(slug="uncategorized")
        user = User.objects.filter(is_superuser=True).first()
        if not user:
            user = User.objects.first()
        if not user:
            user = User.objects.create_user(
                username="admin",
                password="admin",
                is_superuser=True,
                is_staff=True,
            )
            self.stdout.write("Created admin user (username=admin, password=admin)")

        base_date = timezone.now()
        for i in range(count):
            title = fake.sentence(nb_words=4).rstrip(".")
            content = cakeipsum_content(fake)
            post = Post.objects.create(
                author=user,
                category=uncategorized,
                title=title,
                content=content,
                status=Post.STATUS_PUBLISHED,
                published_at=base_date - timedelta(days=i),
            )
            self.stdout.write(self.style.SUCCESS(f"Created: {post.title}"))

        self.stdout.write(self.style.SUCCESS(f"Created {count} posts"))
