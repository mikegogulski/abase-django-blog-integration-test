from django.contrib.auth.models import AbstractUser


class CustomUser(AbstractUser):
    """Custom user model for the blog. Extensible for future fields."""

    pass
