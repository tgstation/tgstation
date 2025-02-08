/**
 * Favorite Vassal
 *
 * Gets some cool abilities depending on the Clan.
 */
/datum/antagonist/vassal/favorite
	name = "\improper Favorite Vassal"
	show_in_antagpanel = FALSE
	antag_hud_name = "vassal6"
	special_type = FAVORITE_VASSAL
	vassal_description = "The Favorite Vassal gets unique abilities over other Vassals depending on your Clan \
		and becomes completely immune to Mindshields. If part of Ventrue, this is the Vassal you will rank up."

	///The batform that some Favorite vassals get given by their Bloodsucker.
	var/datum/action/cooldown/spell/shapeshift/bat/batform
	///Bloodsucker levels, but for Vassals, used by Ventrue.
	var/vassal_level

/datum/antagonist/vassal/favorite/on_gain()
	. = ..()
	SEND_SIGNAL(master, BLOODSUCKER_MAKE_FAVORITE, src)

/datum/antagonist/vassal/favorite/on_removal()
	. = ..()
	if(batform)
		QDEL_NULL(batform)
	var/mob/living/carbon/carbonowner = owner.current
	carbonowner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
	carbonowner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/antagonist/vassal/favorite/pre_mindshield(mob/implanter, mob/living/mob_override)
	return COMPONENT_MINDSHIELD_RESISTED

///Set the Vassal's rank to their Bloodsucker level, and transfer all abilities to the Bloodsucker level.
/datum/antagonist/vassal/favorite/proc/set_vassal_level(datum/antagonist/bloodsucker/vassal_bloodsucker_datum)
	for(var/datum/action/cooldown/bloodsucker/bloodsucker_powers as anything in powers)
		powers -= bloodsucker_powers
		vassal_bloodsucker_datum.powers += bloodsucker_powers
		bloodsucker_powers.bloodsuckerdatum_power = vassal_bloodsucker_datum
	vassal_bloodsucker_datum.bloodsucker_level = vassal_level
