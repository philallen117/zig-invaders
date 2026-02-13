const std = @import("std");
const testing = std.testing;
const game_state_module = @import("game_state");
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

const MockRng = struct {
    pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
        _ = self;
        _ = min;
        _ = max;
        return 0; // Default: never shoots
    }
};

const GameState = game_state_module.GameStateModule(MockRng);

test "init_game_state - invader horizontal spacing" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Check spacing between adjacent invaders in same row
    const first_row = state.invaders[0];
    const invader0_x = first_row[0].shape.left_x;
    const invader1_x = first_row[1].shape.left_x;

    try testing.expectEqual(constants.invaderSpacingX, invader1_x - invader0_x);
}

test "init_game_state - invader vertical spacing" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Check spacing between rows
    const row0_invader = state.invaders[0][0];
    const row1_invader = state.invaders[1][0];

    try testing.expectEqual(constants.invaderSpacingY, row1_invader.shape.top_y - row0_invader.shape.top_y);
}

test "init_game_state - invader first position" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const first_invader = state.invaders[0][0];

    try testing.expectEqual(constants.invaderStartX, first_invader.shape.left_x);
    try testing.expectEqual(constants.invaderStartY, first_invader.shape.top_y);
}

test "init_game_state - shield horizontal spacing" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Check spacing between first two shields
    const shield0_x = state.shields[0].shape.left_x;
    const shield1_x = state.shields[1].shape.left_x;

    try testing.expectEqual(constants.shieldSpacingX, shield1_x - shield0_x);
}

test "init_game_state - shield first position" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const first_shield = state.shields[0];

    try testing.expectEqual(constants.shieldStartX, first_shield.shape.left_x);
    try testing.expectEqual(constants.shieldStartY, first_shield.shape.top_y);
}

test "init_game_state - all shields at same y position" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const expected_y = constants.shieldStartY;
    for (state.shields) |shield| {
        try testing.expectEqual(expected_y, shield.shape.top_y);
    }
}

test "fire_player_bullet - fires when inactive bullet available" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Initially no bullets are active
    try testing.expect(!state.player_bullets[0].active);

    GameState.fire_player_bullet(&state);

    // First bullet should now be active
    try testing.expect(state.player_bullets[0].active);
}

test "fire_player_bullet - does nothing when all bullets active" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Mark all bullets as active
    for (&state.player_bullets) |*b| {
        b.active = true;
    }

    // This should not crash or cause error
    GameState.fire_player_bullet(&state);

    // All bullets should still be active
    for (state.player_bullets) |b| {
        try testing.expect(b.active);
    }
}

test "fire_player_bullet - fires first inactive bullet only" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Mark first bullet as active, leave rest inactive
    state.player_bullets[0].active = true;

    GameState.fire_player_bullet(&state);

    // First should still be active, second should now be active
    try testing.expect(state.player_bullets[0].active);
    try testing.expect(state.player_bullets[1].active);
    // Third should still be inactive
    try testing.expect(!state.player_bullets[2].active);
}

test "fire_player_bullet - positions bullet at player top middle" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const player_x = state.player.shape.left_x;
    const player_y = state.player.shape.top_y;

    GameState.fire_player_bullet(&state);

    const bullet = state.player_bullets[0];
    const expected_x = player_x + PlayerShape.widthBy2 - PlayerBulletShape.widthBy2;
    const expected_y = player_y;

    try testing.expectEqual(expected_x, bullet.shape.left_x);
    try testing.expectEqual(expected_y, bullet.shape.top_y);
}

test "fire_player_bullet - bullet x position centers on player" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Move player to specific position
    state.player.shape.left_x = 100;
    state.player.shape.top_y = 200;

    GameState.fire_player_bullet(&state);

    const bullet = state.player_bullets[0];
    // PlayerShape.width = 50, widthBy2 = 25
    // PlayerBulletShape.width = 4, widthBy2 = 2
    // So bullet should be at 100 + 25 - 2 = 123
    try testing.expectEqual(123, bullet.shape.left_x);
    try testing.expectEqual(200, bullet.shape.top_y);
}

