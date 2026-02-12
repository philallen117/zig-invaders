const rl = @import("raylib");
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

// Game state
pub var score: i32 = 0;
pub var game_over: bool = false;
pub var game_won: bool = false;
pub var invader_direction: i32 = 1;
pub var invader_move_timer: i32 = 0;
pub var invader_shoot_timer: i32 = 0;
pub var player: Player = undefined;
pub var player_bullets: [constants.maxPlayerBullets]PlayerBullet = undefined;
pub var invader_bullets: [constants.maxInvaderBullets]InvaderBullet = undefined;
pub var invaders: [constants.invaderRows][constants.invaderCols]Invader = undefined;
pub var shields: [constants.shieldStartCount]Shield = undefined;

pub fn init_game_state() void {
    score = 0;
    game_over = false;
    game_won = false;
    invader_direction = 1;
    invader_move_timer = 0;
    invader_shoot_timer = 0;
    player = Player.init(constants.screenWidthBy2 - PlayerShape.widthBy2, constants.screenHeight - 60);
    for (&player_bullets) |*b| {
        b.* = PlayerBullet.init(0, 0);
    }
    for (&invader_bullets) |*b| {
        b.* = InvaderBullet.init(0, 0);
    }
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = constants.invaderStartX + constants.invaderSpacingX * @as(i32, @intCast(j));
            const y = constants.invaderStartY + constants.invaderSpacingY * @as(i32, @intCast(i));
            invader.* = Invader.init(x, y);
        }
    }
    for (&shields, 0..) |*s, i| {
        s.* = Shield.init(
            constants.shieldStartX + constants.shieldSpacingX * @as(i32, @intCast(i)),
            constants.shieldStartY,
        );
    }
}

pub fn update_game_state(player_goes_left: bool, player_goes_right: bool, player_shoots: bool) void {
    player.move(player_goes_left, player_goes_right);
    if (player_shoots) {
        for (&player_bullets) |*b| {
            if (!b.active) {
                b.active = true;
                b.shape.left_x = player.shape.left_x + PlayerShape.widthBy2 - PlayerBulletShape.widthBy2;
                b.shape.top_y = player.shape.top_y;
                break;
            }
        }
    }
    for (&player_bullets) |*b| {
        b.move();
    }
    // Find collisions between player bullets and invaders before invaders move or shoot.
    // Do shields too.
    for (&player_bullets) |*b| {
        if (b.active) {
            const bRect = b.shape.getBox();
            invaderLoop: for (&invaders) |*row| {
                for (row) |*i| {
                    if (i.alive) {
                        if (bRect.intersects(i.shape.getBox())) {
                            b.active = false;
                            i.alive = false;
                            score += 10;
                            break :invaderLoop;
                            // because each bullet kills at most one invader
                        }
                    }
                }
            }
            for (&shields) |*s| {
                if (s.health > 0 and bRect.intersects(s.shape.getBox())) {
                    b.active = false;
                    s.health -= 1;
                    break;
                }
            }
        }
    }
    invader_move_timer += 1;
    if (invader_move_timer == Invader.moveDelay) {
        invader_move_timer = 0;

        // Check for invaders hitting edge.
        // Start false and look for true.
        var invader_hit_edge = false;
        invaders: for (&invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    const dx = invader_direction * Invader.speed;
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
            invader_direction *= -1;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    invader.move(0, Invader.dropDistance);
                }
            }
        } else {
            for (&invaders) |*row| {
                for (row) |*invader| {
                    const dx = invader_direction * Invader.speed;
                    invader.move(dx, 0);
                }
            }
        }
    }
    // Invaders shooting before invader bullets update
    invader_shoot_timer += 1;
    if (invader_shoot_timer == Invader.shootDelay) {
        invader_shoot_timer = 0;
        for (&invaders) |*row| {
            for (row) |*i| {
                if (i.alive and rl.getRandomValue(1, 100) <= Invader.shootChance) {
                    bullet_loop: for (&invader_bullets) |*b| {
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
    for (&invader_bullets) |*b| {
        b.move();
    }
    // Check whether player or shield hit.
    for (&invader_bullets) |*b| {
        if (b.active) {
            const bRect = b.shape.getBox();
            if (bRect.intersects(player.shape.getBox())) {
                game_over = true;
                break;
            }
            for (&shields) |*s| {
                if (s.health > 0 and bRect.intersects(s.shape.getBox())) {
                    b.active = false;
                    s.health -= 1;
                    break;
                }
            }
        }
    }
    // Check for game won. Start true and negate if there is a live invader.
    game_won = true;
    invaders: for (&invaders) |*row| {
        for (row) |*invader| {
            if (invader.alive) {
                game_won = false;
                break :invaders;
            }
        }
    }
}

pub fn draw_game_state() void {
    rl.drawText("ZigInvaders - SPACE to shoot, ESC to quit", 20, 20, 20, rl.Color.green);
    const score_text = rl.textFormat("Score: %d", .{score});
    rl.drawText(score_text, 20, constants.screenHeight - 20, 20, rl.Color.white);
    for (&shields) |s| {
        s.draw();
    }
    player.draw();
    for (&player_bullets) |*b| {
        b.draw();
    }
    for (&invaders) |*row| {
        for (row) |*invader| {
            invader.draw();
        }
    }
    for (&invader_bullets) |*b| {
        b.draw();
    }
}

pub fn draw_game_stopped(message: [:0]const u8) void {
    const game_over_font_size = 40;
    const message_width = rl.measureText(message, game_over_font_size);
    rl.drawText(
        message,
        constants.screenWidthBy2 - @divFloor(message_width, 2),
        constants.screenHeightBy2 - 2 * game_over_font_size,
        game_over_font_size,
        rl.Color.white,
    );
    const score_text = rl.textFormat("Final Score: %d", .{score});
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
