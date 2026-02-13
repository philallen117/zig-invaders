So far, we have split up the code by game objects and overall game behaviour, combining game logic and drawing into the same source files.

But the game logic is thoroughly tested and (apart from main) does not depend on raylib, while the drawing code does depend on raylib and is not so easy to test automatically.

I would like to split the code into game logic and drawing, with only a short main.zig file bringing the two together. Drawing is allowed to depend on game data types but not vice versa. This means:

- Moving draw_game_state and draw_game_stopped out of game_state.zig.
- Moving drawBox out of shapes.zig.
- Moving draw methods out of Player and other game object structs.

Propose changes to source files summarizing the contents of the source files. Do not make the changes, yet.
