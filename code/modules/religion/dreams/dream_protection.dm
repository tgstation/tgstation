/datum/religion_rites/dream_protection
	name = "Dream Protection"
	desc = "Bless you and all of your followers with protection in their slumber, \
		granting resistance to damage while asleep, which is further increased while dreaming."
	favor_cost = 200
	rite_flags = RITE_ONE_TIME_USE | RITE_AUTO_DELETE

/datum/religion_rites/dream_protection/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	if(!istype(GLOB.religious_sect, /datum/religion_sect/dreams))
		return

	var/datum/religion_sect/dreams/sect = GLOB.religious_sect
	sect.dream_protection = TRUE

	for(var/mob/living/follower as anything in GLOB.mob_living_list)
		if(follower.mind?.holy_role)
			follower.apply_status_effect(/datum/status_effect/dream_protection)

/datum/status_effect/dream_protection
	id = "dream_protection"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

/datum/status_effect/dream_protection/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(modify_damage))
	ADD_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/dream_protection/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/dream_protection/proc/modify_damage(mob/living/source, list/damage_mods, ...)
	SIGNAL_HANDLER
	if(owner.IsSleeping())
		damage_mods += 0.75
	if(HAS_TRAIT(owner, TRAIT_DREAMING))
		damage_mods += 0.75

/datum/status_effect/dream_protection/get_examine_text()
	if(owner.IsSleeping() || HAS_TRAIT(owner, TRAIT_DREAMING))
		return "A soft cyan glow envelops [owner.p_them()], deflecting attacks slightly."
