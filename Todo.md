Todo
====

Right now
---------

- Add space station model
- Create simple interiour scene for inside the space station
- Fix all menu styles so it's not the default godot style anymore
    - Reimplement the sidebars in the main menu
    - Fix Credits page so all people can be seen on the first page
    - Choose a font which is more readable?
    - Update inside space station menu
- Fix Entity sound distance volume
- Balance the game
- Add explosion effect
- Change splash screen

Optional
------

- Replace Audio:
    - 353159__kinoton__room-tone-sci-fi-large-hall.ogg | Space Station Ambient
    - 130883__karma-ron__mysterion-low-ship-humming.ogg | Space Scene / Ship Idle
    - 833495__wavewire__lootpickup_feedback.ogg | Asteroid Resource Pickup Collected
- Replace Textures:
    - flare_0.png | Signal light at hauler ship
    - asteroid-icon_vecteezy.png | Asteroid Resource Pickup Hovering
- Add an explanation what the game is about

Want
----


Technical Debt
--------------

- Move sell button function from station script to left button panel script (while in station)
- Polish: OnStartShootingAudio play fully on pressing the mouse click each time? Right now it is only playing as long as we pressed it
- Polish: Loop OnHitAudio and OnMissAudio. Right now there’s a second gap when the audio file ends and then it starts again. Is it possible to loop from middle so that it sounds seamless till the mining laser heats up?
- Polish: When player ship is idle there's an audio loop playing and there's 5-6 ms gap when it ends and when it starts again which introduces a pop/glitch
- After dying the lifebar is not shown correctly
- Momentum after undocking is preserved