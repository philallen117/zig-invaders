const std = @import("std");
const testing = std.testing;
const game_state = @import("game_state");
const constants = @import("constants");
const player_mod = @import("player");
const invader_mod = @import("invader");
const shield_mod = @import("shield");

const PlayerShape = player_mod.PlayerShape;
const PlayerBulletShape = player_mod.PlayerBulletShape;
const Invader = invader_mod.Invader;
const InvaderShape = invader_mod.InvaderShape;
const Shield = shield_mod.Shield;
const ShieldShape = shield_mod.ShieldShape;

test "init_game_state - invader horizontal spacing" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Check spacing between adjacent invaders in same row
    const first_row = state.invaders[0];
    const invader0_x = first_row[0].shape.left_x;
    const invader1_x = first_row[1].shape.left_x;

    try testing.expectEqual(constants.invaderSpacingX, invader1_x - invader0_x);
}

test "init_game_state - invader vertical spacing" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Check spacing between rows
    const row0_invader = state.invaders[0][0];
    const row1_invader = state.invaders[1][0];

    try testing.expectEqual(constants.invaderSpacingY, row1_invader.shape.top_y - row0_invader.shape.top_y);
}

test "init_game_state - invader first position" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const first_invader = state.invaders[0][0];

    try testing.expectEqual(constants.invaderStartX, first_invader.shape.left_x);
    try testing.expectEqual(constants.invaderStartY, first_invader.shape.top_y);
}

test "init_game_state - shield horizontal spacing" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Check spacing between first two shields
    const shield0_x = state.shields[0].shape.left_x;
    const shield1_x = state.shields[1].shape.left_x;

    try testing.expectEqual(constants.shieldSpacingX, shield1_x - shield0_x);
}

test "init_game_state - shield first position" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const first_shield = state.shields[0];

    try testing.expectEqual(constants.shieldStartX, first_shield.shape.left_x);
    try testing.expectEqual(constants.shieldStartY, first_shield.shape.top_y);
}

test "init_game_state - all shields at same y position" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const expected_y = constants.shieldStartY;
    for (state.shields) |shield| {
        try testing.expectEqual(expected_y, shield.shape.top_y);
    }
}

test "fire_player_bullet - fires when inactive bullet available" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Initially no bullets are active
    try testing.expect(!state.player_bullets[0].active);

    game_state.fire_player_bullet(&state);

    // First bullet should now be active
    try testing.expect(state.player_bullets[0].active);
}

test "fire_player_bullet - does nothing when all bullets active" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Mark all bullets as active
    for (&state.player_bullets) |*b| {
        b.active = true;
    }

    // This should not crash or cause error
    game_state.fire_player_bullet(&state);

    // All bullets should still be active
    for (state.player_bullets) |b| {
        try testing.expect(b.active);
    }
}

test "fire_player_bullet - fires first inactive bullet only" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Mark first bullet as active, leave rest inactive
    state.player_bullets[0].active = true;

    game_state.fire_player_bullet(&state);

    // First should still be active, second should now be active
    try testing.expect(state.player_bullets[0].active);
    try testing.expect(state.player_bullets[1].active);
    // Third should still be inactive
    try testing.expect(!state.player_bullets[2].active);
}

test "fire_player_bullet - positions bullet at player top middle" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const player_x = state.player.shape.left_x;
    const player_y = state.player.shape.top_y;

    game_state.fire_player_bullet(&state);

    const bullet = state.player_bullets[0];
    const expected_x = player_x + PlayerShape.widthBy2 - PlayerBulletShape.widthBy2;
    const expected_y = player_y;

    try testing.expectEqual(expected_x, bullet.shape.left_x);
    try testing.expectEqual(expected_y, bullet.shape.top_y);
}

test "fire_player_bullet - bullet x position centers on player" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Move player to specific position
    state.player.shape.left_x = 100;
    state.player.shape.top_y = 200;

    game_state.fire_player_bullet(&state);

    const bullet = state.player_bullets[0];
    // PlayerShape.width = 50, widthBy2 = 25
    // PlayerBulletShape.width = 4, widthBy2 = 2
    // So bullet should be at 100 + 25 - 2 = 123
    try testing.expectEqual(123, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
}

test "fire_player_bullet - multiple fires activate sequential bullets" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Fire three times
    game_state.fire_player_bullet(&state);
    game_state.fire_player_bullet(&state);
    game_state.fire_player_bullet(&state);

    // First three should be active
    try testing.expect(state.player_bullets[0].active);
    try testing.expect(state.player_bullets[1].active);
    try testing.expect(state.player_bullets[2].active);
    // Fourth should still be inactive
    try testing.expect(!state.player_bullets[3].active);
}

