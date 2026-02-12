const std = @import("std");
const testing = std.testing;
const shield_module = @import("shield");
const Shield = shield_module.Shield;
const ShieldShape = shield_module.ShieldShape;

// Shield.init tests

test "Shield.init - basic initialization" {
    const shield = Shield.init(100, 200);

    try testing.expectEqual(100, shield.shape.left_x);
    try testing.expectEqual(200, shield.shape.top_y);
    try testing.expectEqual(Shield.startHealth, shield.health);
}

test "Shield.init - at origin" {
    const shield = Shield.init(0, 0);

    try testing.expectEqual(0, shield.shape.left_x);
    try testing.expectEqual(0, shield.shape.top_y);
    try testing.expectEqual(Shield.startHealth, shield.health);
}

test "Shield.init - negative coordinates" {
    const shield = Shield.init(-50, -100);

    try testing.expectEqual(-50, shield.shape.left_x);
    try testing.expectEqual(-100, shield.shape.top_y);
    try testing.expectEqual(Shield.startHealth, shield.health);
}

test "Shield.init - large coordinates" {
    const shield = Shield.init(1000, 2000);

    try testing.expectEqual(1000, shield.shape.left_x);
    try testing.expectEqual(2000, shield.shape.top_y);
    try testing.expectEqual(Shield.startHealth, shield.health);
}

test "Shield.init - multiple shields have independent positions" {
    const shield1 = Shield.init(100, 200);
    const shield2 = Shield.init(300, 400);

    try testing.expectEqual(100, shield1.shape.left_x);
    try testing.expectEqual(200, shield1.shape.top_y);
    try testing.expectEqual(300, shield2.shape.left_x);
    try testing.expectEqual(400, shield2.shape.top_y);
}

test "Shield.init - startHealth constant is 10" {
    try testing.expectEqual(10, Shield.startHealth);
}

test "Shield.init - verify ShieldShape dimensions" {
    try testing.expectEqual(80, ShieldShape.width);
    try testing.expectEqual(60, ShieldShape.height);
}

test "Shield.init - health is always startHealth" {
    const shield1 = Shield.init(10, 20);
    const shield2 = Shield.init(500, 300);
    const shield3 = Shield.init(-10, -20);

    try testing.expectEqual(Shield.startHealth, shield1.health);
    try testing.expectEqual(Shield.startHealth, shield2.health);
    try testing.expectEqual(Shield.startHealth, shield3.health);
}
