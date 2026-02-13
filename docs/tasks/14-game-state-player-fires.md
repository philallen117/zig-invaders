Now it is time to start testing update_game_state. We will do this in small chunks reflecting game behaviour. update_game_state was written without testing in mind, so it will possibly be a good idea to extract functions from it for focussed testing. include such refactoring in your plans.

initially, define a struct called GameState and pass this explicitly between main, init_game_state, update_game_state and the two draw functions in game_state.zig.

---

Test players firing bullets. Do no test key press detection, only the logic in game_state. Here are expected behaviours.

- The game tries to find an inactive player bullet. If no such bullet is available, nothing further happens. This is not an error condition.
- Where an inactive bullet is available, the game makes it active and positions it to be fired from the top middle of the player object.

---

Now add tests for player bullets colliding with invaders and with shields. They are handled in the same bullet loop for efficiency, but you can consider pulling these into separate loops if that greatly simplifies testing. Evaluate the alternatives and tell me what you think.

The expected behaviours for player bullet - invader collisions are:

- Invader dies (become not alive).
- Bullet becomes inactive.
- Score increases by configured constant.
- Dead invaders do not collide with bullets.

The expected behaviours for player bullet - shield collisions are:

- Bullet becomes inactive.
- Shield health reduces by 1.
- As soon as shield health reaches 0, it no longer collides with player bullets.

--- commit

Now add tests for invader movement.

- Invaders (that are still alive) move collectively. E.g. distances between them are preserved.
- Invaders do not move every frame, but move after Invader.moveDelay frames.
- Invaders initially move right (invader_direction = +1) until one of them that is still alive reaches the right edge. At this point, they all drop (dropDistance) and invader_direction toggles to -1.
- In this state, invaders now move left and perform the analogous behaviour.

--- commit

process_invader_shooting calls raylib.getRandomValue directly. in order to support mocking, i would like to parameterize process_invader_shooting by a function that returns a stream of random values. moreover, I would like to avoid a direct dependency of state update logic on raylib. Recommend a design or alternative designs. Don't make changes, just discuss design options.

--- commit

Now add test for invader bullets.
