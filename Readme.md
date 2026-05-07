Project Strike
==============

by New Horizon Studios


Core concept
------------

Project “Strike” is a 3rd Person 3D Sci-fi space mining game with cosmic horror undertones, where the player works for an agency called the “Experitus Exploration Agency,” navigating an expansive asteroid field to locate and extract valuable materials using their powerful mining laser.” Threats infest in the field, however, as bandit ships threaten to attack the ship and steal the valuable resources the player collects. Meanwhile, an unknown entity’s presence looms over the player, threatening to destroy their helpless vessel if they don’t return to their station in time. The ship is equipped with guns to defend itself against the bandit ships, and the player can also buy deployable turrets to assist in the defense. When the player returns to the space station, they may deposit their haul in exchange for credits, which can be spent on upgrades to increase their efficiency and chances of survival.


Vision
------
	
This project aims to create a mining game that can be both relaxing and unsettling, without being overwhelming. By introducing elements of cosmic horror, this game can provide a sense of urgency and unrest into an otherwise mundane and repetitive task, which most similar games do not do. We want players to always be on their toes and reach a point where they react to events that only their mind constructs.



Git
---

To set up Git LFS you have to do these steps after cloning:  
`git lfs install`  
`git config lfs.locksverify false`  
`git lfs pull`


Coding
------


### Creating a new scene from Template

`Template.tscn`  Instead of building that structure from scratch, **inherit** from it:

1. In the top menu **Scene**, select **New Inherited Scene**
2. Select `Scenes/Template.tscn`
3. Save the new `.tscn` file 
4. The inherited scene shows the full Template tree in the editor; nodes marked
   with a chain icon are locked to the parent scene and can only be modified
   there. Add level-specific nodes freely on top


### src

All GDScript source. Each subfolder is a self-contained category — scripts
should only reach across categories via `SignalBus` or the other Singeltons/autoloaded managers