test "process_player_bullet_invader_collisions - invader dies on collision" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    try testing.expect(invader.alive);

    game_state.process_player_bullet_invader_collisions(&state);

    try testing.expect(!invader.alive);
}

test "process_player_bullet_invader_collisions - bullet becomes inactive" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    game_state.process_player_bullet_invader_collisions(&state);

    try testing.expect(!state.player_bullets[0].active);
}

test "process_player_bullet_invader_collisions - score increases by constant" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const initial_score = state.score;

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    game_state.process_player_bullet_invader_collisions(&state);

    try testing.expectEqual(initial_score + constants.invaderKillScore, state.score);
}

test "process_player_bullet_invader_collisions - dead invaders do not collide" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Kill first invader
    state.invaders[0][0].alive = false;

    // Position bullet where dead invader is
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = state.invaders[0][0].shape.left_x;
    state.player_bullets[0].shape.top_y = state.invaders[0][0].shape.top_y;

    const initial_score = state.score;

    game_state.process_player_bullet_invader_collisions(&state);

    // Bullet should still be active (no collision)
    try testing.expect(state.player_bullets[0].active);
    // Score should not increase
    try testing.expectEqual(initial_score, state.score);
}

test "process_player_bullet_invader_collisions - bullet kills at most one invader" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position two invaders at same location (contrived but tests the logic)
    state.invaders[0][0].shape.left_x = 100;
    state.invaders[0][0].shape.top_y = 100;
    state.invaders[0][1].shape.left_x = 100;
    state.invaders[0][1].shape.top_y = 100;

    // Position bullet to collide with both
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = 100;
    state.player_bullets[0].shape.top_y = 100;

    game_state.process_player_bullet_invader_collisions(&state);

    // Only one invader should be dead
    const dead_count = blk: {
        var count: u32 = 0;
        if (!state.invaders[0][0].alive) count += 1;
        if (!state.invaders[0][1].alive) count += 1;
        break :blk count;
    };
    try testing.expectEqual(@as(u32, 1), dead_count);
}

test "process_player_bullet_invader_collisions - inactive bullets do not collide" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position inactive bullet where invader is
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = false;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    game_state.process_player_bullet_invader_collisions(&state);

    // Invader should still be alive
    try testing.expect(invader.alive);
}

test "process_player_bullet_shield_collisions - bullet becomes inactive" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    game_state.process_player_bullet_shield_collisions(&state);

    try testing.expect(!state.player_bullets[0].active);
}

test "process_player_bullet_shield_collisions - shield health reduces by 1" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    const initial_health = shield.health;
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    game_state.process_player_bullet_shield_collisions(&state);

    try testing.expectEqual(initial_health - 1, shield.health);
}

test "process_player_bullet_shield_collisions - zero health shield does not collide" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Set shield health to 0
    state.shields[0].health = 0;

    // Position bullet where shield is
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = state.shields[0].shape.left_x;
    state.player_bullets[0].shape.top_y = state.shields[0].shape.top_y;

    game_state.process_player_bullet_shield_collisions(&state);

    // Bullet should still be active (no collision)
    try testing.expect(state.player_bullets[0].active);
    // Shield health should still be 0
    try testing.expectEqual(@as(i32, 0), state.shields[0].health);
}

test "process_player_bullet_shield_collisions - inactive bullets do not collide" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const shield = &state.shields[0];
    const initial_health = shield.health;

    // Position inactive bullet where shield is
    state.player_bullets[0].active = false;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    game_state.process_player_bullet_shield_collisions(&state);

    // Shield health should not change
    try testing.expectEqual(initial_health, shield.health);
}

test "process_player_bullet_shield_collisions - bullet hits at most one shield" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position two shields at same location (contrived but tests the logic)
    state.shields[0].shape.left_x = 200;
    state.shields[0].shape.top_y = 200;
    state.shields[1].shape.left_x = 200;
    state.shields[1].shape.top_y = 200;

    const initial_health_0 = state.shields[0].health;
    const initial_health_1 = state.shields[1].health;

    // Position bullet to collide with both
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = 200;
    state.player_bullets[0].shape.top_y = 200;

    game_state.process_player_bullet_shield_collisions(&state);

    // Only one shield should be damaged
    const damaged_count = blk: {
        var count: u32 = 0;
        if (state.shields[0].health < initial_health_0) count += 1;
        if (state.shields[1].health < initial_health_1) count += 1;
        break :blk count;
    };
    try testing.expectEqual(@as(u32, 1), damaged_count);
}

