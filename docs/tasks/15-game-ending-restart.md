Test the game lost and game won functionality in game_state.zig: process_invader_bullet_player_collisions and process_game_won_condition.

--- commit

Now let us test the overall implementation of the game loop. Please test the following:

- If the player wins (game_won = true), no further updates to game objects occur.

- If the player loses (game_over = true), no further updates to game objects occur.

- Test that the game loop calls the correct draw method for the state the game is in: draw_game_state when the game is running, draw_game_stopped with message "you won!" when the player has won and draw_game_stopped with message "game over" when the player has lost.

Note: here, I don't want you to test the drawing functions, just the game loop. You may need to refactor the code to enable this testing.

---
