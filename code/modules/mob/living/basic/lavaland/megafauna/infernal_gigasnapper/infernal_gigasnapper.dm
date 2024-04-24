


///A very, VERY large crab.
/mob/living/basic/mining/megafauna/infernal_gigasnapper
	name = "infernal gigasnapper"
	desc = "\"Magmacarcinidae gigantus\", also known as a very, very large crab. Whether the presence of crustaceans is a cause or effect of this behemoth is uncertain."
	health = 1000
	maxHealth = 1000

	icon = 'icons/mob/simple/lavaland/infernal_gigasnapper.dmi'
	icon_state = "crab"
	pixel_x = -32
	pixel_y = -16

	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_SPECIAL

	//// actions
	/// side charging attack
	var/datum/action/cooldown/mob_cooldown/side_charge/side_charge_action

/mob/living/basic/mining/megafauna/infernal_gigasnapper/Initialize(mapload)
	. = ..()
	side_charge_action = new side_charge_action(src)
	AddElement(/datum/element/x_restricted_movement)

/mob/living/basic/mining/megafauna/infernal_gigasnapper/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/list/crab_turfs = get_crab_turfs()
	for(var/turf/crab_turf as anything in crab_turfs)
		for(var/mob/living/collided in crab_turf.contents)
			if(side_charge_action.charge_dir)
				side_charge_action.charge_collide(src, collided)
			else
				regular_collide(collided)
		if(side_charge_action.charge_dir)
			side_charge_action.charge_collide(crab_turf)
		else
			regular_collide(collided)

/// gets all the turfs that the crab sprite touches
/mob/living/basic/mining/megafauna/infernal_gigasnapper/proc/get_crab_turfs() as /list
	var/list/dirs = list(NORTH, NORTHEAST, EAST, WEST, NORTHWEST)
	var/list/turfs = list()
	for(dir in dirs)
		turfs += get_step(src, dir)
	return turfs

/// non-charging collision logic (see charge action for charging collision).
/// generally similar but weaker than normal charges.
/mob/living/basic/mining/megafauna/infernal_gigasnapper/proc/regular_collide(atom/collided)
