/**
 * Component for meteors and meteor imitators that handles punching them, mining them, & examining them
 */

/datum/component/meteor_combat
	///If the parent object can give the meteor punching achievement
	var/achievement_enabled
	///Callback for the parent object's deflection logic
	var/datum/callback/redirection_proc
	///Callback for the parent object's destruction logic
	var/datum/callback/destruction_proc

/datum/component/meteor_combat/Initialize(datum/callback/redirection_callback, datum/callback/destruction_callback, achievement_on = FALSE)
	redirection_proc = redirection_callback
	destruction_proc = destruction_callback
	achievement_enabled = achievement_on
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attacked))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_punched))

/datum/component/meteor_combat/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/meteor_combat/proc/on_attacked(atom/owner, obj/item/attacking_item, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(attacking_item.tool_behaviour == TOOL_MINING)
		destruction_proc?.Invoke()
		playsound(parent, 'sound/effects/pickaxe/picaxe1.ogg', 50, TRUE)
		qdel(parent)
		return TRUE

	if(istype(attacking_item, /obj/item/melee/baseball_bat))
		if(user.mind?.get_skill_level(/datum/skill/athletics) < SKILL_LEVEL_EXPERT)
			to_chat(user, span_warning("\The [parent] is too heavy for you!"))
			return FALSE
		playsound(parent, 'sound/items/baseballhit.ogg', 100, TRUE)
		redirection_proc.Invoke(user)
		return TRUE

	if (istype(attacking_item, /obj/item/melee/powerfist))
		var/obj/item/melee/powerfist/fist = attacking_item
		if(!fist.tank)
			to_chat(user, span_warning("\The [fist] has no gas tank!"))
			return FALSE
		var/datum/gas_mixture/gas_used = fist.tank.remove_air(fist.gas_per_fist * 3) // 3 is HIGH_PRESSURE setting on powerfist.
		if(!gas_used || !molar_cmp_equals(gas_used.total_moles(), fist.gas_per_fist * 3))
			to_chat(user, span_warning("\The [fist] didn't have enough gas to budge \the [parent]!"))
			return FALSE
		playsound(parent, 'sound/items/weapons/resonator_blast.ogg', 50, TRUE)
		redirection_proc.Invoke(user)
		return TRUE

	return FALSE

/datum/component/meteor_combat/proc/on_punched(atom/owner, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(!isliving(user))
		return FALSE
	var/mob/living/livinguser = user

	if(livinguser.combat_mode && livinguser.mind?.get_skill_level(/datum/skill/athletics) >= SKILL_LEVEL_LEGENDARY)
		check_punch_award(livinguser)
		playsound(parent, SFX_PUNCH, 50, TRUE)
		redirection_proc.Invoke(livinguser)
		return TRUE

	return FALSE

/datum/component/meteor_combat/proc/check_punch_award(mob/user)
	if(achievement_enabled && !(astype(parent, /atom).flags_1 & ADMIN_SPAWNED_1) && isliving(user))
		user.client.give_award(/datum/award/achievement/misc/meteor_punch, user)
