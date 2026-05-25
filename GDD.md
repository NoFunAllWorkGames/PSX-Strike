**Project “Strike” GDD**
========================


**Core Concept**
----------------

Project “Strike” is a 3rd Person 3D Sci-fi space mining game with cosmic horror undertones, where the player works for an agency called the “Experitus Exploration Agency,” navigating an expansive asteroid field to locate and extract valuable materials using their powerful mining laser.” Threats infest in the field, however, as bandit ships threaten to attack the ship and steal the valuable resources the player collects. Meanwhile, an unknown entity’s presence looms over the player, threatening to destroy their helpless vessel if they don’t return to their station in time. The ship is equipped with guns to defend itself against the bandit ships, and the player can also buy deployable turrets to assist in the defense. When the player returns to the space station, they may deposit their haul in exchange for credits, which can be spent on upgrades to increase their efficiency and chances of survival

**Vision**  
----------
	  
This project aims to create a mining game that can be both relaxing and unsettling, without being overwhelming. By introducing elements of cosmic horror, this game can provide a sense of urgency and unrest into an otherwise mundane and repetitive task, which most similar games do not do. We want players to always be on their toes and reach a point where they react to events that only their mind constructs.

**Systems**
===========

**Core Mechanics**
------------------

The core mechanics center entirely around the ship and its systems, and therefore, the rest of the game shall also center around the ship and these systems.

* **Mining Laser** \- The ship is equipped with a mining laser, located on the top of the bridge. This laser is what is used to break apart the rocks into smaller collectible pieces. The mining laser follows where the cursor is pointing. The laser will overheat when used for too long at one time. **\***The mining laser could have two modes: one specifically for destroying large asteroids, and a more precise one for gathering resources.  
* **Armaments** \- The ship can be equipped with laser repeaters, ballistic cannons, or missile pods to shoot down enemy ships. The mining laser can not be active when the armaments are active, and vice versa. Only one type of armament can be equipped at a time. Armaments can not destroy asteroids.  
  * **Lasers** have a high cyclic rate, moderate capacity, but low damage. **Cannons** have a high capacity, moderate damage, but low cyclic rate. **Missiles** have high damage, Moderate Cyclic rate, but low Capacity.  
* **Deployable Turrets** \- Single use turrets can be deployed to attack any enemies that come into range. These turrets will persist until the player returns to the station and ends their run. Similar to armaments, there are laser turrets, ballistic turrets, and missile turrets.  


**Gameplay**
============


**Onboarding**
--------------

The first time a player starts a new save, they will start with the tutorial sequence. This begins with the player being guided to fly towards an asteroid to begin mining it. They may accelerate, decelerate, ascend, descend, strafe, and yaw (No pitch or roll to keep things simple, but it can be added if we see fit). Once they are in range of the asteroid, they can fire their laser to begin mining away at it. By aiming the laser directly at a piece of material, they can collect it. Once they completely mine out the rocks they will be collected into the player’s inventory. Once they fill up their inventory they will be directed to return to the station to deposit their materials, where they can buy their first upgrades. They will repeat this until an enemy ship spawns. The player will be directed to attack and destroy the ship before they can continue mining. This will be the first and last time destroying an enemy ship will be easy. They will continue doing mining runs until the Entity makes its presence known. The game will not explain what the entity is, and will only direct the player to return home before it actually appears.

**Controls**
-------------

* **Accel & Decel** \- W & S  
* **Strafe** \- A & D  
* **Ascend & Descend** \- Space & CTRL  
* **Yaw/Aim Laser or Armaments**\- Mouse  
* **Use Laser/ Fire Armaments** \- L-Click  
* **Switch Laser/Armaments** \- E  
* **Deploy Turret** \- Q 

Controller support should be added


**Gameplay Loop**
-----------------

The typical loop starts with the player leaving the station to go mining in the asteroid field. As they break down the asteroids and collect them their inventory will fill. The more full their inventory, the more likely an enemy ship will spawn. The player will defend themselves against the enemy ship using their armaments or turrets before they continue mining. After a certain amount of time passes the Entity will spawn in the distance and slowly draw closer. The player can not fight this entity and must return to the station to unload their resources. At the station, their resources are exchanged for credits, and they will be able to refuel, repair, change armaments, purchase upgrades, and buy new turrets. After they are done in the station this loop repeats.

**Progression**
---------------

| Hull | Health | Speed | Fuel |  |
| :---- | :---- | :---- | :---- | :---- |
| **Mining Laser** | Strength | Mining rate | Cooling | Cargo |
| **Armaments** | Damage | Cyclic Rate | Capacity |  |
| **Turrets** | Damage | Range | Count |  |

