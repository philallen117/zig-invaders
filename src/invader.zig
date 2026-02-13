const shapes = @import("shapes.zig");
const constants = @import("constants.zig");

const GameObjectShape = shapes.GameObjectShape;

pub const InvaderShape = GameObjectShape(40, 30);

pub const Invader = struct {
    shape: InvaderShape,
    alive: bool = false,

    pub const speed = 5;
    pub const moveDelay = 30; // frames
    pub const shootDelay = 60; // frames
    pub const shootChance = 5; // percent chance per delay interval per live invader
    pub const dropDistance = 20;

    pub fn init(left_x: i32, top_y: i32) @This() {
        return .{
            .shape = .{ .left_x = left_x, .top_y = top_y },
            .alive = true,
        };
    }

    pub fn move(self: *@This(), dx: i32, dy: i32) void {
        self.shape.left_x += dx;
        self.shape.top_y += dy;
    }
};

pub const InvaderBulletShape = GameObjectShape(4, 10);

pub const InvaderBullet = struct {
    shape: InvaderBulletShape,
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
            self.shape.top_y += speed;
            if (self.shape.top_y > constants.screenHeight) {
                self.active = false;
            }
        }
    }
};
