Todo
====

Right now
---------

- The visuals for the laser beam are all wrong, it doesn't hit where it seems to hit
- Main base should remain a light to be able to find the way back
- Implementing the Entity in a horror way
- Move sell button function from station script to left button panel script (while in station)

Should
------

- The further you travel, the more valuable the resources
- Add a splash screen in the beginning to explain what the game is about
- Gamepad controls
- Model for Hauler
- Menu visual uplift

Want
----


Technical Debt
--------------

- Sometimes Asteroids lose their value
- Polish: OnStartShootingAudio play fully on pressing the mouse click each time? Right now it is only playing as long as we pressed it
- Polish: Loop OnHitAudio and OnMissAudio. Right now there’s a second gap when the audio file ends and then it starts again. Is it possible to loop from middle so that it sounds seamless till the mining laser heats up?
- Polish: When player ship is idle there's an audio loop playing and there's 5-6 ms gap when it ends and when it starts again which introduces a pop/glitch
- After dying the lifebar is not shown correctly
- Momentum after undocking is preserved
- Scoreboard myscore doesn't show correctly if you are the best or worst
