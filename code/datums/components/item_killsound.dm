/datum/component/item_killsound
	/// list of allowed types, not null/empty
	var/list/allowed_mobs
	/// list of blacklisted types
	var/list/blacklisted_mobs
	var/killsound
	var/killsound_volume = 100
	/**
	 * on true will act as replacement for mob's death sound,
	 * otherwise it will just play sound on death
	 */
	var/replace_default_death_sound

/datum/component/item_killsound/Initialize(
	allowed_mobs,
	blacklisted_mobs,
	killsound,
	killsound_volume = 100,
	replace_default_death_sound = FALSE
)
	src.allowed_mobs = allowed_mobs
	src.blacklisted_mobs = blacklisted_mobs
	src.killsound = killsound
	src.killsound_volume = killsound_volume
	src.replace_default_death_sound = replace_default_death_sound

/datum/component/item_killsound/RegisterWithParent()
	var/obj/item/item_parent = parent
	RegisterSignal(item_parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/item_killsound/proc/on_attack(host, target_mob, user, params)
	SIGNAL_HANDLER

	if(!allowed_mobs || is_type_in_list(target_mob, allowed_mobs))
		if(is_type_in_list(target_mob, blacklisted_mobs))
			return
		var/mob/living/mob = target_mob
		if(replace_default_death_sound)
			mob.apply_status_effect(/datum/status_effect/replace_death_sound, 1 SECONDS, killsound)
		else
			mob.apply_status_effect(/datum/status_effect/death_sound, 1 SECONDS, killsound, killsound_volume)
