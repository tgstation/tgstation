

**Basics:**

**What is Linda?**

Linda is a new invironmental air system, who will replace the current system, called FEA. The goals of Linda is to make a less CPU intensive system, a system that will be easy to see what is going on in-game with debug options and start opening ways for new gases. Linda also includes a lot of "bugfixes", they aren't actually bugfixes because it's just a complete new system, but it works the same. Responses are faster too.

**How does this affects gameplay?**

Mostly players will stop experimenting the bugs of FEA, for example, breaking a window and having to wait 20 seconds until it starts draining air, flamethrowers not working, superconductivity being awful, suddenly getting a room filled of plasma because of the air group breaking, breathing toxins when there isn't any visible plasma. And of course, less lag.

**How does it work?**

It's quite simple actually, if the mapping is good (I'll get into this later), all the turfs will be asleep and not making any air calculations. All turf changes and a selected group of objects are in charge to activate the turfs, for example, a door opening, windows rotating, an open canister, etc. When a turf is activated, it will compare their own air with the adjacent turfs, if there's a difference, they will start sharing.

**Images of the activation process:**

http://imgur.com/dO8GJd4,FPwah51,p8EF3nK,l8pUUNf,ApEQiAQ,CgnwOBV

**Note on mapping:**

About mapping, when the server starts (before the timer to start the round even begins), all turfs calculate if there's a difference with their adjacent turfs, if there it is, the turf will be activated before the round starts. This should not happen unless the mapper is doing it on purpose. 

To easily check the number of active turfs -as an admin-, on the status tab, on the air line. It should be # 0 if everything goes okay. This is also a good way to help mappers.


**Interaction as a coder:**

Okay, first, lets talk on how you should interact with linda.

When an object changes the air of a turf, by removing the air, merging it, adding, etc. The object must activate the turf, so it can compare with the adjacent turfs and start sharing if needed. This is really really simple. You just need to call for this proc:
src.air_update_turf()

Just like that, easy, eh?

Now, it's a bit different with windows and airlocks, because these must update the bitflag of the adjacent turfs, so you'll have to do this:
src.air_update_turf(1)

Is that simple, you don't have to worry about anything else. One of the things that you HAVE to do, is to call this proc on the move() of your object, like this:
Move()
src.air_update_turf(1)
..()
src.air_update_turf(1)

It might not be the best thing on the world, but (usually because of the singularity), objects can move. And this can fuck up the adjacent turfs bitflag.

CanPass() is no longer used for atmos, now it uses CanAtmosPass(var/turf/T) and BlockSuperconductivity() for superconductivity. As the names of the proc say, if you return 1 in CanAtmosPass(var/turf/T), the object will allow atmos to pass and if you return 0 in BlockSuperconductivity() the object will not stop superconductivity. 

If you're working with direction based objects (like windows or firelocks) make sure to include the proper checks (ONLY IN CanAtmosPass(var/turf/T)), search on the code for examples.

BlockSuperconductivity() does NOT have an argument because it's only called when the CanAtmosPass() fails, so the direction is already handled. Don't add directional checks there.

**Advanced:**

Well, if you already read the previous walls of texts, this might be a little bit easier.

**Server Setup:**

When the server starts, setup_allturfs() is called when the controller is created. This proc calculates the adjacent turfs bitflag and the superconductivity bitflag of all turfs and activates turfs if there's a difference. These activated turfs will start sharing once the round starts.

The activated turfs are saved in a list of the air controlled called active_turfs. This list ONLY includes simulated turfs that have air (walls do not have air)

**Controller ticking**

The air controller will call the process_cell() proc of all the turfs in that list for each controller tick.

The process_cell() proc of turfs will be the one handling shares, compares and group creations.

This proc will check if the four turfs next to the src are included on the adjacent turf bitlfag, if they are, a huge chunk of code will trigger, the "backbone of linda"

This will check if the enemy turf is simulated or not, if they are active, if they have a group, if the src has a group. It will merge groups if both turfs have groups. This is of course handled on a "tree" way so it doesn't lag like a motherfucker.

These are the different cases:

Simulated enemy turf:

* src has a group. The enemy is not active. A compare() is called, on success, the enemy is merged to the group and they share air.
* src has a group. The enemy is active but doesn't have a group. The enemy is merged to the group and they share air.
* src has a group. The enemy is active and does have a group. The smallest group is merged to the bigger one and they both share air.
* src doesn't have a group. The enemy is not active. A compare() is called, on success, a new group is generated and they share air.
* src doesn't have a group. The enemy is active but doesn't have a group. They generate a new group and share air.
* src doesn't have a group. The enemy is active and does have a group. The smallest group is merged to the bigger one and the both share air.
* If the enemy turf is not simulated, the src will call a special compare proc for unsimulated turfs, on success, it will mimic a share call.

When this group handling finishes, if the src doesn't have a group and didn't mimic a share with a unsimulated turf, it will be removed from the active_turfs list. Simple!

**What are groups?**

What is a group? When all the turfs of a group share less than a certain number (MINIMUM_AIR_TO_SUSPEND), the group will start a cooldown, if not, the cooldown will be reset to 0. If this behaviour stays for 10 ticks, the group will compare all the turfs of itself, if there's a difference, the group will merge all turfs and make them have the same amount of air. 

This is to avoid having a room with high pressure from one side and low pressure on the other side. After this merging, the group will wait for one more tick, if the breakdown cooldown is not reseted, all the turfs will be deactivated and the group will be deleted (garbage collected actually)

Groups are also deleted if an object calls for src.air_update_turf(1). But all turfs stay active.
If the temperature of a turf is really high on the process_cell(), it will check if it should spawn a hotspot and the turf will be included to the superconductivity list. The air controller owns a list of turfs for superconductivitiy. Walls can be included on this list.

**Superconductivity and adjacency**

The superconductivity proc is very similar to the process_cell(), it will check for all the four turfs next to the src and see if they are included on the superconductivity bitflag. After this, it only shares temperature and activates turfs.

The adjacent turf bitflag and the superconductivity bitflags are set on the CalculateAdjacentTurfs() proc. This call will simply set the bitflags of the turf and modify the proper value of the bitflags of the adjacent turfs. CanAtmosPass(var/turf/T) and BlockSuperconductivity() procs are called around here, on all the objects of the turfs.