test "fire_player_bullet - multiple fires activate sequential bullets" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Fire three times
    GameState.fire_player_bullet(&state);
    GameState.fire_player_bullet(&state);
    GameState.fire_player_bullet(&state);

    // First three should be active
    try testing.expect(state.player_bullets[0].active);
    try testing.expect(state.player_bullets[1].active);
    try testing.expect(state.player_bullets[2].active);
    // Fourth should still be inactive
    try testing.expect(!state.player_bullets[3].active);
}

test "process_player_bullet_invader_collisions - invader dies on collision" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    try testing.expect(invader.alive);

    GameState.process_player_bullet_invader_collisions(&state);

    try testing.expect(!invader.alive);
}

test "process_player_bullet_invader_collisions - bullet becomes inactive" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    GameState.process_player_bullet_invader_collisions(&state);

    try testing.expect(!state.player_bullets[0].active);
}

test "process_player_bullet_invader_collisions - score increases by constant" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const initial_score = state.score;

    // Position bullet to collide with first invader
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    GameState.process_player_bullet_invader_collisions(&state);

    try testing.expectEqual(initial_score + constants.invaderKillScore, state.score);
}

test "process_player_bullet_invader_collisions - dead invaders do not collide" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Kill first invader
    state.invaders[0][0].alive = false;

    // Position bullet where dead invader is
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = state.invaders[0][0].shape.left_x;
    state.player_bullets[0].shape.top_y = state.invaders[0][0].shape.top_y;

    const initial_score = state.score;

    GameState.process_player_bullet_invader_collisions(&state);

    // Bullet should still be active (no collision)
    try testing.expect(state.player_bullets[0].active);
    // Score should not increase
    try testing.expectEqual(initial_score, state.score);
}

test "process_player_bullet_invader_collisions - bullet kills at most one invader" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position two invaders at same location (contrived but tests the logic)
    state.invaders[0][0].shape.left_x = 100;
    state.invaders[0][0].shape.top_y = 100;
    state.invaders[0][1].shape.left_x = 100;
    state.invaders[0][1].shape.top_y = 100;

    // Position bullet to collide with both
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = 100;
    state.player_bullets[0].shape.top_y = 100;

    GameState.process_player_bullet_invader_collisions(&state);

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
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position inactive bullet where invader is
    const invader = &state.invaders[0][0];
    state.player_bullets[0].active = false;
    state.player_bullets[0].shape.left_x = invader.shape.left_x;
    state.player_bullets[0].shape.top_y = invader.shape.top_y;

    GameState.process_player_bullet_invader_collisions(&state);

    // Invader should still be alive
    try testing.expect(invader.alive);
}

test "process_player_bullet_shield_collisions - bullet becomes inactive" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_player_bullet_shield_collisions(&state);

    try testing.expect(!state.player_bullets[0].active);
}

test "process_player_bullet_shield_collisions - shield health reduces by 1" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    const initial_health = shield.health;
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_player_bullet_shield_collisions(&state);

    try testing.expectEqual(initial_health - 1, shield.health);
}

test "process_player_bullet_shield_collisions - zero health shield does not collide" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Set shield health to 0
    state.shields[0].health = 0;

    // Position bullet where shield is
    state.player_bullets[0].active = true;
    state.player_bullets[0].shape.left_x = state.shields[0].shape.left_x;
    state.player_bullets[0].shape.top_y = state.shields[0].shape.top_y;

    GameState.process_player_bullet_shield_collisions(&state);

    // Bullet should still be active (no collision)
    try testing.expect(state.player_bullets[0].active);
    // Shield health should still be 0
    try testing.expectEqual(@as(i32, 0), state.shields[0].health);
}

test "process_player_bullet_shield_collisions - inactive bullets do not collide" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const shield = &state.shields[0];
    const initial_health = shield.health;

    // Position inactive bullet where shield is
    state.player_bullets[0].active = false;
    state.player_bullets[0].shape.left_x = shield.shape.left_x;
    state.player_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_player_bullet_shield_collisions(&state);

    // Shield health should not change
    try testing.expectEqual(initial_health, shield.health);
}

