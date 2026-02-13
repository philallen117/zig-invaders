const constants = @import("constants.zig");
const player_mod = @import("player.zig");
const invader_mod = @import("invader.zig");
const shield_mod = @import("shield.zig");

const Player = player_mod.Player;
const PlayerShape = player_mod.PlayerShape;
const PlayerBullet = player_mod.PlayerBullet;
const PlayerBulletShape = player_mod.PlayerBulletShape;
const Invader = invader_mod.Invader;
const InvaderShape = invader_mod.InvaderShape;
const InvaderBullet = invader_mod.InvaderBullet;
const InvaderBulletShape = invader_mod.InvaderBulletShape;
const Shield = shield_mod.Shield;

pub fn GameStateModule(comptime RngSource: type) type {
    return struct {
        pub const GameState = struct {
            score: i32,
            game_over: bool,
            game_won: bool,
            invader_direction: i32,
            invader_move_timer: i32,
            invader_shoot_timer: i32,
            player: Player,
            player_bullets: [constants.maxPlayerBullets]PlayerBullet,
            invader_bullets: [constants.maxInvaderBullets]InvaderBullet,
            invaders: [constants.invaderRows][constants.invaderCols]Invader,
            shields: [constants.shieldStartCount]Shield,
        };

        pub fn init_game_state(state: *GameState) void {
            state.score = 0;
            state.game_over = false;
            state.game_won = false;
            state.invader_direction = 1;
            state.invader_move_timer = 0;
            state.invader_shoot_timer = 0;
            state.player = Player.init(constants.screenWidthBy2 - PlayerShape.widthBy2, constants.screenHeight - 60);
            for (&state.player_bullets) |*b| {
                b.* = PlayerBullet.init(0, 0);
            }
            for (&state.invader_bullets) |*b| {
                b.* = InvaderBullet.init(0, 0);
            }
            for (&state.invaders, 0..) |*row, i| {
                for (row, 0..) |*invader, j| {
                    const x = constants.invaderStartX + constants.invaderSpacingX * @as(i32, @intCast(j));
                    const y = constants.invaderStartY + constants.invaderSpacingY * @as(i32, @intCast(i));
                    invader.* = Invader.init(x, y);
                }
            }
            for (&state.shields, 0..) |*s, i| {
                s.* = Shield.init(
                    constants.shieldStartX + constants.shieldSpacingX * @as(i32, @intCast(i)),
                    constants.shieldStartY,
                );
            }
        }

        pub fn fire_player_bullet(state: *GameState) void {
            for (&state.player_bullets) |*b| {
                if (!b.active) {
                    b.active = true;
                    b.shape.left_x = state.player.shape.left_x + PlayerShape.widthBy2 - PlayerBulletShape.widthBy2;
                    b.shape.top_y = state.player.shape.top_y;
                    break;
                }
            }
        }

        pub fn process_player_bullet_invader_collisions(state: *GameState) void {
            for (&state.player_bullets) |*b| {
                if (b.active) {
                    const bRect = b.shape.getBox();
                    invaderLoop: for (&state.invaders) |*row| {
                        for (row) |*i| {
                            if (i.alive) {
                                if (bRect.intersects(i.shape.getBox())) {
                                    b.active = false;
                                    i.alive = false;
                                    state.score += constants.invaderKillScore;
                                    break :invaderLoop;
                                    // because each bullet kills at most one invader
                                }
                            }
                        }
                    }
                }
            }
        }

        pub fn process_player_bullet_shield_collisions(state: *GameState) void {
            for (&state.player_bullets) |*b| {
                if (b.active) {
                    const bRect = b.shape.getBox();
                    for (&state.shields) |*s| {
                        if (s.health > 0 and bRect.intersects(s.shape.getBox())) {
                            b.active = false;
                            s.health -= 1;
                            break;
                        }
                    }
                }
            }
        }

        pub fn process_invader_movement(state: *GameState) void {
            state.invader_move_timer += 1;
            if (state.invader_move_timer == Invader.moveDelay) {
                state.invader_move_timer = 0;

                // Check for invaders hitting edge.
                // Start false and look for true.
                var invader_hit_edge = false;
                invaders: for (&state.invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive) {
                            const dx = state.invader_direction * Invader.speed;
                            const new_x = invader.shape.left_x + dx;
                            if (new_x <= 0 or new_x + InvaderShape.width >= constants.screenWidth) {
                                invader_hit_edge = true;
                                break :invaders;
                            }
                        }
                    }
                }
                // In which case, they drop and switch direction.
                if (invader_hit_edge) {
                    state.invader_direction *= -1;
                    for (&state.invaders) |*row| {
                        for (row) |*invader| {
                            invader.move(0, Invader.dropDistance);
                        }
                    }
                } else {
                    for (&state.invaders) |*row| {
                        for (row) |*invader| {
                            const dx = state.invader_direction * Invader.speed;
                            invader.move(dx, 0);
                        }
                    }
                }
            }
        }

        pub fn process_invader_shooting(state: *GameState, rng: *RngSource) void {
            state.invader_shoot_timer += 1;
            if (state.invader_shoot_timer == Invader.shootDelay) {
                state.invader_shoot_timer = 0;
                for (&state.invaders) |*row| {
                    for (row) |*i| {
                        if (i.alive and rng.getRandomValue(1, 100) <= Invader.shootChance) {
                            bullet_loop: for (&state.invader_bullets) |*b| {
                                if (!b.active) {
                                    b.active = true;
                                    b.shape.left_x = i.shape.left_x + InvaderShape.widthBy2 - InvaderBulletShape.widthBy2;
                                    b.shape.top_y = i.shape.top_y + InvaderShape.height;
                                    break :bullet_loop;
                                }
                            }
                        }
                    }
                }
            }
        }

        pub fn update_game_state(state: *GameState, rng: *RngSource, player_goes_left: bool, player_goes_right: bool, player_shoots: bool) void {
            state.player.move(player_goes_left, player_goes_right);
            if (player_shoots) {
                fire_player_bullet(state);
            }
            for (&state.player_bullets) |*b| {
                b.move();
            }
            // Find collisions between player bullets and invaders before invaders move or shoot.
            // Do shields too.
            process_player_bullet_invader_collisions(state);
            process_player_bullet_shield_collisions(state);
            process_invader_movement(state);
            // Invaders shooting before invader bullets update
            process_invader_shooting(state, rng);
            for (&state.invader_bullets) |*b| {
                b.move();
            }
            // Check whether player or shield hit.
            for (&state.invader_bullets) |*b| {
                if (b.active) {
                    const bRect = b.shape.getBox();
                    if (bRect.intersects(state.player.shape.getBox())) {
                        state.game_over = true;
                        break;
                    }
                    for (&state.shields) |*s| {
                        if (s.health > 0 and bRect.intersects(s.shape.getBox())) {
                            b.active = false;
                            s.health -= 1;
                            break;
                        }
                    }
                }
            }
            // Check for game won. Start true and negate if there is a live invader.
            state.game_won = true;
            invaders: for (&state.invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        state.game_won = false;
                        break :invaders;
                    }
                }
            }
        }
    };
}

