"""Generate a short random blog title with cakeipsum-style words."""

import random

CAKE_WORDS = [
    "Chocolate",
    "Vanilla",
    "Ganache",
    "Cupcake",
    "Frosting",
    "Sprinkles",
    "Buttercream",
    "Layer",
    "Confection",
    "Pastry",
    "Caramel",
    "Marzipan",
    "Bundt",
    "Éclair",
    "Macaron",
    "Tiramisu",
    "Mousse",
    "Torte",
    "Biscuit",
    "Crème",
]


def get_blog_title() -> str:
    """Return a short random blog title (2-3 cake-themed words)."""
    n = random.randint(2, 3)
    words = random.sample(CAKE_WORDS, n)
    return " ".join(words)
