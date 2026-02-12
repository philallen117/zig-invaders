const std = @import("std");
const testing = std.testing;
const invader_module = @import("invader");
const Invader = invader_module.Invader;
const InvaderShape = invader_module.InvaderShape;
const InvaderBullet = invader_module.InvaderBullet;
const InvaderBulletShape = invader_module.InvaderBulletShape;

// Invader.move tests

test "Invader.move - no movement with zero deltas" {
    var inv = Invader.init(100, 200);
    inv.move(0, 0);

    try testing.expectEqual(100, inv.shape.left_x);
    try testing.expectEqual(200, inv.shape.top_y);
}

test "Invader.move - move right" {
    var inv = Invader.init(100, 200);
    inv.move(5, 0);

    try testing.expectEqual(105, inv.shape.left_x);
    try testing.expectEqual(200, inv.shape.top_y);
}

test "Invader.move - move left" {
    var inv = Invader.init(100, 200);
    inv.move(-5, 0);

    try testing.expectEqual(95, inv.shape.left_x);
    try testing.expectEqual(200, inv.shape.top_y);
}

test "Invader.move - move down" {
    var inv = Invader.init(100, 200);
    inv.move(0, 20);

    try testing.expectEqual(100, inv.shape.left_x);
    try testing.expectEqual(220, inv.shape.top_y);
}

test "Invader.move - move up" {
    var inv = Invader.init(100, 200);
    inv.move(0, -10);

    try testing.expectEqual(100, inv.shape.left_x);
    try testing.expectEqual(190, inv.shape.top_y);
}

test "Invader.move - diagonal movement" {
    var inv = Invader.init(100, 200);
    inv.move(5, 20);

    try testing.expectEqual(105, inv.shape.left_x);
    try testing.expectEqual(220, inv.shape.top_y);
}

test "Invader.move - multiple moves accumulate" {
    var inv = Invader.init(100, 200);
    inv.move(5, 0);
    inv.move(5, 0);
    inv.move(0, 20);

    try testing.expectEqual(110, inv.shape.left_x);
    try testing.expectEqual(220, inv.shape.top_y);
}

test "Invader.move - large move values" {
    var inv = Invader.init(100, 200);
    inv.move(100, 50);

    try testing.expectEqual(200, inv.shape.left_x);
    try testing.expectEqual(250, inv.shape.top_y);
}

test "Invader.move - negative positions" {
    var inv = Invader.init(10, 10);
    inv.move(-20, -20);

    try testing.expectEqual(-10, inv.shape.left_x);
    try testing.expectEqual(-10, inv.shape.top_y);
}

test "Invader.init - starts alive" {
    const inv = Invader.init(100, 200);

    try testing.expect(inv.alive);
    try testing.expectEqual(100, inv.shape.left_x);
    try testing.expectEqual(200, inv.shape.top_y);
}

test "Invader.move - can be dead and still move" {
    var inv = Invader.init(100, 200);
    inv.alive = false;
    inv.move(10, 20);

    try testing.expectEqual(110, inv.shape.left_x);
    try testing.expectEqual(220, inv.shape.top_y);
    try testing.expect(!inv.alive);
}

test "Invader - verify constants" {
    try testing.expectEqual(5, Invader.speed);
    try testing.expectEqual(30, Invader.moveDelay);
    try testing.expectEqual(60, Invader.shootDelay);
    try testing.expectEqual(5, Invader.shootChance);
    try testing.expectEqual(20, Invader.dropDistance);
}

test "Invader - verify InvaderShape dimensions" {
    try testing.expectEqual(40, InvaderShape.width);
    try testing.expectEqual(30, InvaderShape.height);
}

// InvaderBullet.move tests

test "InvaderBullet.move - inactive bullet does not move" {
    var bullet = InvaderBullet.init(100, 200);
    bullet.active = false;
    bullet.move();

    try testing.expectEqual(100, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
    try testing.expect(!bullet.active);
}

test "InvaderBullet.move - active bullet moves downward by speed" {
    var bullet = InvaderBullet.init(100, 200);
    bullet.active = true;
    bullet.move();

    try testing.expectEqual(100, bullet.shape.left_x); // x should not change
    try testing.expectEqual(210, bullet.shape.top_y); // 200 + 10
    try testing.expect(bullet.active); // Should still be active
}

test "InvaderBullet.move - multiple moves accumulate" {
    var bullet = InvaderBullet.init(100, 200);
    bullet.active = true;
    bullet.move(); // 210
    bullet.move(); // 220
    bullet.move(); // 230

    try testing.expectEqual(230, bullet.shape.top_y);
    try testing.expect(bullet.active);
}

test "InvaderBullet.move - deactivates when past screen bottom" {
    var bullet = InvaderBullet.init(100, 595);
    bullet.active = true;
    bullet.move(); // Would move to 605, should deactivate (screenHeight = 600)

    try testing.expect(!bullet.active);
    try testing.expectEqual(605, bullet.shape.top_y);
}

test "InvaderBullet.move - stays active at screen height" {
    var bullet = InvaderBullet.init(100, 590);
    bullet.active = true;
    bullet.move(); // Moves to 600, should still be active (only deactivates when > 600)

    try testing.expect(bullet.active);
    try testing.expectEqual(600, bullet.shape.top_y);

    bullet.move(); // Now moves to 610, should deactivate
    try testing.expect(!bullet.active);
    try testing.expectEqual(610, bullet.shape.top_y);
}

test "InvaderBullet.move - stays inactive after deactivation" {
    var bullet = InvaderBullet.init(100, 595);
    bullet.active = true;
    bullet.move(); // Deactivates
    bullet.move(); // Should not move anymore
    bullet.move(); // Should not move anymore

    try testing.expect(!bullet.active);
    try testing.expectEqual(605, bullet.shape.top_y); // Position unchanged after deactivation
}

test "InvaderBullet.move - just below deactivation threshold" {
    var bullet = InvaderBullet.init(100, 589);
    bullet.active = true;
    bullet.move(); // Moves to 599, should still be active

    try testing.expect(bullet.active);
    try testing.expectEqual(599, bullet.shape.top_y);
}

test "InvaderBullet.move - init creates inactive bullet" {
    const bullet = InvaderBullet.init(100, 200);

    try testing.expect(!bullet.active);
    try testing.expectEqual(100, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
}

test "InvaderBullet.move - activation and movement" {
    var bullet = InvaderBullet.init(100, 100);
    try testing.expect(!bullet.active);

    bullet.active = true;
    bullet.move();

    try testing.expectEqual(110, bullet.shape.top_y);
    try testing.expect(bullet.active);
}

test "InvaderBullet - verify speed constant" {
    try testing.expectEqual(10, InvaderBullet.speed);
}

test "InvaderBullet - verify InvaderBulletShape dimensions" {
    try testing.expectEqual(4, InvaderBulletShape.width);
    try testing.expectEqual(10, InvaderBulletShape.height);
}
