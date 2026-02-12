const rl = @import("raylib");

pub const BoundingBox = struct {
    left_x: i32,
    right_x: i32,
    top_y: i32,
    bottom_y: i32,

    pub fn intersects(self: @This(), other: @This()) bool {
        return !(self.left_x > other.right_x or
            self.right_x < other.left_x or
            self.top_y > other.bottom_y or
            self.bottom_y < other.top_y);
    }
};

pub fn GameObjectShape(w: i32, h: i32) type {
    return struct {
        left_x: i32,
        top_y: i32,
        pub const width = w;
        pub const widthBy2 = width / 2;
        pub const height = h;
        pub fn getBox(self: @This()) BoundingBox {
            return BoundingBox{
                .left_x = self.left_x,
                .right_x = self.left_x + width,
                .top_y = self.top_y,
                .bottom_y = self.top_y + height,
            };
        }
    };
}

pub fn drawBox(shapeType: type, comptime color: rl.Color, self: shapeType, active: bool) void {
    if (active) {
        rl.drawRectangle(
            self.left_x,
            self.top_y,
            shapeType.width,
            shapeType.height,
            color,
        );
    }
}
