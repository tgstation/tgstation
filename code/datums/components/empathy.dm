// Empath quirk component, it's a component because it can be applied in ways that don't give you the quirk. (For health analyzer purposes)

/datum/component/empathy

	dupe_mode = COMPONENT_DUPE_SOURCES

	// Whether or not we should get scared the next time we see an evil person.
	var/seen_it = FALSE

	// What sort of information we can glean from examining someone
	var/visible_info = ALL

	// Whether or not we can use empathy on ourselves
	var/self_empath = FALSE

	// Whether or not empathy works on humans playing dead
	var/sense_dead = FALSE

	// Whether or not we can tell if people whisper under their mask from far away (We can't hear what they said, we just know they said something)
	var/sense_whisper = TRUE

	// Whether or not we can be smited by someoneone with the evil trait using the mending touch mutation
	var/smite_target = TRUE

/datum/component/empathy/Initialize(seen_it = FALSE, visible_info = ALL, self_empath = FALSE, sense_dead = FALSE, sense_whisper = TRUE, smite_target = TRUE)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.seen_it = seen_it
	src.visible_info = visible_info
	src.self_empath = self_empath
	src.sense_dead = sense_dead
	src.sense_whisper = sense_whisper
	src.smite_target = smite_target
	if(sense_whisper)
		ADD_TRAIT(parent, TRAIT_SEE_MASK_WHISPER, REF(src))

/datum/component/empathy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CARBON_MID_EXAMINE, PROC_REF(get_empath_info))
	RegisterSignal(parent, COMSIG_ON_LAY_ON_HANDS, PROC_REF(on_hands_laid))

/datum/component/empathy/proc/get_empath_info(datum/source, mob/living/target, list/examine_list)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	if(HAS_TRAIT(target, TRAIT_FAKEDEATH))
		if(sense_dead)
			examine_list += "Something about this dead body doesn't look right..."
		else
			return
	var/mob/living/living_parent = parent
	if(target == living_parent && !self_empath)
		return
	var/t_They = target.p_They()
	var/t_their = target.p_their()
	var/t_Their = target.p_Their()
	var/t_are = target.p_are()
	if((visible_info & EMPATH_SEE_COMBAT) && target.combat_mode)
		examine_list += "[t_They] seem[p_s()] to be on guard."
	if((visible_info & EMPATH_SEE_OXY) && target.get_oxy_loss() >= 10)
		examine_list += "[t_They] seem[p_s()] winded."
	if((visible_info & EMPATH_SEE_TOX) && target.get_tox_loss() >= 10)
		examine_list += "[t_They] seem[p_s()] sickly."
	if((visible_info & EMPATH_SEE_SANITY) && target.mob_mood.sanity <= SANITY_DISTURBED)
		examine_list += "[t_They] seem[p_s()] distressed."
	if((visible_info & EMPATH_SEE_BLIND) && target.is_blind())
		examine_list += "[t_They] appear[p_s()] to be staring off into space."
	if((visible_info & EMPATH_SEE_DEAF) && HAS_TRAIT(target, TRAIT_DEAF))
		examine_list += "[t_They] appear[p_s()] to not be responding to noises."
	if((visible_info & EMPATH_SEE_HOT) && target.bodytemperature > target.get_body_temp_heat_damage_limit())
		examine_list += "[t_They] [t_are] flushed and wheezing."
	if((visible_info & EMPATH_SEE_COLD) && target.bodytemperature < target.get_body_temp_cold_damage_limit())
		examine_list += "[t_They] [t_are] shivering."
	if((visible_info & EMPATH_SEE_EVIL) && HAS_TRAIT(target, TRAIT_EVIL))
		examine_list += "[t_Their] eyes radiate with a unfeeling, cold detachment. There is nothing but darkness within [t_their] soul."
		if(living_parent.mind?.holy_role >= HOLY_ROLE_PRIEST)
			examine_list += span_warning("PERFECT FOR SMITING!!")
		else if(!seen_it)
			seen_it = TRUE
			living_parent.add_mood_event("encountered_evil", /datum/mood_event/encountered_evil)
			living_parent.set_jitter_if_lower(15 SECONDS)

/datum/component/empathy/proc/on_hands_laid(datum/source, mob/living/carbon/smiter)
	SIGNAL_HANDLER
	if(iscarbon(parent))
		var/mob/living/carbon/carbon_parent = parent
		if(carbon_parent.mob_biotypes & MOB_UNDEAD)
			return FALSE
	if(smite_target && HAS_TRAIT(smiter, TRAIT_EVIL))
		return TRUE
	return FALSE

/datum/component/empathy/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CARBON_MID_EXAMINE)

/datum/component/empathy/Destroy(force = FALSE)
	REMOVE_TRAIT(parent, TRAIT_SEE_MASK_WHISPER, REF(src))
	return ..()
