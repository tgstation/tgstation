#define TRAIT_HOOKED "hooked"
#define IMMOBILIZATION_TIMER (0.25 SECONDS) //! How long we immobilize the firer after firing - we do cancel the immobilization early if nothing is hit.

/// Meat Hook
/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	inhand_icon_state = "hook"
	icon_angle = 45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/items/weapons/batonextend.ogg'
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
	if(HAS_TRAIT(user, TRAIT_IMMOBILIZED))
		return FALSE
	return TRUE

/obj/item/gun/magic/hook/suicide_act(mob/living/user)
	var/obj/item/bodypart/head/removable = user.get_bodypart(BODY_ZONE_HEAD)
	if(isnull(removable))
		user.visible_message(span_suicide("[user] stuffs the chain of the [src] down the hole where their head should be! It looks like [user.p_theyre()] trying to commit suicide!"))
		return OXYLOSS

	playsound(get_turf(src), fire_sound, 50, TRUE, -1)
	user.visible_message(span_suicide("[user] is using the [src] on their [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(get_turf(src), 'sound/items/weapons/bladeslice.ogg', 70)
	removable.dismember(silent = FALSE)
	return BRUTELOSS

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
	/// The chain we send out while we are in motion, referred to as "initial" to not get confused with the chain we use to reel the victim in.
	var/datum/beam/initial_chain

/obj/projectile/hook/fire(setAngle)
	if(firer)
		initial_chain = firer.Beam(src, icon_state = "chain", emissive = FALSE)
		ADD_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))
		addtimer(TRAIT_CALLBACK_REMOVE(firer, TRAIT_IMMOBILIZED, REF(src)), IMMOBILIZATION_TIMER) // safety if we miss, if we get a hit we stay immobilized
	return ..()

/obj/projectile/hook/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!ismovable(target))
		return

	var/atom/movable/victim = target
	if(victim.anchored || HAS_TRAIT_FROM(victim, TRAIT_HOOKED, REF(firer)))
		return

	victim.visible_message(span_danger("[victim] is snagged by [firer]'s hook!"))

	var/datum/hook_and_move/puller = new
	puller.begin_pulling(firer, victim, get_turf(firer))
	REMOVE_TRAIT(firer, TRAIT_IMMOBILIZED, REF(src))

/obj/projectile/hook/Destroy(force)
	QDEL_NULL(initial_chain)
	return ..()

/// Lightweight datum that just handles moving a target for the hook.
/// For the love of God, do not use this outside this file.
/datum/hook_and_move
	/// Weakref to the victim we are dragging
	var/datum/weakref/victim_ref = null
	/// Weakref of the destination that the victim is heading towards.
	var/datum/weakref/destination_ref = null
	/// Weakref to the firer of the hook
	var/datum/weakref/firer_ref = null
	/// String to the REF() of the dude that fired us so we can ensure we always cleanup our traits
	var/firer_ref_string = null

	/// The last time our movement fired.
	var/last_movement = 0
	/// The chain beam we currently own.
	var/datum/beam/return_chain = null

	/// How many steps we force the victim to take per tick
	var/steps_per_tick = 5
	/// How long we knockdown the victim for.
	var/knockdown_time = (0.5 SECONDS)

	/// List of traits that prevent the user from moving. More restrictive than attempting to fire the hook by design.
	var/static/list/prevent_movement_traits = list(
		TRAIT_IMMOBILIZED,
		TRAIT_UI_BLOCKED,
	)

/datum/hook_and_move/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(return_chain)
	return ..()

/// Uses fastprocessing to move our victim to the destination at a rather fast speed.
/datum/hook_and_move/proc/begin_pulling(atom/movable/firer, atom/movable/victim, atom/destination)
	return_chain = firer.Beam(victim, icon_state = "chain", emissive = FALSE)

	firer_ref_string = REF(firer)
	ADD_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)
	firer.add_traits(prevent_movement_traits, REF(src))
	if(isliving(victim))
		var/mob/living/fresh_meat = victim
		fresh_meat.Knockdown(knockdown_time)

	destination_ref = WEAKREF(destination)
	victim_ref = WEAKREF(victim)
	firer_ref = WEAKREF(firer)

	START_PROCESSING(SSfastprocess, src)

/// Cancels processing and removes the trait from the victim.
/datum/hook_and_move/proc/end_movement()
	var/atom/movable/firer = firer_ref?.resolve()
	if(!QDELETED(firer))
		firer.remove_traits(prevent_movement_traits, REF(src))

	var/atom/movable/victim = victim_ref?.resolve()
	if(!QDELETED(victim))
		REMOVE_TRAIT(victim, TRAIT_HOOKED, firer_ref_string)

	qdel(src)

/datum/hook_and_move/process(seconds_per_tick)
	var/atom/movable/victim = victim_ref?.resolve()
	var/atom/destination = destination_ref?.resolve()
	if(QDELETED(victim) || QDELETED(destination))
		end_movement()
		return

	var/steps_to_take = round(steps_per_tick * (world.time - last_movement))
	if(steps_to_take <= 0)
		return

	var/movement_result = attempt_movement(victim, destination)
	if(!movement_result || (victim.loc == destination.loc)) // either we failed our movement or our mission is complete
		end_movement()

/// Attempts to move the victim towards the destination. Returns TRUE if we do a successful movement, FALSE otherwise.
/// second_attempt is a boolean to prevent infinite recursion.
/// If this whole series of events wasn't reliant on SSfastprocess firing as fast as it does, it would have been more useful to make this a move loop datum. But, we need the speed.
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

/// Debug hook for fun (AKA admin abuse). doesn't do any more damage or anything just lets you wildfire it.
/obj/item/gun/magic/hook/debug
	name = "super meat hook"
	max_charges = 100
	recharge_rate = 1

#undef TRAIT_HOOKED
#undef IMMOBILIZATION_TIMER
