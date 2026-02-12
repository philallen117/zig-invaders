In the code I have written so far, there are several structs that contain fields for dimensions (e.g., width, height) that are redundant because they can be derived from constants. To improve code clarity and reduce redundancy, I want to refactor the code to remove these redundant dimension fields and to use constants directly instead in the functions and logic that rely on them.
I would like to carry out this work one domain type at a time. That is, I want to change the given struct (e.g. `Player`) by removing its redundant dimension fields, and then update its associated functions (e.g. `getRect`) as well as the game and drawing logic in `main` that makes use of them. After making the changes for one domain type, I want to test the game to ensure that it still works correctly before moving on to the next domain type. The domain types to be refactored are as follows:

1. `Player`.
2. `Bullet`.
3. `Invader`.
