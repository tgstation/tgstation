/// A global list of Bloodsucker antag datums that have broken the Masquerade
GLOBAL_LIST_EMPTY(masquerade_breakers)

/datum/bloodsucker_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "The history of the Malkavian clan is not well known, even to most modern Malkavians. \n\
		Complete insanity and an almost puritanical devotion to the Masquerade are the most common themes throughout the literature. \n\
		Their favorite vassal suffers from insanity just as they do."
	join_icon_state = "malkavian"
	join_description = "Become completely insane, travel through tears in reality, ramble in whispers constantly, \
		and become an enforcer of the Masquerade."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/malkavian/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/malkavian/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/malkavian/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE, PROC_REF(on_bloodsucker_broke_masquerade))
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)
	var/mob/living/carbon/carbon_owner = bloodsuckerdatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	owner_datum.owner.current.update_sight()

	for(var/datum/antagonist/bloodsucker/unmasked in GLOB.masquerade_breakers)
		if(unmasked.owner.current && unmasked.owner.current.stat != DEAD)
			on_bloodsucker_broke_masquerade(unmasked)

	bloodsuckerdatum.owner.current.playsound_local(get_turf(bloodsuckerdatum.owner.current), 'sound/music/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(bloodsuckerdatum.owner.current, span_hypnophrase("Welcome to the Malkavian..."))

/datum/bloodsucker_clan/malkavian/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)
	var/mob/living/carbon/carbon_owner = bloodsuckerdatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	bloodsuckerdatum.owner.current.update_sight()
	return ..()

/datum/bloodsucker_clan/malkavian/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	if(prob(85) || bloodsuckerdatum.owner.current.stat != CONSCIOUS || HAS_TRAIT(bloodsuckerdatum.owner.current, TRAIT_MASQUERADE))
		return
	var/message = pick(strings("malkavian_revelations.json", "revelations", "modular_meta/features/antagonists/strings/bloodsuckers"))
	INVOKE_ASYNC(bloodsuckerdatum.owner.current, TYPE_PROC_REF(/atom/movable, say), message, , , , , , CLAN_MALKAVIAN)

/datum/bloodsucker_clan/malkavian/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	var/mob/living/carbon/carbonowner = vassaldatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you now suffer the same fate as your master."))

/datum/bloodsucker_clan/malkavian/on_exit_torpor(datum/antagonist/bloodsucker/source)
	var/mob/living/carbon/carbonowner = bloodsuckerdatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/bloodsucker_clan/malkavian/on_final_death(datum/antagonist/bloodsucker/source)
	var/obj/item/soulstone/bloodsucker/stone = new /obj/item/soulstone/bloodsucker(get_turf(bloodsuckerdatum.owner.current))
	stone.init_shade(victim = bloodsuckerdatum.owner.current, message_user = FALSE)
	return DONT_DUST

/datum/bloodsucker_clan/malkavian/proc/on_bloodsucker_broke_masquerade(datum/antagonist/bloodsucker/masquerade_breaker)
	SIGNAL_HANDLER
	to_chat(bloodsuckerdatum.owner.current, span_userdanger("[masquerade_breaker.owner.current] has broken the Masquerade! Ensure [masquerade_breaker.owner.current.p_they()] [masquerade_breaker.owner.current.p_are()] eliminated at all costs!"))
	var/datum/objective/assassinate/masquerade_objective = new()
	masquerade_objective.target = masquerade_breaker.owner.current
	masquerade_objective.objective_name = "Clan Objective"
	masquerade_objective.explanation_text = "Ensure [masquerade_breaker.owner.current], who has broken the Masquerade, succumbs to Final Death."
	bloodsuckerdatum.objectives += masquerade_objective
	bloodsuckerdatum.owner.announce_objectives()
