Tests src/invaders.zig: add tests for moving InvaderBullet.

<!-- It tried to add back a bunch of redundant tests on player bullet. Also, many of the tests generated for Invader and InvaderBullet have little value, testing declarative aspects of the code rather than any logic. For the former, it is arguably worth having one test per code feature, as a form of double entry book-keeping as a defence against regressions, but that's all. -->

---

I don't want build.zig to be too difficult to read. Factor out common declarations where possible. For example, the player and invader tests both depend on module declarations for constants and shapes. Give me some ideas for making build.zig less verbose. Feel free to suggests changes in folder organization.

---

I see addGameTest has parameters for shapes and constants modules. But these are global constants in the build; please remove these parameters and make addGameTest find the values globally.

---

<!-- It then tried to put a whole bunch of unrelated stuff in a struct and pass that as a a parameter. -->

No, this is wrong. The reasons for substituting optimization level are nothing to do with reasons to substitute shapes_module. Unwind these changes and do what I said.