As the player is able to travel further, the more valuable resources will also increase. As the mining laser’s strength increases, so too will their ability to mine through harder material

**Threats**
------------

The more full the player’s cargo gets, the higher the likelihood of an enemy ship spawning. When the player destroys an enemy ship, it increases the chances of a second one spawning in the next mining run. Enemies will try to keep their distance from the player, but not too far out of range of their weapons. The further out the player goes, the stronger the enemies get.  

The longer the player stays out mining the higher the likelihood of the Entity spawning.  
Types of enemy ships:

* **Hauler** \- Slow ship, flying linear through the space, just shooting at the player when the player comes too near
* **Nimble** \- Fast and doesn’t stop moving, but low health and damage.  
* **Hardy** \- Slow with lots of health.  
* **Cautious** \- Keeps its distance and reheals over time.  
* **Annoying** \- Not much damage, but occasionally shuts down thrusters or weapons.  
* **Stealthy** \- Does not give an alert when it appears.  
* **Aggressive** \- Deals the most damage.

**Ending**  
----------

There is no definitive ending to this game. However, setting a concrete goal or quota, either per trip or overall, will give players something tangible to work with, beyond simply reaching maximum upgrades.


**Narrative**
=============

Project “Strike” is not a story-driven game, but it is grounded in the wider fiction of the verse.

This game takes place in the 27th century, in the midst of a resource gathering race, as Humanity’s top industrial organizations rush to gather as many valuable materials as they can from around the Solar system and neighboring bodies with the hopes of gaining enough materials to build colony ships capable of allowing Humanity to escape the system-wide calamity that’s befallen them.

This game has a central theme that deals with the effects of traumatic events that deeply affect people, even in their daily lives, known as Post Traumatic Stress Disorder, or Shellshock. This game should explore this theme by producing an environment where the player never feels truly safe, no matter how many upgrades they purchase.

This will also have a darker and grittier tone than similar games. Because of the nature of why they are mining in the first place, there is a sense of urgency and dread, especially in character dialogues.

It is important that while this takes place in the wider universe that we never explicitly state that it is a part of any kind of universe at all\! The impression is that this and all subsequent games are isolated\!

**Visuals**
============

Resolution and sizing
---------------------

The game will be run in **426x240** which is a widescreen version of the original **320 × 240** NTSC Standard original PSX size.  
The main window will remain at the original **320 × 240** resolution but it will have two added sidebars with a resolution of **53x240** each. To make the game easier to see on modern displays it will by default scale the window by a factor 2 or 4, while remaining the original internal resolution.

**Visual Aesthetic**
--------------------

The visual aesthetic we will be aiming for is Dark Sci-fi, similar to that of the artist BakaArts. This aesthetic features sharp contrasts, striking colors, and a cell-shaded texture to everything. All of the ships and the station also have a futuristic industrial design. Do not allow this to turn “cartoony.” We must maintain the dark and gritty tone and cosmic horror undertones. Additionally, this is not a cyberpunk aesthetic, despite the similarities.

**Environment**
---------------

The environment will be a deep space skybox, with floating asteroids scattered around the empty space. Lighting will be a harsh, directional lighting that can be blinding when looking at the source, which should appear in a random location each trip.

Locations:
- Space Station
- Space with small asteroids

Enities:
- Turrets
- Enemy Ships
- Big Scary Black Blob Horror


**Models**
----------

* **The Ship** will be a boxy shape with the cockpit located to the right side of the nose of the ship, while the mining laser is on the left, on top. The armament is placed on the top of the ship, able to turn 180 degrees. The ship will have 2 wings with large thrusters on the ends, and RCS thrusters all around the ship.  
* **The Station** is a simple spire with a massive ring around it and solar panel wings. The only part that needs to be detailed is the hangar that the player flies in and out of between trips  
* **The Armaments** will be simple in design as well; the laser and cannon is mostly just a pair of tubes with identifying details on them, while the missile pod is a hexagon shape, with missiles in the corners and one in the center. Their surface details and colors will change to reflect their upgrades.  
* **Deployable Turrets** will be shaped like curling stones, with the weapons placed on top. The weapon models will be the same as the ship armaments.  
* **Asteroids** will be a random assortment and shapes of gray rocks of different sizes with crater impacts on them.  
* **Resources** will be small floating masses of different colored material with a transparent white bubble around them for visibility.  
* **Enemy Ships** will have more aggressive designs, with thinner builds, and sharper edges.  
* **The Entity** will be a mass of black glitching artifacts and whatever makes it appear like something unfathomable to the human find.

