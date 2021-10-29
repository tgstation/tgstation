/obj/effect/proc_holder/spell/pointed/celeritas
	name = "Celeritas"
	desc = "Swap places with a target within range."
	school = "transmutation"
	charge_max = 200
	cooldown_min = 60
	clothes_req = FALSE
	invocation_type = NONE
	action_icon_state = "spellcard"
	range = 10
	message = "The world rapidly shift!"

/obj/effect/proc_holder/spell/pointed/celeritas/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	user.emote("snap")
	playsound(user, 'sound/weapons/punchmiss.ogg', 75, TRUE)
	var/turf/targeted_turf = get_turf(target)
	var/turf/user_turf = get_turf(user)

	new /obj/effect/temp_visual/small_smoke/halfsecond(user.drop_location())
	new /obj/effect/temp_visual/small_smoke/halfsecond(targeted_turf)
	do_teleport(user, targeted_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	do_teleport(target, user_turf, 0, no_effects = TRUE, channel= TELEPORT_CHANNEL_MAGIC)


/obj/effect/proc_holder/spell/pointed/celeritas/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to swap with [target]!</span>")
		return FALSE
	return TRUE
