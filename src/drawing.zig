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
const ShieldShape = shield_mod.ShieldShape;

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

pub fn draw_player(player: Player) void {
    drawBox(PlayerShape, rl.Color.blue, player.shape, true);
}

pub fn draw_player_bullet(bullet: PlayerBullet) void {
    drawBox(PlayerBulletShape, rl.Color.white, bullet.shape, bullet.active);
}

pub fn draw_invader(invader: Invader) void {
    drawBox(InvaderShape, rl.Color.red, invader.shape, invader.alive);
}

pub fn draw_invader_bullet(bullet: InvaderBullet) void {
    drawBox(InvaderBulletShape, rl.Color.yellow, bullet.shape, bullet.active);
}

pub fn draw_shield(shield: Shield) void {
    if (shield.health > 0) {
        const alpha = @as(u8, @intCast(@min(255, shield.health * 25)));
        rl.drawRectangle(
            shield.shape.left_x,
            shield.shape.top_y,
            ShieldShape.width,
            ShieldShape.height,
            rl.Color{ .r = 0, .g = 255, .b = 255, .a = alpha },
        );
    }
}

pub fn draw_game_state(state: anytype) void {
    rl.drawText("ZigInvaders - SPACE to shoot, ESC to quit", 20, 20, 20, rl.Color.green);
    const score_text = rl.textFormat("Score: %d", .{state.score});
    rl.drawText(score_text, 20, constants.screenHeight - 20, 20, rl.Color.white);
    for (&state.shields) |s| {
        draw_shield(s);
    }
    draw_player(state.player);
    for (&state.player_bullets) |*b| {
        draw_player_bullet(b.*);
    }
    for (&state.invaders) |*row| {
        for (row) |*invader| {
            draw_invader(invader.*);
        }
    }
    for (&state.invader_bullets) |*b| {
        draw_invader_bullet(b.*);
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