test "process_player_bullet_shield_collisions - bullet hits at most one shield" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

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

    GameState.process_player_bullet_shield_collisions(&state);

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
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const initial_x = state.invaders[0][0].shape.left_x;
    const initial_y = state.invaders[0][0].shape.top_y;

    // Call process_invader_movement for moveDelay - 1 frames
    var i: i32 = 0;
    while (i < Invader.moveDelay - 1) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // Invaders should not have moved yet
    try testing.expectEqual(initial_x, state.invaders[0][0].shape.left_x);
    try testing.expectEqual(initial_y, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - moves after exactly moveDelay frames" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const initial_x = state.invaders[0][0].shape.left_x;

    // Call process_invader_movement for exactly moveDelay frames
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // Invaders should have moved right (direction = 1)
    try testing.expectEqual(initial_x + Invader.speed, state.invaders[0][0].shape.left_x);
}

test "process_invader_movement - timer increments each frame" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    try testing.expectEqual(@as(i32, 0), state.invader_move_timer);

    GameState.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 1), state.invader_move_timer);

    GameState.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 2), state.invader_move_timer);
}

test "process_invader_movement - timer resets after movement" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Move to just before moveDelay
    var i: i32 = 0;
    while (i < Invader.moveDelay - 1) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    try testing.expectEqual(Invader.moveDelay - 1, state.invader_move_timer);

    // One more call should trigger movement and reset timer
    GameState.process_invader_movement(&state);
    try testing.expectEqual(@as(i32, 0), state.invader_move_timer);
}

test "process_invader_movement - invaders move collectively preserving distances" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

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
        GameState.process_invader_movement(&state);
    }

    // Check distances are preserved
    const new_horizontal_distance = state.invaders[0][1].shape.left_x - state.invaders[0][0].shape.left_x;
    const new_vertical_distance = state.invaders[1][0].shape.top_y - state.invaders[0][0].shape.top_y;

    try testing.expectEqual(initial_horizontal_distance, new_horizontal_distance);
    try testing.expectEqual(initial_vertical_distance, new_vertical_distance);
}

test "process_invader_movement - initial direction is right" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    try testing.expectEqual(@as(i32, 1), state.invader_direction);

    const initial_x = state.invaders[0][0].shape.left_x;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // Should move right (positive x)
    try testing.expect(state.invaders[0][0].shape.left_x > initial_x);
}

test "process_invader_movement - toggles direction at right edge" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position invader near right edge
    state.invaders[0][0].shape.left_x = constants.screenWidth - InvaderShape.width - 2;
    state.invader_direction = 1;

    const initial_y = state.invaders[0][0].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // Direction should have toggled
    try testing.expectEqual(@as(i32, -1), state.invader_direction);
    // Should have dropped
    try testing.expectEqual(initial_y + Invader.dropDistance, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - toggles direction at left edge" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position invader near left edge, moving left
    state.invaders[0][0].shape.left_x = 2;
    state.invader_direction = -1;

    const initial_y = state.invaders[0][0].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // Direction should have toggled back
    try testing.expectEqual(@as(i32, 1), state.invader_direction);
    // Should have dropped
    try testing.expectEqual(initial_y + Invader.dropDistance, state.invaders[0][0].shape.top_y);
}

test "process_invader_movement - all invaders drop when one hits edge" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position only first invader near edge
    state.invaders[0][0].shape.left_x = constants.screenWidth - InvaderShape.width - 2;
    state.invader_direction = 1;

    const initial_y_00 = state.invaders[0][0].shape.top_y;
    const initial_y_11 = state.invaders[1][1].shape.top_y;

    // Trigger movement
    var i: i32 = 0;
    while (i < Invader.moveDelay) : (i += 1) {
        GameState.process_invader_movement(&state);
    }

    // All invaders should have dropped
    try testing.expectEqual(initial_y_00 + Invader.dropDistance, state.invaders[0][0].shape.top_y);
    try testing.expectEqual(initial_y_11 + Invader.dropDistance, state.invaders[1][1].shape.top_y);
}

test "process_invader_movement - dead invaders do not affect edge detection" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

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
        GameState.process_invader_movement(&state);
    }

    // Should have moved right, not dropped
    try testing.expectEqual(initial_x + Invader.speed, state.invaders[2][5].shape.left_x);
    try testing.expectEqual(initial_y, state.invaders[2][5].shape.top_y);
    try testing.expectEqual(@as(i32, 1), state.invader_direction);
}

test "process_invader_shooting - does not shoot until shootDelay frames" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    var rng = MockRng{};

    // Call for shootDelay - 1 frames
    var i: i32 = 0;
    while (i < Invader.shootDelay - 1) : (i += 1) {
        GameState.process_invader_shooting(&state, &rng);
    }

    // No bullets should be active
    for (state.invader_bullets) |b| {
        try testing.expect(!b.active);
    }
}

