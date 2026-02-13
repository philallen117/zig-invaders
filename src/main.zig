const rl = @import("raylib");
const constants = @import("constants.zig");
const game_state_module = @import("game_state.zig");
const drawing = @import("drawing.zig");

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
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        const draw_mode = GameState.get_draw_mode(&state);

        switch (draw_mode) {
            .won => {
                drawing.draw_game_stopped(&state, "You won!");
                if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                    GameState.init_game_state(&state);
                }
            },
            .lost => {
                drawing.draw_game_stopped(&state, "You lost.");
                if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                    GameState.init_game_state(&state);
                }
            },
            .playing => {
                const player_goes_right = rl.isKeyDown(rl.KeyboardKey.right);
                const player_goes_left = rl.isKeyDown(rl.KeyboardKey.left);
                const player_shoots = rl.isKeyPressed(rl.KeyboardKey.space);
                GameState.update_game_state(&state, &rng, player_goes_left, player_goes_right, player_shoots);
                drawing.draw_game_state(&state);
            },
        }
    }
}