test "process_invader_movement - does not move until moveDelay frames" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const initial_x = state.invaders[0][0].shape.left_x;
    const initial_y = state.invaders[0][0].shape.top_y;

    // Call process_invader_movement for moveDelay - 1 frames
    var i: i32 = 0;
    while (i < Invader.moveDelay - 1) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Invaders should not have moved yet
    try testing.expectEqual(initial_x, state.invaders[0][0].shape.left_x);
    try testing.expectEqual(initial_y, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - moves after exactly moveDelay frames" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    const initial_x = state.invaders[0][0].shape.left_x;

    // Call process_invader_movement for exactly moveDelay frames
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Invaders should have moved right (direction = 1)
    try testing.expectEqual(initial_x + Invader.speed, state.invaders[0][0].shape.left_x);
}

test "process_invader_movement - timer increments each frame" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    try testing.expectEqual(@as(i32, 0), state.invader_move_timer);

    game_state.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 1), state.invader_move_timer);

    game_state.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 2), state.invader_move_timer);
}

test "process_invader_movement - timer resets after movement" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Move to just before moveDelay
    var i: i32 = 0;
    while (i < Invader.moveDelay - 1) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    try testing.expectEqual(Invader.moveDelay - 1, state.invader_move_timer);

    // One more call should trigger movement and reset timer
    game_state.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 0), state.invader_move_timer);
}

test "process_invader_movement - invaders move collectively preserving distances" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Record initial positions and distances
    const inv_0_0_x = state.invaders[0][0].shape.left_x;
    const inv_0_1_x = state.invaders[0][1].shape.left_x;
    const inv_1_0_y = state.invaders[1][0].shape.top_y;
    const inv_0_0_y = state.invaders[0][0].shape.top_y;

    const initial_horizontal_distance = inv_0_1_x - inv_0_0_x;
    const initial_vertical_distance = inv_1_0_y - inv_0_0_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Check distances are preserved
    const new_horizontal_distance = state.invaders[0][1].shape.left_x - state.invaders[0][0].shape.left_x;
    const new_vertical_distance = state.invaders[1][0].shape.top_y - state.invaders[0][0].shape.top_y;

    try testing.expectEqual(initial_horizontal_distance, new_horizontal_distance);
    try testing.expectEqual(initial_vertical_distance, new_vertical_distance);
}

test "process_invader_movement - initial direction is right" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    try testing.expectEqual(@as(i32, 1), state.invader_direction);

    const initial_x = state.invaders[0][0].shape.left_x;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Should move right (positive x)
    try testing.expect(state.invaders[0][0].shape.left_x > initial_x);
}

test "process_invader_movement - toggles direction at right edge" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position invader near right edge
    state.invaders[0][0].shape.left_x = constants.screenWidth - InvaderShape.width - 2;
    state.invader_direction = 1;

    const initial_y = state.invaders[0][0].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Direction should have toggled
    try testing.expectEqual(@as(i32, -1), state.invader_direction);
    // Should have dropped
    try testing.expectEqual(initial_y + Invader.dropDistance, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - toggles direction at left edge" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position invader near left edge, moving left
    state.invaders[0][0].shape.left_x = 2;
    state.invader_direction = -1;

    const initial_y = state.invaders[0][0].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Direction should have toggled back
    try testing.expectEqual(@as(i32, 1), state.invader_direction);
    // Should have dropped
    try testing.expectEqual(initial_y + Invader.dropDistance, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - all invaders drop when one hits edge" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Position only first invader near edge
    state.invaders[0][0].shape.left_x = constants.screenWidth - InvaderShape.width - 2;
    state.invader_direction = 1;

    const initial_y_00 = state.invaders[0][0].shape.top_y;
    const initial_y_11 = state.invaders[1][1].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // All invaders should have dropped
    try testing.expectEqual(initial_y_00 + Invader.dropDistance, state.invaders[0][0].shape.top_y);
    try testing.expectEqual(initial_y_11 + Invader.dropDistance, state.invaders[1][1].shape.top_y);
}

test "process_invader_movement - dead invaders do not affect edge detection" {
    var state: game_state.GameState = undefined;
    game_state.init_game_state(&state);

    // Kill all invaders except one in the middle
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            invader.alive = false;
        }
    }
    state.invaders[2][5].alive = true;

    // Position the alive invader far from edges
    state.invaders[2][5].shape.left_x = constants.screenWidth / 2;
    state.invader_direction = 1;

    const initial_y = state.invaders[2][5].shape.top_y;
    const initial_x = state.invaders[2][5].shape.left_x;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        game_state.process_invader_movement(&state);
    }

    // Should have moved right, not dropped
    try testing.expectEqual(initial_x + Invader.speed, state.invaders[2][5].shape.left_x);
    try testing.expectEqual(initial_y, state.invaders[2][5].shape.top_y);
    try testing.expectEqual(@as(i32, 1), state.invader_direction);
}
