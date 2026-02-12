const std = @import("std");
const rl = @import("raylib");
const shapes = @import("shapes.zig");

const GameObjectShape = shapes.GameObjectShape;

pub const ShieldShape = GameObjectShape(80, 60);

pub const Shield = struct {
    shape: ShieldShape,
    health: i32,

    pub const startHealth = 10;

    pub fn init(left_x: i32, top_y: i32) @This() {
        return .{
            .shape = .{ .left_x = left_x, .top_y = top_y },
            .health = startHealth,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha = @as(u8, @intCast(@min(255, self.health * 25)));
            rl.drawRectangle(
                self.shape.left_x,
                self.shape.top_y,
                ShieldShape.width,
                ShieldShape.height,
                rl.Color{ .r = 0, .g = 255, .b = 255, .a = alpha },
            );
        }
    }
};
