const std = @import("std");
const testing = std.testing;
const player_module = @import("player");
const Player = player_module.Player;
const PlayerShape = player_module.PlayerShape;
const PlayerBullet = player_module.PlayerBullet;
const PlayerBulletShape = player_module.PlayerBulletShape;

test "Player.move - no movement when no direction specified" {
    var p = Player.init(100, 200);
    p.move(false, false);

    try testing.expectEqual(100, p.shape.left_x);
    try testing.expectEqual(200, p.shape.top_y);
}

test "Player.move - move right increases position by speed" {
    var p = Player.init(100, 200);
    p.move(false, true);

    try testing.expectEqual(105, p.shape.left_x);
    try testing.expectEqual(200, p.shape.top_y); // y should not change
}

test "Player.move - move left decreases position by speed" {
    var p = Player.init(100, 200);
    p.move(true, false);

    try testing.expectEqual(95, p.shape.left_x);
    try testing.expectEqual(200, p.shape.top_y); // y should not change
}

test "Player.move - both directions cancel out" {
    var p = Player.init(100, 200);
    p.move(true, true);

    // Move right (+5) then left (-5) = net 0
    try testing.expectEqual(100, p.shape.left_x);
}

test "Player.move - multiple moves right accumulate" {
    var p = Player.init(100, 200);
    p.move(false, true);
    p.move(false, true);
    p.move(false, true);

    try testing.expectEqual(115, p.shape.left_x); // 100 + 3*5
}

test "Player.move - multiple moves left accumulate" {
    var p = Player.init(100, 200);
    p.move(true, false);
    p.move(true, false);
    p.move(true, false);

    try testing.expectEqual(85, p.shape.left_x); // 100 - 3*5
}

test "Player.move - left edge clamp at zero" {
    var p = Player.init(3, 200);
    p.move(true, false); // Would move to -2, but clamped to 0

    try testing.expectEqual(0, p.shape.left_x);
}

test "Player.move - left edge clamp stays at zero" {
    var p = Player.init(0, 200);
    p.move(true, false); // Already at 0, should stay at 0

    try testing.expectEqual(0, p.shape.left_x);
}

test "Player.move - multiple moves past left edge" {
    var p = Player.init(8, 200);
    p.move(true, false); // 8 - 5 = 3
    p.move(true, false); // 3 - 5 = -2, clamped to 0
    p.move(true, false); // Still at 0

    try testing.expectEqual(0, p.shape.left_x);
}

test "Player.move - right edge clamp at screen boundary" {
    // screenWidth = 800, PlayerShape.width = 50
    // Max allowed left_x = 750
    var p = Player.init(748, 200);
    p.move(false, true); // Would move to 753, but clamped to 750

    try testing.expectEqual(750, p.shape.left_x);
}

test "Player.move - right edge clamp stays at boundary" {
    var p = Player.init(750, 200);
    p.move(false, true); // Already at max, should stay at 750

    try testing.expectEqual(750, p.shape.left_x);
}

test "Player.move - multiple moves past right edge" {
    var p = Player.init(740, 200);
    p.move(false, true); // 740 + 5 = 745
    p.move(false, true); // 745 + 5 = 750
    p.move(false, true); // Would be 755, clamped to 750

    try testing.expectEqual(750, p.shape.left_x);
}

test "Player.move - move from left edge to interior" {
    var p = Player.init(0, 200);
    p.move(false, true);
    p.move(false, true);

    try testing.expectEqual(10, p.shape.left_x);
}

test "Player.move - move from right edge to interior" {
    var p = Player.init(750, 200);
    p.move(true, false);
    p.move(true, false);

    try testing.expectEqual(740, p.shape.left_x);
}

test "Player.move - alternating directions" {
    var p = Player.init(100, 200);
    p.move(false, true); // 105
    p.move(true, false); // 100
    p.move(false, true); // 105
    p.move(true, false); // 100

    try testing.expectEqual(100, p.shape.left_x);
}

