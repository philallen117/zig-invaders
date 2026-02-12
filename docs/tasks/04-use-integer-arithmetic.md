The code I have written so far uses a mix of floating-point and integer arithmetic. To improve performance and avoid precision issues, I want to refactor the code to use only integer arithmetic, which is what the raylib library uses for coordinates and dimensions.

This will involve changing variable types, changing function parameter types, changing constants, and modifying calculations, and ensuring that all operations are done using integers. Note that only addition, subtraction and multiplication are used in the code.

I would like to carry out this work one domain type at a time. That is, I want to change the given struct (e.g. `Player`) and its associated functions and constants (e.g. `playerWidth`) and the game and drawing logic in `main` that makes use of it. After making the changes for one domain type, I want to test the game to ensure that it still works correctly before moving on to the next domain type. The domain types to be refactored are as follows:

1. `Rectangle`.
2. `Player`.
3. `Bullet`.
4. `Invader`.

// const GameConfig = struct {
//     screenWidth: i32 = 800,
//     screenHeight: i32 = 600,
//     playerWidth: f32 = 50.0,
//     playerHeight: f32 = 20.0,
//     playerStartY: f32 = 550.0,
//     bulletWidth: f32 = 5.0,
//     bulletHeight: f32 = 10.0,
//     shieldStartX: f32 = 150.0,
//     shieldY: f32 = 500.0,
//     shieldWidth: f32 = 60.0,
//     shieldHeight: f32 = 30.0,
//     shieldSpacing: f32 = 100.0,
//     invaderStartX: f32 = 100.0,
//     invaderStartY: f32 = 50.0,
//     invaderWidth: f32 = 40.0,
//     invaderHeight: f32 = 30.0,
//     invaderSpacingX: f32 = 20.0,
//     invaderSpacingY: f32 = 20.0,
// };