test "process_invader_shooting - timer increments each frame" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    var rng = MockRng{};

    try testing.expectEqual(@as(i32, 0), state.invader_shoot_timer);

    GameState.process_invader_shooting(&state, &rng);
    try testing.expectEqual(@as(i32, 1), state.invader_shoot_timer);

    GameState.process_invader_shooting(&state, &rng);
    try testing.expectEqual(@as(i32, 2), state.invader_shoot_timer);
}

test "process_invader_shooting - timer resets after shootDelay" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    var rng = MockRng{};

    // Move to just before shootDelay
    var i: i32 = 0;
    while (i < Invader.shootDelay - 1) : (i += 1) {
        GameState.process_invader_shooting(&state, &rng);
    }

    try testing.expectEqual(Invader.shootDelay - 1, state.invader_shoot_timer);

    // One more call should trigger shooting opportunity and reset timer
    GameState.process_invader_shooting(&state, &rng);
    try testing.expectEqual(@as(i32, 0), state.invader_shoot_timer);
}

test "process_invader_shooting - invader shoots when random value is low enough" {
    const ShootingRng = struct {
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = self;
            _ = min;
            _ = max;
            return 5; // Exactly at shootChance threshold
        }
    };
    const ShootingGameState = game_state_module.GameStateModule(ShootingRng);

    var state: ShootingGameState.GameState = undefined;
    ShootingGameState.init_game_state(&state);
    var rng = ShootingRng{};

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        ShootingGameState.process_invader_shooting(&state, &rng);
    }

    // At least one bullet should be active (first alive invader should have shot)
    var bullet_found = false;
    for (state.invader_bullets) |b| {
        if (b.active) {
            bullet_found = true;
            break;
        }
    }
    try testing.expect(bullet_found);
}

test "process_invader_shooting - invader does not shoot when random value too high" {
    const NonShootingRng = struct {
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = self;
            _ = min;
            _ = max;
            return 100; // Above shootChance
        }
    };
    const NonShootingGameState = game_state_module.GameStateModule(NonShootingRng);

    var state: NonShootingGameState.GameState = undefined;
    NonShootingGameState.init_game_state(&state);
    var rng = NonShootingRng{};

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        NonShootingGameState.process_invader_shooting(&state, &rng);
    }

    // No bullets should be active
    for (state.invader_bullets) |b| {
        try testing.expect(!b.active);
    }
}

test "process_invader_shooting - multiple invaders can shoot in same frame" {
    const AllShootRng = struct {
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = self;
            _ = min;
            _ = max;
            return 1; // Well below shootChance
        }
    };
    const AllShootGameState = game_state_module.GameStateModule(AllShootRng);

    var state: AllShootGameState.GameState = undefined;
    AllShootGameState.init_game_state(&state);
    var rng = AllShootRng{};

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        AllShootGameState.process_invader_shooting(&state, &rng);
    }

    // Multiple bullets should be active
    var active_count: u32 = 0;
    for (state.invader_bullets) |b| {
        if (b.active) {
            active_count += 1;
        }
    }
    try testing.expect(active_count > 1);
}

test "process_invader_shooting - no error when all bullets active" {
    const AllShootRng = struct {
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = self;
            _ = min;
            _ = max;
            return 1;
        }
    };
    const AllShootGameState = game_state_module.GameStateModule(AllShootRng);

    var state: AllShootGameState.GameState = undefined;
    AllShootGameState.init_game_state(&state);
    var rng = AllShootRng{};

    // Activate all bullets
    for (&state.invader_bullets) |*b| {
        b.active = true;
    }

    // This should not crash
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        AllShootGameState.process_invader_shooting(&state, &rng);
    }

    // All bullets should still be active
    for (state.invader_bullets) |b| {
        try testing.expect(b.active);
    }
}

