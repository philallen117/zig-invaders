const rl = @import("raylib");
const constants = @import("constants.zig");
const game_state = @import("game_state.zig");

pub fn main() void {
    rl.initWindow(constants.screenWidth, constants.screenHeight, "Zig Invaders");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    game_state.init_game_state();
    game_loop: while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        if (game_state.game_won) {
            game_state.draw_game_stopped("You won!");
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_state.game_won = false;
                game_state.init_game_state();
                continue :game_loop;
            }
        } else if (game_state.game_over) {
            game_state.draw_game_stopped("You lost.");
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                game_state.game_over = false;
                game_state.init_game_state();
                continue :game_loop;
            }
        } else {
            const player_goes_right = rl.isKeyDown(rl.KeyboardKey.right);
            const player_goes_left = rl.isKeyDown(rl.KeyboardKey.left);
            const player_shoots = rl.isKeyPressed(rl.KeyboardKey.space);
            // I am not making the randomness side effect for invader shooting explicit here :-(
            game_state.update_game_state(player_goes_left, player_goes_right, player_shoots);
            game_state.draw_game_state();
        }
    }
}
