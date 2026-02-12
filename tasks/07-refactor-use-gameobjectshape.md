I want to do two refactorings.

# Use of GameObjectShape

I have refactored the Player game object, using GameObjectShape for its shape definition. This meant creating PlayerShape from GameObjectShape, using PlayerShape for shape constant references.
I want to do the same for the other game objects, also using removing their getRect methods, and replacing references to getRect in the game logic to use the corresponding shape fields instead. I want to do this for the following game objects:

1. PlayerBullet
2. Invader
3. InvaderBullet
4. Shield

# Use of drawBox

I have written a comptime function drawBox that draws a game object. It takes a shape type e.g. PlayerShape, a color, e.g. rl.Color.blue, an instance of the shape, and a boolean expression for whether to draw the shape at all.

I have refactored drawing Player to use drawBox. I want to do the same for the following game objects:

1. PlayerBullet - the active condition is just the active field
2. InvaderBullet - the active condition is just the active field
3. Invader - the active condition is the alive field

Note: I do not want to refactor Shield to use drawBox, because Shield has a more complex drawing logic that is not captured by drawBox.
