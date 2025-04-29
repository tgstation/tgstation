/// how much favor is gained when someone is deaconized
#define DEACONIZE_FAVOR_GAIN 300

/**
 * Deaconizing
 * Makes the person holy, and if crusader_code is set then they must also follow the honorbound code, but
 * earns the church favor, convincing others to uphold the code is not easy.
 * Non-crusader variant allows the Chaplain to grant one non-holy member the ability to use
 * Chaplain equipment, such as bibles, for blessing water, at the cost of being one-time use.
 */
/datum/religion_rites/deaconize
	name = "Join Crusade"
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
	They will become honorbound like you, and you will gain a massive favor boost!"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"A good, honorable crusade against evil is required.",
		"We need the righteous ...",
		"... the unflinching ...",
		"... and the just.",
		"Sinners must be silenced ...",
	)
	invoke_msg = "... And the code must be upheld!"

	rite_flags = RITE_ALLOW_MULTIPLE_PERFORMS

	///Boolean on whether or not the new deacon will have to follow a crusader code, used in flavortext & granting favor.
	var/crusader_code = TRUE
	///The person currently being deaconized.
	var/mob/living/carbon/human/potential_deacon

/datum/religion_rites/deaconize/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the [movable_reltool]!"))
		return FALSE
	for(var/mob/living/carbon/human/possible_deacons in movable_reltool.buckled_mobs)
		if(possible_deacons.stat != CONSCIOUS)
			to_chat(user, span_warning("[possible_deacons] needs to be alive and conscious to join the crusade!"))
			return FALSE
		if(crusader_code && (TRAIT_GENELESS in possible_deacons.dna.species.inherent_traits))
			to_chat(user, span_warning("This species disgusts [GLOB.deity]! They would never be allowed to join the crusade!"))
			return FALSE
		if(possible_deacons.mind && possible_deacons.mind.holy_role)
			to_chat(user, span_warning("[possible_deacons] is already a member of the religion!"))
			return FALSE
		//no one invited or this is not the invited person
		if(!potential_deacon || (possible_deacons != potential_deacon))
			INVOKE_ASYNC(src, PROC_REF(invite_deacon), possible_deacons)
			if(crusader_code)
				to_chat(user, span_notice("They have been given the option to consider joining the crusade against evil. Wait for them to decide and try again."))
			else
				to_chat(user, span_notice("They have been given the option to consider becoming a Deacon. Wait for them to decide and try again."))
			return FALSE
	return ..()

/datum/religion_rites/deaconize/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	if(!(potential_deacon in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The new member is no longer on the altar!"))
		return FALSE
	if(potential_deacon.stat != CONSCIOUS)
		to_chat(user, span_warning("The new member has to stay alive for the rite to work!"))
		return FALSE
	if(!potential_deacon.mind)
		to_chat(user, span_warning("The new member has no mind!"))
		return FALSE
	if(IS_CULTIST(potential_deacon))//what the fuck?!
		to_chat(user, span_warning("[GLOB.deity] has seen a true, dark evil in [potential_deacon]'s heart, and they have been smitten!"))
		playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
		potential_deacon.gib(DROP_ORGANS|DROP_BODYPARTS)
		return FALSE
	var/datum/brain_trauma/special/honorbound/honor = user.has_trauma_type(/datum/brain_trauma/special/honorbound)
	if(honor && (potential_deacon in honor.guilty))
		honor.guilty -= potential_deacon
	if(crusader_code)
		GLOB.religious_sect.adjust_favor(DEACONIZE_FAVOR_GAIN, user)
	to_chat(user, span_notice("[GLOB.deity] has bound [potential_deacon] to the code! They are now a holy role! (albeit the lowest level of such)"))
	potential_deacon.mind.holy_role = HOLY_ROLE_DEACON
	GLOB.religious_sect.on_conversion(potential_deacon)
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE

/**
 * Async proc that waits for a response on joining the sect.
 * If they accept, the deaconize rite can now recruit them instead of just offering more invites.
 */
/datum/religion_rites/deaconize/proc/invite_deacon(mob/living/carbon/human/invited)
	var/ask = tgui_alert(invited, "Join [GLOB.deity]?[crusader_code ? " You will be bound to a code of honor." : " You will be expected to follow the Chaplain's order."]", "Invitation", list("Yes", "No"), 60 SECONDS)
	if(ask != "Yes")
		return
	potential_deacon = invited

///One time use subtype of deaconize.
/datum/religion_rites/deaconize/one_time_use
	name = "Deaconize"
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
	They will gain the same holy abilities as you, this is a one-time use so make sure they are worthy!"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"A good, honorable person has been brought here by faith ...",
		"With their hands ready to serve ...",
		"Heart ready to listen ...",
		"And soul ready to follow ...",
		"May we offer our own hand in return ..."
	)
	invoke_msg = "And use them to the best of our abilities."
	crusader_code = FALSE
	rite_flags = RITE_ALLOW_MULTIPLE_PERFORMS | RITE_ONE_TIME_USE

#undef DEACONIZE_FAVOR_GAIN
