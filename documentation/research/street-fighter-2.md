# Street Fighter II

[Player Game](https://www.retrogames.cz/play_304-SNES.php?language=EN)

## Collision Detection

Each character has multiple hitboxes and one hurtbox. Hitboxes are the areas on a sprite that represent where the character can be hit by an attack, and hurtboxes are the areas on a sprite that cause damage when they come into contact with enemy hitboxes. Multiple hitboxes allow for a little better hit registration than one rectange, and change throughout sprite animations. They don't stick to the exact sprite but are just a rough rectangular approximation.

*In the figure below image, hitboxes are blue.*

![image](https://user-images.githubusercontent.com/8422699/148707950-01e808a4-5e4b-46a3-a25c-ba65bf98a9aa.png)


*In the figure below, hitboxes are blue and hurtboxes are red.*

![image](https://user-images.githubusercontent.com/8422699/148707975-19685a97-1a68-47c3-91b6-eb901ac73d63.png)

## Movement

- Players face each other constantly. If a player jumps over another, after a handful of frames the other player flips to face them.
- Movement is rather slow sidestepping instead of running
- During an attack or crouching the player cannot move (unless hit)
- When in the air, the player cannot change direction until reaching the ground
- Some moves have the player step out of their standing positiong but they do not actually move

## References
- https://www.retrogames.cz/play_304-SNES.php?language=EN
- https://combovid.com/?p=956
