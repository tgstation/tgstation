/datum/team/overthrow
	name = "overthrow" // The team name is set on creation by the leader.
	member_name = "syndicate agent"
	var/hud_entry_num // A number holding the hud's index inside 'huds' global list. Gets set on hud update, if a hud doesn't exist already. Must be a number, otherwise BYOND shits up with assoc lists and everything goes to hell.

/datum/team/overthrow/Destroy()
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[hud_entry_num]
	GLOB.huds -= GLOB.huds[hud_entry_num]
	qdel(overthrowhud)
	. = ..()

/datum/team/overthrow/proc/create_objectives()
	// Heads objective
	var/datum/objective/ovethrow_heads/heads = new()
	heads.team = src
	heads.find_target()
	objectives += heads
	// AI objective
	var/datum/objective/overthrow_AI/AI = new()
	AI.team = src
	objectives += AI
	// Target objective
	var/datum/objective/overthrow_target/target = new()
	target.team = src
	target.find_target()
	objectives += target