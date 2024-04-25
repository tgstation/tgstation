///A very, VERY large crab.
/mob/living/basic/mining/megafauna/infernal_gigasnapper
	name = "infernal gigasnapper"
	desc = "\"Magmacarcinidae gigantus\", also known as a very, very large crab. Whether the presence of crustaceans is a cause or effect of this behemoth is uncertain."
	health = 1000
	maxHealth = 1000

	icon = 'icons/mob/simple/lavaland/gigasnapper/infernal_gigasnapper.dmi'
	icon_state = "crab"
	pixel_x = -32
	pixel_y = -16

	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_SPECIAL

	//// actions

	/// side charging attack (and general collision logic)
	var/datum/action/cooldown/mob_cooldown/crab_collide/collide_action = /datum/action/cooldown/mob_cooldown/crab_collide

/mob/living/basic/mining/megafauna/infernal_gigasnapper/Initialize(mapload)
	. = ..()
	collide_action = new collide_action(src)
	collide_action.Grant(src)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/dir_restricted_movement, (EAST | WEST))

/// returns all the turfs that the crab sprite touches
/mob/living/basic/mining/megafauna/infernal_gigasnapper/proc/get_crab_turfs(include_self_turf = FALSE) as /list
	var/list/dirs = list(NORTH, NORTHEAST, EAST, WEST, NORTHWEST)
	var/list/turfs = list()
	for(var/dir in dirs)
		var/turf/stepped = get_step(src, dir)
		if(stepped)
			turfs += stepped
	if(include_self_turf)
		turfs += get_turf(src)
	return turfs
