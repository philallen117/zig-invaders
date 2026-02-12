In the game in `main.zig`, want to move constants for game objects into the structs representing those objects, as pub consts. I have already done this for Player and Shield. I want you to do that for:

1. PlayerBullet
2. InvaderBullet - give it its own constants rather than reuse PlayerBullet's
3. Invader

Do not attempt to do this for the screen constants.

Finally, Move speed constants into the structs representing the objects they relate to. For example, move Invader's speed constant into the Invader struct as a pub const.