test "Player.move - speed constant is 5" {
    try testing.expectEqual(5, Player.speed);
}

test "Player.move - verify PlayerShape dimensions" {
    try testing.expectEqual(50, PlayerShape.width);
    try testing.expectEqual(30, PlayerShape.height);
}

// PlayerBullet.move tests

test "PlayerBullet.move - inactive bullet does not move" {
    var bullet = PlayerBullet.init(100, 200);
    bullet.active = false;
    bullet.move();

    try testing.expectEqual(100, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
    try testing.expect(!bullet.active);
}

test "PlayerBullet.move - active bullet moves upward by speed" {
    var bullet = PlayerBullet.init(100, 200);
    bullet.active = true;
    bullet.move();

    try testing.expectEqual(100, bullet.shape.left_x); // x should not change
    try testing.expectEqual(190, bullet.shape.top_y); // 200 - 10
    try testing.expect(bullet.active); // Should still be active
}

test "PlayerBullet.move - multiple moves accumulate" {
    var bullet = PlayerBullet.init(100, 200);
    bullet.active = true;
    bullet.move(); // 190
    bullet.move(); // 180
    bullet.move(); // 170

    try testing.expectEqual(170, bullet.shape.top_y);
    try testing.expect(bullet.active);
}

test "PlayerBullet.move - deactivates when reaching top edge" {
    var bullet = PlayerBullet.init(100, 5);
    bullet.active = true;
    bullet.move(); // Would move to -5, should deactivate

    try testing.expect(!bullet.active);
    try testing.expectEqual(-5, bullet.shape.top_y);
}

test "PlayerBullet.move - deactivates exactly at zero" {
    var bullet = PlayerBullet.init(100, 10);
    bullet.active = true;
    bullet.move(); // Moves to 0, should NOT deactivate (only deactivates when < 0)

    try testing.expect(bullet.active); // Should still be active at 0
    try testing.expectEqual(0, bullet.shape.top_y);

    bullet.move(); // Now moves to -10, should deactivate
    try testing.expect(!bullet.active);
    try testing.expectEqual(-10, bullet.shape.top_y);
}

test "PlayerBullet.move - stays inactive after deactivation" {
    var bullet = PlayerBullet.init(100, 5);
    bullet.active = true;
    bullet.move(); // Deactivates
    bullet.move(); // Should not move anymore
    bullet.move(); // Should not move anymore

    try testing.expect(!bullet.active);
    try testing.expectEqual(-5, bullet.shape.top_y); // Position unchanged after deactivation
}

test "PlayerBullet.move - one pixel from top" {
    var bullet = PlayerBullet.init(100, 1);
    bullet.active = true;
    bullet.move(); // Moves to -9, should deactivate

    try testing.expect(!bullet.active);
    try testing.expectEqual(-9, bullet.shape.top_y);
}

test "PlayerBullet.move - just above deactivation threshold" {
    var bullet = PlayerBullet.init(100, 11);
    bullet.active = true;
    bullet.move(); // Moves to 1, should still be active

    try testing.expect(bullet.active);
    try testing.expectEqual(1, bullet.shape.top_y);
}

test "PlayerBullet.move - init creates inactive bullet" {
    const bullet = PlayerBullet.init(100, 200);

    try testing.expect(!bullet.active);
    try testing.expectEqual(100, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
}

test "PlayerBullet.move - activation and movement" {
    var bullet = PlayerBullet.init(100, 100);
    try testing.expect(!bullet.active);

    bullet.active = true;
    bullet.move();

    try testing.expectEqual(90, bullet.shape.top_y);
    try testing.expect(bullet.active);
}

test "PlayerBullet.move - verify PlayerBulletShape dimensions" {
    try testing.expectEqual(4, PlayerBulletShape.width);
    try testing.expectEqual(10, PlayerBulletShape.height);
}
