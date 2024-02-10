/* this component is what handles gun jamming
*/

/datum/component/gun_jammable
	var/obj/item/weapon/gun/ballistic/owner_gun
	///jamming probability
	var/jamming_prob
	//the time in deci seconds until we can jam again
	var/jam_time
	//are we jammed
	var/jammed = FALSE
	///the time we spend unjamming
	var/jam_use_time = 1 SECONDS
	///our gun jamming cd to prevent spam jammings
	COOLDOWN_DECLARE(jam_cooldown)


/datum/component/gun_jammable/Initialize(jamming_prob = 5, jam_time = 1 SECONDS, jam_use_time = 1 SECONDS)
	. = ..()
	src.jamming_prob = jamming_prob
	src.jam_time = jam_time
	src.jam_use_time = jam_use_time

/datum/component/gun_jammable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACHED, PROC_REF(handle_stat_gain))
	RegisterSignal(parent, COMSIG_ATTACHMENT_DETACHED, PROC_REF(handle_stat_loss))
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(handle_jam_attempt))
	RegisterSignal(parent, COMSIG_GUN_RACKED, PROC_REF(try_clear_jam))

/datum/component/gun_jammable/proc/handle_jam_attempt(obj/item/gun/ballistic/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER

	if(jammed)
		user.balloon_alert(user, "Gun is jammed!")
		playsound(source, source.dry_fire_sound, 30, TRUE)
		return COMPONENT_CANCEL_GUN_FIRE

	if(jamming_prob && prob(jamming_prob) && COOLDOWN_FINISHED(src, jam_cooldown))
		jammed = TRUE
		user.balloon_alert(user, "Gun has jammed!")
		playsound(source, source.dry_fire_sound, 30, TRUE)
		return COMPONENT_CANCEL_GUN_FIRE

/datum/component/gun_jammable/proc/try_clear_jam(obj/item/gun/ballistic/source, mob/user)
	if(jammed && do_after(user, jam_use_time, parent))
		COOLDOWN_START(src, jam_cooldown, jam_time)
		user.balloon_alert(user, "Gun jam has been cleared!")
		jammed = FALSE

/datum/component/gun_jammable/proc/handle_stat_gain(atom/source, obj/item/attachment/attached)
	SIGNAL_HANDLER
	jamming_prob *= attached.misfire_multiplier
	jam_use_time /= attached.ease_of_use

/datum/component/gun_jammable/proc/handle_stat_loss(atom/source, obj/item/attachment/attached)
	SIGNAL_HANDLER
	jamming_prob /= attached.misfire_multiplier
	jam_use_time *= attached.ease_of_use