test "process_invader_shooting - bullet positioned at bottom middle of invader" {
    const OneShootRng = struct {
        call_count: u32 = 0,
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = min;
            _ = max;
            self.call_count += 1;
            // Only first invader shoots
            return if (self.call_count == 1) 1 else 100;
        }
    };
    const OneShootGameState = game_state_module.GameStateModule(OneShootRng);

    var state: OneShootGameState.GameState = undefined;
    OneShootGameState.init_game_state(&state);
    var rng = OneShootRng{};

    const invader = state.invaders[0][0];
    const expected_x = invader.shape.left_x + InvaderShape.widthBy2 - invader_mod.InvaderBulletShape.widthBy2;
    const expected_y = invader.shape.top_y + InvaderShape.height;

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        OneShootGameState.process_invader_shooting(&state, &rng);
    }

    // First bullet should be at invader's bottom middle
    try testing.expect(state.invader_bullets[0].active);
    try testing.expectEqual(expected_x, state.invader_bullets[0].shape.left_x);
    try testing.expectEqual(expected_y, state.invader_bullets[0].shape.top_y);
}

test "process_invader_shooting - dead invaders do not shoot" {
    const AllShootRng = struct {
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = self;
            _ = min;
            _ = max;
            return 1;
        }
    };
    const AllShootGameState = game_state_module.GameStateModule(AllShootRng);

    var state: AllShootGameState.GameState = undefined;
    AllShootGameState.init_game_state(&state);
    var rng = AllShootRng{};

    // Kill all invaders
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            invader.alive = false;
        }
    }

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        AllShootGameState.process_invader_shooting(&state, &rng);
    }

    // No bullets should be active
    for (state.invader_bullets) |b| {
        try testing.expect(!b.active);
    }
}

test "process_invader_shooting - finds first available bullet" {
    const OneShootRng = struct {
        call_count: u32 = 0,
        pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
            _ = min;
            _ = max;
            self.call_count += 1;
            return if (self.call_count == 1) 1 else 100;
        }
    };
    const OneShootGameState = game_state_module.GameStateModule(OneShootRng);

    var state: OneShootGameState.GameState = undefined;
    OneShootGameState.init_game_state(&state);
    var rng = OneShootRng{};

    // Activate first two bullets
    state.invader_bullets[0].active = true;
    state.invader_bullets[1].active = true;

    // Trigger shooting
    var i: i32 = 0;
    while (i < Invader.shootDelay) : (i += 1) {
        OneShootGameState.process_invader_shooting(&state, &rng);
    }

    // Third bullet should be the one activated
    try testing.expect(state.invader_bullets[0].active);
    try testing.expect(state.invader_bullets[1].active);
    try testing.expect(state.invader_bullets[2].active);
    try testing.expect(!state.invader_bullets[3].active);
}

test "process_invader_bullet_shield_collisions - bullet becomes inactive" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = shield.shape.left_x;
    state.invader_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_invader_bullet_shield_collisions(&state);

    try testing.expect(!state.invader_bullets[0].active);
}

test "process_invader_bullet_shield_collisions - shield health reduces by 1" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with first shield
    const shield = &state.shields[0];
    const initial_health = shield.health;
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = shield.shape.left_x;
    state.invader_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_invader_bullet_shield_collisions(&state);

    try testing.expectEqual(initial_health - 1, shield.health);
}

test "process_invader_bullet_shield_collisions - zero health shield does not collide" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Set shield health to 0
    state.shields[0].health = 0;

    // Position bullet where shield is
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = state.shields[0].shape.left_x;
    state.invader_bullets[0].shape.top_y = state.shields[0].shape.top_y;

    GameState.process_invader_bullet_shield_collisions(&state);

    // Bullet should still be active (no collision)
    try testing.expect(state.invader_bullets[0].active);
    // Shield health should still be 0
    try testing.expectEqual(@as(i32, 0), state.shields[0].health);
}

test "process_invader_bullet_shield_collisions - inactive bullets do not collide" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const shield = &state.shields[0];
    const initial_health = shield.health;

    // Position inactive bullet where shield is
    state.invader_bullets[0].active = false;
    state.invader_bullets[0].shape.left_x = shield.shape.left_x;
    state.invader_bullets[0].shape.top_y = shield.shape.top_y;

    GameState.process_invader_bullet_shield_collisions(&state);

    // Shield health should not change
    try testing.expectEqual(initial_health, shield.health);
}

