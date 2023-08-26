## Title: <!--Title of your addition-->

<!-- uppercase, underscore_connected name of your module, that you use to mark files-->
MODULE ID: JOB_XP 

### Description:

This PR adds an xp system for each job in the game aswell as the framework for job milestones

Milestone Guide: Milestones are sorted by key_id where key_id is equal to a jobs title(use JOB_ Helper for this)
There are than 2 milestone lists you can add items to, the first of which is a permenant fixture like a loadout item, the second of which is the in_round_list which takes an item and that item can be redeemed each round as a reward.
to write one of these simply create a list like so:
	list(
		"{level}" = {path},
	)
Note that the level is in string format. Loadout items should have the loadout path, round items should have the item id.
### Master file additions

- N/A
<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->
<!-- Orignal Coders -->
Made by Dwasint
<!-- Orignal Coders -->
