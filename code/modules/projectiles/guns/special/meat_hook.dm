#define TRAIT_HOOKED "hooked"

/// Meat Hook
/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	inhand_icon_state = "hook"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	pinless = TRUE
	max_charges = 1
	item_flags = NEEDS_PERMIT | NOBLUDGEON
	sharpness = SHARP_POINTY
	force = 18
	antimagic_flags = NONE

/obj/item/gun/magic/hook/shoot_with_empty_chamber(mob/living/user)
	balloon_alert(user, "not ready yet!")

/obj/item/gun/magic/hook/can_trigger_gun(mob/living/user, akimbo_usage) // This isn't really a gun, so it shouldn't be checking for TRAIT_NOGUNS, a firing pin (pinless), or a trigger guard (guardless)
	if(akimbo_usage)
		return FALSE //this would be kinda weird while shooting someone down.
	return TRUE

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/projectile/hook
	caliber = CALIBER_HOOK
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect

/obj/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 20
	stamina = 20
	armour_penetration = 60
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	var/datum/beam/chain
	var/knockdown_time = (0.5 SECONDS)

/obj/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", emissive = FALSE)
	..()
	//TODO: root the firer until the chain returns

/obj/projectile/hook/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!ismovable(target))
		return

	var/atom/movable/victim = target
	if(victim.anchored || HAS_TRAIT_FROM(victim, TRAIT_HOOKED, REF(firer)))
		return

	victim.visible_message(span_danger("[victim] is snagged by [firer]'s hook!"))

	var/datum/hook_and_move/puller = new
	puller.register_victim(firer, victim, get_turf(firer))

	if (isliving(victim))
		var/mob/living/fresh_meat = target
		fresh_meat.Knockdown(knockdown_time)

	//TODO: keep the chain beamed to victim
	//TODO: needs a callback to delete the chain

/obj/projectile/hook/Destroy()
	qdel(chain)
	return ..()

/// Lightweight datum that just handles moving a target for the hook.
/// For the love of God, do not use this outside this file.
/datum/hook_and_move
	/// How many steps we force the victim to take per tick
	var/steps_per_tick = 5
	/// String to the REF() of the dude that fired us so we can ensure we always cleanup our traits
	var/firer_ref_string = null
	/// Weakref to the victim we are dragging
	var/datum/weakref/victim_ref = null
	/// Destination that the victim is heading towards.
	var/datum/weakref/destination_ref = null
	/// The last time our movement fired.
	var/last_movement = 0

/// Uses fastprocessing to move our victim to the destination at a rather fast speed.
/// TODO is to replace this with a movement loop, but the visual effects of this are pretty scuffed so we're just reliant on this old method for now :(
/datum/hook_and_move/proc/register_victim(atom/movable/firer, atom/movable/victim, atom/destination)
	firer_ref_string = REF(firer)
	ADD_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)

	destination_ref = WEAKREF(destination)
	victim_ref = WEAKREF(victim)

	START_PROCESSING(SSfastprocess, src)

/// Cancels processing and removes the trait from the victim.
/datum/hook_and_move/proc/end_movement()
	STOP_PROCESSING(SSfastprocess, src)
	var/atom/movable/victim = victim_ref?.resolve()
	if(QDELETED(victim))
		return

	REMOVE_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)
	victim_ref = null
	destination_ref = null
	qdel(src)

/datum/hook_and_move/process(seconds_per_tick)
	var/atom/movable/victim = victim_ref?.resolve()
	var/atom/destination = destination_ref?.resolve()
	if(QDELETED(victim) || QDELETED(destination))
		end_movement(victim)
		return

	var/steps_to_take = round(steps_per_tick * (world.time - last_movement))
	if(steps_to_take <= 0)
		return

	var/movement_result = attempt_movement(victim, destination)
	if(!movement_result || (victim.loc == destination.loc)) // either we failed our movement or our mission is complete
		end_movement()

/// Attempts to move the victim towards the destination. Returns TRUE if we do a successful movement, FALSE otherwise.
/// second_attempt is a boolean to prevent infinite recursion.
/datum/hook_and_move/proc/attempt_movement(atom/movable/subject, atom/target, second_attempt = FALSE)
	var/actually_moved = FALSE
	if(!second_attempt)
		actually_moved = step_towards(subject, target)

	if(actually_moved)
		return TRUE

	// alright now the code fucking sucks
	var/subject_x = subject.x
	var/subject_y = subject.y
	var/target_x = target.x
	var/target_y = target.y

	//If we're going x, step x
	if((target_x > subject_x) && step(subject, EAST))
		actually_moved = TRUE
	else if((target_x < subject_x) && step(subject, WEST))
		actually_moved = TRUE

	if(actually_moved)
		return TRUE

	//If the x step failed, go y
	if((target_y > subject_y) && step(subject, NORTH))
		actually_moved = TRUE
	else if((target_y < subject_y) && step(subject, SOUTH))
		actually_moved = TRUE

	if(actually_moved)
		return TRUE

	// if we fail twice, abort. otherwise queue up the second attempt.
	if(second_attempt)
		return FALSE

	return attempt_movement(subject, target, second_attempt = TRUE)

//just a nerfed version of the real thing for the bounty hunters.
/obj/item/gun/magic/hook/bounty
	name = "hook"
	ammo_type = /obj/item/ammo_casing/magic/hook/bounty

/obj/item/ammo_casing/magic/hook/bounty
	projectile_type = /obj/projectile/hook/bounty

/obj/projectile/hook/bounty
	damage = 0
	stamina = 40

#undef TRAIT_HOOKED