test "process_invader_bullet_shield_collisions - bullet hits at most one shield" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position two shields at same location (contrived but tests the logic)
    state.shields[0].shape.left_x = 200;
    state.shields[0].shape.top_y = 200;
    state.shields[1].shape.left_x = 200;
    state.shields[1].shape.top_y = 200;

    const initial_health_0 = state.shields[0].health;
    const initial_health_1 = state.shields[1].health;

    // Position bullet to collide with both
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = 200;
    state.invader_bullets[0].shape.top_y = 200;

    GameState.process_invader_bullet_shield_collisions(&state);

    // Only one shield should be damaged
    const damaged_count = blk: {
        var count: u32 = 0;
        if (state.shields[0].health < initial_health_0) count += 1;
        if (state.shields[1].health < initial_health_1) count += 1;
        break :blk count;
    };
    try testing.expectEqual(@as(u32, 1), damaged_count);
}

test "process_invader_bullet_player_collisions - player loses when hit" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet to collide with player
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = state.player.shape.left_x;
    state.invader_bullets[0].shape.top_y = state.player.shape.top_y;

    try testing.expect(!state.game_over);

    GameState.process_invader_bullet_player_collisions(&state);

    try testing.expect(state.game_over);
}

test "process_invader_bullet_player_collisions - inactive bullet does not cause loss" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position inactive bullet at player position
    state.invader_bullets[0].active = false;
    state.invader_bullets[0].shape.left_x = state.player.shape.left_x;
    state.invader_bullets[0].shape.top_y = state.player.shape.top_y;

    GameState.process_invader_bullet_player_collisions(&state);

    try testing.expect(!state.game_over);
}

test "process_invader_bullet_player_collisions - bullet misses player" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position bullet away from player
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = state.player.shape.left_x + 1000;
    state.invader_bullets[0].shape.top_y = state.player.shape.top_y + 1000;

    GameState.process_invader_bullet_player_collisions(&state);

    try testing.expect(!state.game_over);
}

test "process_invader_bullet_player_collisions - stops checking after first hit" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Position two bullets at player position
    state.invader_bullets[0].active = true;
    state.invader_bullets[0].shape.left_x = state.player.shape.left_x;
    state.invader_bullets[0].shape.top_y = state.player.shape.top_y;
    state.invader_bullets[1].active = true;
    state.invader_bullets[1].shape.left_x = state.player.shape.left_x;
    state.invader_bullets[1].shape.top_y = state.player.shape.top_y;

    GameState.process_invader_bullet_player_collisions(&state);

    // Both bullets should still be active (function breaks after first hit)
    try testing.expect(state.invader_bullets[0].active);
    try testing.expect(state.invader_bullets[1].active);
    try testing.expect(state.game_over);
}

test "process_game_won_condition - player wins when all invaders dead" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Kill all invaders
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            invader.alive = false;
        }
    }

    try testing.expect(!state.game_won);

    GameState.process_game_won_condition(&state);

    try testing.expect(state.game_won);
}

test "process_game_won_condition - player does not win when invaders alive" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // All invaders are alive by default
    GameState.process_game_won_condition(&state);

    try testing.expect(!state.game_won);
}

test "process_game_won_condition - player does not win with one invader alive" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Kill all but one invader
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            invader.alive = false;
        }
    }
    state.invaders[2][5].alive = true;

    GameState.process_game_won_condition(&state);

    try testing.expect(!state.game_won);
}

test "process_game_won_condition - resets game_won to false when invaders respawn" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    // Set game_won to true
    state.game_won = true;

    // All invaders still alive
    GameState.process_game_won_condition(&state);

    // Should be set back to false
    try testing.expect(!state.game_won);
}

// Game loop tests
test "get_draw_mode - returns playing when game is active" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);

    const mode = GameState.get_draw_mode(&state);

    try testing.expectEqual(GameState.DrawMode.playing, mode);
}

test "get_draw_mode - returns won when player has won" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    state.game_won = true;

    const mode = GameState.get_draw_mode(&state);

    try testing.expectEqual(GameState.DrawMode.won, mode);
}

test "get_draw_mode - returns lost when player has lost" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    state.game_over = true;

    const mode = GameState.get_draw_mode(&state);

    try testing.expectEqual(GameState.DrawMode.lost, mode);
}

test "get_draw_mode - won takes priority over lost" {
    var state: GameState.GameState = undefined;
    GameState.init_game_state(&state);
    state.game_won = true;
    state.game_over = true;

    const mode = GameState.get_draw_mode(&state);

    try testing.expectEqual(GameState.DrawMode.won, mode);
}