**Visual Effects**
------------------

The visual effects will be used to give lots of visual feedback to the player’s actions. This is paramount for enhancing the feel of the game 

* The ship thrusters will slowly grow with a blue trail when accelerating or decelerating, while the RCS thrusters will randomly pulse, especially after ascending, descending, mining, or firing ordinance.  
* The mining laser will be an orange-red hue, with particles flying from the origin of the laser, and from where it contacts an asteroid. A flashlight on the front of the ship will give clearer visibility when facing the dark side of asteroids. The laser module itself will grow red when overheating.  
* The laser repeater will rapidly pulse red beams. The cannon will have a bright orange flash followed by a puff of smoke. The missiles will let out an orange sprite followed by a faint smoke trail.  
* When the ship takes impacts, whether it be from asteroids, or weapon fire, sparks will fly while wear and tear appears and accumulates with additional impacts. When it is destroyed, it will do so with an explosion.

**HUD & UI**
-------------

* The HUD will remain minimal and unobstructive.   
* At the top of the screen will be a compass that points to the station.  
* On the right will be a vertical bar that indicates cargo capacity  
* On the left will be a bar that indicates fuel reserves, with numbers to the right of that indicating armament ammunition and deployable turrets remaining. A darker section of the fuel reserves will indicate how much fuel will be needed to return to the station, based on the distance.  
* The bottom of the screen will have a horizontal bar that indicates the ship’s hull health.  
* A red triangle will appear flashing on the compass when an enemy spawns, then remain a solid red to indicate which direction the enemy is.  
* When the entity is close, the edges of the screen will darken, and the HUD will glitch. As it gets closer, this effect becomes stronger.  
    
* The UI menus will appear to be off of an industrial screen interface.



**Audio**
=========

**Audio Aesthetic**
-------------------

**Music**  

The aesthetic of the music and sounds of this game will be eerie and unsettling, but oddly comforting at the same time.

**Sound Effects**

* The sound effects during mining will be muffled and muddy, as if hearing them from outside of the ship.  
* **The Ship** will have a gentle hum with a low tamber, and a bass you can feel in your ears. The main thrusters should have a thick rumble, while the rcs thrusters should make sharp hisses as they pulse. (Mid Priority)  
* **The mining laser** will have a soft tenor buzzing sound that makes mining feel satisfying. (High Priority)  
* **The armaments** will have thick punchy sound effects to sell the feeling for firing ship-mounted weapons. (Mid-High)  
* **The deployable turrets** will have the same effect, but will also feature a deep mechanical deployment sound. (High)  
* **Alerts** of different kinds will each have their own sounds for things like low fuel, low ammo, overheating mining laser, full cargo, low ship health, and enemy spawns (But not for the entity). (Low)  
* **Rocks Breaking** (Mid)  
* **Collisions** (Mid)  
* **The Entity** should have unsettling outer-dimensional sounds that overtake any other sound effects. (Mid-High)  
* **UI Sounds** (Low)


**Development**
================


**Principles**
--------------

1) **Mining is primary, Surviving is secondary** \- The combat encounters should be few and far between, and should incentivise the player to escape, rather than attempt to fight back.  
2) **The Entity Exists, and it’s dangerous** \- The Entity should not hold back when attacking the player. When it appears it should practically mean game over.  
3) **Equity in all things** \- The guns and deployable turrets should be equal in effectiveness, rather than one being better or worse than the other.  
4) **Always Improving** \- The player should feel a substantial improvement with every upgrade. Nothing they do should feel wasted.

**Design**  
	This game will be designed with the fantasy of racing against the clock in mind. The mundane mining portions of the game will feel slow and relaxing until something appears that makes every second count, whether that be low fuel, enemies, or the Entity. Traversal and mining should feel just *barely* not fast enough, while fighting off enemy ships and running from the enemy should feel like you’re *barely* able to survive.  
	The game exists in a 3D plane because the requirement of 


**Production Plan**
--------------------

**Engine:** Godot  
**Script:** GDScript  
**Version Control**: Github

* **Use your own** scripts, assets, artwork, or music for this project. Else have to be attributed at Credits.md
* **Low Tolerance for AI**, meaning it may be used as a tool, but you must take responsibility for your own works.  



**Roles**
---------

* **Dave (Suntyger)** - Original Idea, abandoned
* **B1773rm4n** - Everything else


**Release**
------------

Deadline will be the end of the PSX Horror Jam https://itch.io/jam/psx-horror-jam at July 11th 2026 at 1:23 AM 