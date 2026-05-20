Todo
====

Vertical Slice 
--------------

- The visuals for the laser beam are all wrong, it doesn't hit where it seems to hit
- Add at least control overview in the settings menu

Should
-----------

- having the healthbars on top of the asteroid instead of static on the UI
- Gamepad controls

Want
-----------

- GUT - Godot Unit Testing


Technical Debt
--------------

- Bug: After Load sometimes the esc menu stays open and cannot be closed or a second menu overlays
- Sometimes Asteroids lose their value
- Polish: OnStartShootingAudio play fully on pressing the mouse click each time? Right now it is only playing as long as we pressed it
- Polish: Loop OnHitAudio and OnMissAudio. Right now there’s a second gap when the audio file ends and then it starts again. Is it possible to loop from middle so that it sounds seamless till the mining laser heats up?