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
