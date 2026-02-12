const std = @import("std");
const testing = std.testing;
const shapes = @import("shapes");
const BoundingBox = shapes.BoundingBox;

test "BoundingBox.intersects - no intersection: boxes far apart horizontally" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 20,
        .right_x = 30,
        .top_y = 0,
        .bottom_y = 10,
    };
    try testing.expect(!box1.intersects(box2));
    try testing.expect(!box2.intersects(box1));
}

test "BoundingBox.intersects - no intersection: boxes far apart vertically" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 20,
        .bottom_y = 30,
    };
    try testing.expect(!box1.intersects(box2));
    try testing.expect(!box2.intersects(box1));
}

test "BoundingBox.intersects - no intersection: boxes diagonally separated" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 20,
        .right_x = 30,
        .top_y = 20,
        .bottom_y = 30,
    };
    try testing.expect(!box1.intersects(box2));
    try testing.expect(!box2.intersects(box1));
}

test "BoundingBox.intersects - complete overlap: identical boxes" {
    const box1 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 5,
        .bottom_y = 15,
    };
    const box2 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 5,
        .bottom_y = 15,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - complete overlap: box2 inside box1" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 20,
        .top_y = 0,
        .bottom_y = 20,
    };
    const box2 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 5,
        .bottom_y = 15,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - partial overlap: from right" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 0,
        .bottom_y = 10,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - partial overlap: from left" {
    const box1 = BoundingBox{
        .left_x = 10,
        .right_x = 20,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 0,
        .bottom_y = 10,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - partial overlap: from top" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 10,
        .bottom_y = 20,
    };
    const box2 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 5,
        .bottom_y = 15,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - partial overlap: from bottom" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 5,
        .bottom_y = 15,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - partial overlap: corner overlap top-left" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 5,
        .right_x = 15,
        .top_y = 5,
        .bottom_y = 15,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - edge touching: right edge to left edge" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 10,
        .right_x = 20,
        .top_y = 0,
        .bottom_y = 10,
    };
    // Touching edges should intersect (right_x == left_x means they share a line)
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - edge touching: bottom edge to top edge" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 10,
        .bottom_y = 20,
    };
    // Touching edges should intersect (bottom_y == top_y means they share a line)
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - single point touch: corner to corner" {
    const box1 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    const box2 = BoundingBox{
        .left_x = 10,
        .right_x = 20,
        .top_y = 10,
        .bottom_y = 20,
    };
    // Corner touching should intersect
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - negative coordinates" {
    const box1 = BoundingBox{
        .left_x = -10,
        .right_x = 0,
        .top_y = -10,
        .bottom_y = 0,
    };
    const box2 = BoundingBox{
        .left_x = -5,
        .right_x = 5,
        .top_y = -5,
        .bottom_y = 5,
    };
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - zero-sized box" {
    const box1 = BoundingBox{
        .left_x = 5,
        .right_x = 5,
        .top_y = 5,
        .bottom_y = 5,
    };
    const box2 = BoundingBox{
        .left_x = 0,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 10,
    };
    // A point at (5,5) should intersect with a box containing that point
    try testing.expect(box1.intersects(box2));
    try testing.expect(box2.intersects(box1));
}

test "BoundingBox.intersects - cross pattern: vertical box and horizontal box" {
    const vertical_box = BoundingBox{
        .left_x = 5,
        .right_x = 10,
        .top_y = 0,
        .bottom_y = 20,
    };
    const horizontal_box = BoundingBox{
        .left_x = 0,
        .right_x = 20,
        .top_y = 8,
        .bottom_y = 12,
    };
    try testing.expect(vertical_box.intersects(horizontal_box));
    try testing.expect(horizontal_box.intersects(vertical_box));
}

test "GameObjectShape.getBox - basic 10x20 shape at origin" {
    const Shape = shapes.GameObjectShape(10, 20);
    const obj = Shape{ .left_x = 0, .top_y = 0 };
    const box = obj.getBox();

    try testing.expectEqual(0, box.left_x);
    try testing.expectEqual(10, box.right_x);
    try testing.expectEqual(0, box.top_y);
    try testing.expectEqual(20, box.bottom_y);
}

test "GameObjectShape.getBox - shape at positive offset" {
    const Shape = shapes.GameObjectShape(15, 25);
    const obj = Shape{ .left_x = 100, .top_y = 200 };
    const box = obj.getBox();

    try testing.expectEqual(100, box.left_x);
    try testing.expectEqual(115, box.right_x);
    try testing.expectEqual(200, box.top_y);
    try testing.expectEqual(225, box.bottom_y);
}

test "GameObjectShape.getBox - verify width and height constants" {
    const Shape = shapes.GameObjectShape(16, 32);

    try testing.expectEqual(16, Shape.width);
    try testing.expectEqual(8, Shape.widthBy2);
    try testing.expectEqual(32, Shape.height);
}
