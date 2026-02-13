In game_state.zig, process_game_frame is too "thin" and does not help code understanding. i prefer to remove it and inline its logic into main. but make sure overall test coverage will remain as good.

---

Interesting that it was able to check effect on testing!

✂️ Removed 6 tests for process_game_frame:
Tests for no updates when won/over (redundant - main loop controls this)
Tests for updates when playing (covered by existing update_game_state tests)
Tests for bullet firing (covered by existing tests)

---

in game_loop, do i still need the "continue" statements that are inside the branches of the switch? if not, remove them.
