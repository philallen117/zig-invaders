I want to add bullets that the Invaders can fire.

1. Create InvaderBullet struct with the same fields as PlayerBullet, and with an init function that behaves the same way as PlayerBullet's init function, and a getRect function that behaves the same way as PlayerBullet's getRect function.

2. Create pool of InvaderBullets, similar to the existing pool of PlayerBullets. There will be maxInvaderBullets (already defined in the code) of them. Initialize them all in the init function of the main game logic, next to the code for initializing the the player bullets.
