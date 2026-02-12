const std = @import("std");
const testing = std.testing;
const game_state = @import("game_state");
const constants = @import("constants");

test "init_game_state - invader horizontal spacing" {
    game_state.init_game_state();

    // Check spacing between adjacent invaders in same row
    const first_row = game_state.invaders[0];
    const invader0_x = first_row[0].shape.left_x;
    const invader1_x = first_row[1].shape.left_x;

    try testing.expectEqual(constants.invaderSpacingX, invader1_x - invader0_x);
}

test "init_game_state - invader vertical spacing" {
    game_state.init_game_state();

    // Check spacing between rows
    const row0_invader = game_state.invaders[0][0];
    const row1_invader = game_state.invaders[1][0];

    try testing.expectEqual(constants.invaderSpacingY, row1_invader.shape.top_y - row0_invader.shape.top_y);
}

test "init_game_state - invader first position" {
    game_state.init_game_state();

    const first_invader = game_state.invaders[0][0];

    try testing.expectEqual(constants.invaderStartX, first_invader.shape.left_x);
    try testing.expectEqual(constants.invaderStartY, first_invader.shape.top_y);
}

test "init_game_state - shield horizontal spacing" {
    game_state.init_game_state();

    // Check spacing between first two shields
    const shield0_x = game_state.shields[0].shape.left_x;
    const shield1_x = game_state.shields[1].shape.left_x;

    try testing.expectEqual(constants.shieldSpacingX, shield1_x - shield0_x);
}

test "init_game_state - shield first position" {
    game_state.init_game_state();

    const first_shield = game_state.shields[0];

    try testing.expectEqual(constants.shieldStartX, first_shield.shape.left_x);
    try testing.expectEqual(constants.shieldStartY, first_shield.shape.top_y);
}

test "init_game_state - all shields at same y position" {
    game_state.init_game_state();

    const expected_y = constants.shieldStartY;
    for (game_state.shields) |shield| {
        try testing.expectEqual(expected_y, shield.shape.top_y);
    }
}
