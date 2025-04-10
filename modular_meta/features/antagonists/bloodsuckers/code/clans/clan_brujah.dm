/datum/bloodsucker_clan/brujah
	name = CLAN_BRUJAH
	description = "The Brujah seek societal advancement through direct (and usually violent) means.\n\
		With age they develop a powerful physique and become capable of obliterating almost anything with their bare hands.\n\
		Be wary, as they are ferverous insurgents, rebels, and anarchists who always attempt to undermine local authorities. \n\
		Their favorite vassal gains the regular Brawn ability and substantially strengthened fists."
	clan_objective = /datum/objective/brujah_clan_objective
	join_icon_state = "brujah"
	join_description = "Gain an enhanced version of the brawn ability that lets you destroy most structures (including walls!) \
		Rebel against all authority and attempt to subvert it, but in turn <b>break the Masquerade immediately on joining</b>  \
		and lose nearly all of your Humanity."
	blood_drink_type = BLOODSUCKER_DRINK_INHUMANELY


/datum/bloodsucker_clan/brujah/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	owner_datum.special_vassals -= DISCORDANT_VASSAL //Removes Discordant Vassal, which is in the list by default.
	owner_datum.break_masquerade()
	owner_datum.AddHumanityLost(37.5) // Frenzy at 400
	bloodsuckerdatum.remove_nondefault_powers(return_levels = TRUE)
	// Copied over from 'clan_tremere.dm' with appropriate adjustment.
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if((initial(power.purchase_flags) & BRUJAH_DEFAULT_POWER))
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/brujah/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank, blood_cost)
	// Give them a quick warning about losing humanity on ranking up before actually ranking them up...
	var/mob/living/carbon/human/our_antag = source.owner.current
	var/warning_accepted = tgui_alert(our_antag, \
		"Since you are part of the Brujah clan, increasing your rank will also decrease your humanity. \n\
		This will increase your current Frenzy threshold from [source.frenzy_threshold] to \
		[source.frenzy_threshold + 50]. Please ensure that you have enough blood available or risk entering Frenzy.", \
		"BE ADVISED", \
		list("Accept Warning", "Abort Ranking Up"))
	if(warning_accepted != "Accept Warning")
		return FALSE
	return ..()

/datum/bloodsucker_clan/brujah/finalize_spend_rank(datum/antagonist/bloodsucker/source, cost_rank, blood_cost)
	. = ..()
	source.AddHumanityLost(5) //Increases frenzy threshold by fifty

/// Raise the damage of both of their hands by four. Copied from 'finalize_spend_rank()' in '_clan.dm'
/datum/bloodsucker_clan/brujah/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	. = ..()
	var/mob/living/carbon/our_vassal = vassaldatum.owner.current
	var/obj/item/bodypart/vassal_left_hand = our_vassal.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/vassal_right_hand = our_vassal.get_bodypart(BODY_ZONE_R_ARM)
	vassal_left_hand.unarmed_damage_low += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_right_hand.unarmed_damage_low += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_left_hand.unarmed_damage_high += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS
	vassal_right_hand.unarmed_damage_high += BRUJAH_FAVORITE_VASSAL_ATTACK_BONUS

/**
 * Clan Objective
 * Brujah's Clan objective is to brainwash the highest ranking person on the station (if any.)
 * Made by referencing 'objective.dm'
 */
/datum/objective/brujah_clan_objective
	name = "brujahrevolution"
	martyr_compatible = TRUE

	/// Set to true when the target is turned into a Discordant Vassal.
	var/target_subverted = FALSE
	/// I have no idea what this actually does. It's on a lot of other assassination/similar objectives though...
	var/target_role_type = FALSE

/datum/objective/brujah_clan_objective/New(text)
	. = ..()
	get_target()
	update_explanation_text()

/datum/objective/brujah_clan_objective/check_completion()
	if(target_subverted)
		return TRUE
	return FALSE

/datum/objective/brujah_clan_objective/update_explanation_text()
	if(target?.current)
		explanation_text = "Subvert the authority of [target.name] the [!target_role_type ? target.assigned_role.title : target.special_role] \
			by turning [target.p_them()] into a Discordant Vassal with a persuassion rack."
	else
		explanation_text = "Free objective."

/// Made after referencing '/datum/team/revolution/roundend_report()' in 'revolution.dm'
/datum/objective/brujah_clan_objective/get_target()
	var/list/target_options = SSjob.get_living_heads() //Look for heads...
	if(!target_options.len)
		target_options = SSjob.get_living_sec() //If no heads then look for security...
		if(!target_options.len)
			target_options = get_crewmember_minds() //If no security then look for ANY CREW MEMBER.

	if(target_options.len)
		target_options.Remove(owner)
	else
		update_explanation_text()
		return

	for(var/datum/mind/possible_target in target_options)
		if(!is_valid_target(possible_target))
			target_options.Remove(possible_target)

	target = pick(target_options)
	update_explanation_text()
