const rl = @import("raylib");
const constants = @import("constants.zig");
const game_state_module = @import("game_state.zig");

const RaylibRng = struct {
    pub fn getRandomValue(self: *@This(), min: i32, max: i32) i32 {
        _ = self;
        return rl.getRandomValue(min, max);
    }
};

const GameState = game_state_module.GameStateModule(RaylibRng);

pub fn main() void {
    rl.initWindow(constants.screenWidth, constants.screenHeight, "Zig Invaders");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var state: GameState.GameState = undefined;
    var rng = RaylibRng{};
    GameState.init_game_state(&state);
    game_loop: while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        if (state.game_won) {
            game_state_module.draw_game_stopped(&state, "You won!");
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                state.game_won = false;
                GameState.init_game_state(&state);
                continue :game_loop;
            }
        } else if (state.game_over) {
            game_state_module.draw_game_stopped(&state, "You lost.");
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                state.game_over = false;
                GameState.init_game_state(&state);
                continue :game_loop;
            }
        } else {
            const player_goes_right = rl.isKeyDown(rl.KeyboardKey.right);
            const player_goes_left = rl.isKeyDown(rl.KeyboardKey.left);
            const player_shoots = rl.isKeyPressed(rl.KeyboardKey.space);
            GameState.update_game_state(&state, &rng, player_goes_left, player_goes_right, player_shoots);
            game_state_module.draw_game_state(&state);
        }
    }
}
