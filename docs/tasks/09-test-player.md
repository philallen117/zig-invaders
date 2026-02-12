So far, the project has no tests. I will start by adding some tests for src/shapes.zig and src/player.zig, focussing on logic rather than drawing. In generating code, follow zig best practice in folder structure and file naming.
First, generate tests for BoundingBox.intersects.

---

Just one more thing on shapes.zig: GameObjectShape is pretty declarative, but I would still like a simple test on GameObjectShape.getBox just to help avoid regressions.

---

Now for Player.move. Tests should focus on speed in both directions and bracketing at screen edges.

---

Similarly, add tests for PlayerBullet.move.