// Drawing functions remain outside the generic module as they depend on raylib
const rl = @import("raylib");

pub fn draw_game_state(state: anytype) void {
    rl.drawText("ZigInvaders - SPACE to shoot, ESC to quit", 20, 20, 20, rl.Color.green);
    const score_text = rl.textFormat("Score: %d", .{state.score});
    rl.drawText(score_text, 20, constants.screenHeight - 20, 20, rl.Color.white);
    for (&state.shields) |s| {
        s.draw();
    }
    state.player.draw();
    for (&state.player_bullets) |*b| {
        b.draw();
    }
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            invader.draw();
        }
    }
    for (&state.invader_bullets) |*b| {
        b.draw();
    }
}

pub fn draw_game_stopped(state: anytype, message: [:0]const u8) void {
    const game_over_font_size = 40;
    const message_width = rl.measureText(message, game_over_font_size);
    rl.drawText(
        message,
        constants.screenWidthBy2 - @divFloor(message_width, 2),
        constants.screenHeightBy2 - 2 * game_over_font_size,
        game_over_font_size,
        rl.Color.white,
    );
    const score_text = rl.textFormat("Final Score: %d", .{state.score});
    const score_text_width = rl.measureText(score_text, game_over_font_size);
    rl.drawText(
        score_text,
        constants.screenWidthBy2 - @divFloor(score_text_width, 2),
        constants.screenHeightBy2,
        game_over_font_size,
        rl.Color.white,
    );
    const start_again_text = "ENTER to start again, ESC to quit.";
    const start_again_text_width = rl.measureText(start_again_text, game_over_font_size);
    rl.drawText(
        start_again_text,
        constants.screenWidthBy2 - @divFloor(start_again_text_width, 2),
        constants.screenHeightBy2 + 2 * game_over_font_size,
        game_over_font_size,
        rl.Color.white,
    );
}
