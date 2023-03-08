/datum/bloodsucker_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Little is documented about Malkavians. Complete insanity is the most common theme. \n\
		The Favorite Vassal will suffer the same fate as the Master."
	join_icon_state = "malkavian"
	join_description = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, \
		and become the enforcer of the Masquerade code."
	frenzy_stun_immune = TRUE
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY

/datum/bloodsucker_clan/malkavian/New(mob/living/carbon/user)
	. = ..()
	user.playsound_local(get_turf(user), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(user, span_hypnophrase("Welcome to the Malkavian..."))
	user.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
	user.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)
	ADD_TRAIT(user, TRAIT_XRAY_VISION, BLOODSUCKER_TRAIT)

/datum/bloodsucker_clan/malkavian/handle_clan_life(atom/source, datum/antagonist/bloodsucker/bloodsuckerdatum)
	. = ..()
	if(prob(85) || bloodsuckerdatum.owner.current.stat != CONSCIOUS || HAS_TRAIT(bloodsuckerdatum.owner.current, TRAIT_MASQUERADE))
		return
	var/message = pick(strings("malkavian_revelations.json", "revelations", "fulp_modules/strings/bloodsuckers"))
	INVOKE_ASYNC(bloodsuckerdatum.owner.current, /atom/movable/proc/say, message, , , , , , CLAN_MALKAVIAN)

/datum/bloodsucker_clan/malkavian/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/bloodsucker)
	var/mob/living/carbon/carbonowner = vassaldatum.owner.current
	carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
	carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you now suffer the same fate as your Master."))

/datum/bloodsucker_clan/malkavian/on_exit_torpor(atom/source, mob/living/carbon/user)
	user.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
	user.gain_trauma(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/bloodsucker_clan/malkavian/on_final_death(atom/source, mob/living/carbon/user)
	var/obj/item/soulstone/bloodsucker/stone = new /obj/item/soulstone/bloodsucker(get_turf(user))
	stone.capture_soul(user, forced = TRUE)
	return DONT_DUST
