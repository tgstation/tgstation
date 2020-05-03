
/**
  # unwieldy.dm
  *
  * An element that crudely simulates swinging a big heavy weapon. Meant to be used with 2h weapons.
  *
  * When you swing an unwieldy weapon at a mob, it checks the turf either clockwise or counterclockwise from you to your target based on which hand the weapon was in, and then switches hands.
  * If there's a solid or dense atom on the checked turf, it interrupts your swing, and you have a short immobilize or stun (half a second) as a result.
*/
/datum/element/unwieldy
	element_flags = ELEMENT_DETACH

/datum/element/unwieldy/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, .proc/swing)

/datum/element/unwieldy/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_PRE_ATTACK))
	return ..()

/datum/element/unwieldy/proc/swing(obj/item/I, atom/intended_target, mob/living/user)
	if(!iscarbon(user) || !ismob(intended_target))
		return

	var/mob/living/carbon/C = user
	// if we're checking the clockwise or the counterclockwise tile from us to our target
	var/clockwise = (C.active_hand_index % 2 == 0) // right hand means we're swinging counterclockwise, so check clockwise tile
	var/dir = dir2angle(get_dir(user, intended_target))

	if(clockwise)
		dir = (dir + 45) % 360
	else
		dir = (dir + 315) % 360

	var/turf/tile_check = get_step(user, angle2dir(dir))
	var/atom/obstacle

	if(tile_check.density)
		obstacle = tile_check
	else
		var/highest_layer = 0
		for(var/i in tile_check)
			var/atom/thing = i
			if(thing.density && thing.layer > highest_layer)
				obstacle = thing
				highest_layer = thing.layer

	if(obstacle)
		SEND_SIGNAL(I, COMSIG_UNWIELDY_BONK, user, intended_target, obstacle)
		return COMPONENT_NO_ATTACK
