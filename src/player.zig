const rl = @import("raylib");
const shapes = @import("shapes.zig");
const constants = @import("constants.zig");

const GameObjectShape = shapes.GameObjectShape;
const drawBox = shapes.drawBox;

pub const PlayerShape = GameObjectShape(50, 30);

pub const Player = struct {
    shape: PlayerShape,

    pub const speed = 5;

    pub fn init(left_x: i32, top_y: i32) @This() {
        return .{ .shape = .{ .left_x = left_x, .top_y = top_y } };
    }

    pub fn move(self: *@This(), go_left: bool, go_right: bool) void {
        if (go_right) {
            self.shape.left_x += speed;
        }
        if (go_left) {
            self.shape.left_x -= speed;
        }
        if (self.shape.left_x < 0) {
            self.shape.left_x = 0;
        }
        if (self.shape.left_x + PlayerShape.width > constants.screenWidth) {
            self.shape.left_x = constants.screenWidth - PlayerShape.width;
        }
    }
    pub fn draw(self: @This()) void {
        drawBox(PlayerShape, rl.Color.blue, self.shape, true);
    }
};

pub const PlayerBulletShape = GameObjectShape(4, 10);

pub const PlayerBullet = struct {
    shape: PlayerBulletShape,
    active: bool = false,

    pub const speed = 10;

    pub fn init(left_x: i32, top_y: i32) @This() {
        return .{
            .shape = .{ .left_x = left_x, .top_y = top_y },
            .active = false,
        };
    }

    pub fn move(self: *@This()) void {
        if (self.active) {
            self.shape.top_y -= speed;
            if (self.shape.top_y < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        drawBox(PlayerBulletShape, rl.Color.white, self.shape, self.active);
    }
};
