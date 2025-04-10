///The maximum level a Ventrue Bloodsucker can be, before they have to level up their vassal instead.
#define VENTRUE_MAX_LEVEL 3
///How much it costs for a Ventrue to rank up without a spare rank to spend.
#define BLOODSUCKER_BLOOD_RANKUP_COST (550)

/datum/bloodsucker_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue are extremely snobby with their meals, and refuse to drink blood from people without a mind. \n\
		They may only gain three abilities, with the rest of their progress being given to (and to some extent shared with,) their favorite vassal. \n\
		Their favorite vassal will slowly turn more vampiric this way, until they finally lose the last bits of their humanity and become a Fledgling."
	clan_objective = /datum/objective/ventrue_clan_objective
	join_icon_state = "ventrue"
	join_description = "Lose the ability to drink from the mindless; become unable to gain more than three powers, \
		instead raise a vassal into a Bloodsucker."
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY

/datum/bloodsucker_clan/ventrue/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	if(!target)
		if(bloodsuckerdatum.bloodsucker_level < VENTRUE_MAX_LEVEL)
			return ..()
		return FALSE
	var/datum/antagonist/vassal/favorite/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal/favorite)
	var/datum/antagonist/bloodsucker/vassal_bloodsuker_datum = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!vassaldatum)
		return FALSE
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if(!(initial(power.purchase_flags) & VASSAL_CAN_BUY))
			continue
		if(locate(power) in vassaldatum.powers)
			continue
		if(vassal_bloodsuker_datum && (locate(power) in vassal_bloodsuker_datum.powers))
			continue
		options[initial(power.name)] = power

	if(options.len < 1)
		to_chat(bloodsuckerdatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(bloodsuckerdatum.owner.current, "You have the opportunity to level up your Favorite Vassal. Select a power you wish them to receive.", "Your Blood Thickens...", options)
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if(cost_rank && bloodsuckerdatum.bloodsucker_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if((locate(options[choice]) in vassaldatum.powers))
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return

		// Good to go - Buy Power!
		var/datum/action/cooldown/bloodsucker/purchased_power = options[choice]
		vassaldatum.BuyPower(new purchased_power)
		bloodsuckerdatum.owner.current.balloon_alert(bloodsuckerdatum.owner.current, "taught [choice]!")
		to_chat(bloodsuckerdatum.owner.current, span_notice("You taught [target] how to use [choice]!"))
		target.balloon_alert(target, "learned [choice]!")
		to_chat(target, span_notice("Your master taught you how to use [choice]!"))

	vassaldatum.vassal_level++
	switch(vassaldatum.vassal_level)
		if(2)
			target.add_traits(list(TRAIT_COLDBLOODED, TRAIT_NOBREATH, TRAIT_AGEUSIA), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("Your blood begins to feel cold, and as a mote of ash lands upon your tongue, you stop breathing..."))
		if(3)
			target.add_traits(list(TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("You feel your master's blood improve your endurance, you will not fall that easily."))
		if(4)
			target.add_traits(list(TRAIT_SLEEPIMMUNE, TRAIT_VIRUSIMMUNE), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("You feel your master's blood begin to invigorate your thymus."))
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				human_target.skin_tone = "albino"
		if(5)
			target.add_traits(list(TRAIT_NOHARDCRIT, TRAIT_HARDLY_WOUNDED), BLOODSUCKER_TRAIT)
			to_chat(target, span_notice("Your blood stills, you feel like you'd be able to withstand cuts and stabbings."))
		if(6 to INFINITY)
			if(!vassal_bloodsuker_datum)
				if(vassaldatum.info_button_ref)
					QDEL_NULL(vassaldatum.info_button_ref)
				vassal_bloodsuker_datum = target.mind.add_antag_datum(/datum/antagonist/bloodsucker)
				vassal_bloodsuker_datum.my_clan = new /datum/bloodsucker_clan/vassal(src)

				to_chat(target, span_cult("You feel your heart pump for the last time as you begin to thirst for blood, you feel... <b>dead</b>."))
				bloodsuckerdatum.owner.current.add_mood_event("madevamp", /datum/mood_event/madevamp)

			vassaldatum.set_vassal_level(vassal_bloodsuker_datum)

	finalize_spend_rank(bloodsuckerdatum, cost_rank, blood_cost)
	vassaldatum.LevelUpPowers()

/datum/bloodsucker_clan/ventrue/interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	. = ..()
	if(.)
		return TRUE
	if(!istype(vassaldatum))
		return FALSE
	if(!bloodsuckerdatum.bloodsucker_level_unspent <= 0)
		bloodsuckerdatum.SpendRank(vassaldatum.owner.current)
		return TRUE
	if(bloodsuckerdatum.bloodsucker_blood_volume >= BLOODSUCKER_BLOOD_RANKUP_COST)
		// We don't have any ranks to spare? Let them upgrade... with enough Blood.
		to_chat(bloodsuckerdatum.owner.current, span_warning("Do you wish to spend [BLOODSUCKER_BLOOD_RANKUP_COST] blood to rank [vassaldatum.owner.current] up?"))
		var/static/list/rank_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/rank_response = show_radial_menu(bloodsuckerdatum.owner.current, vassaldatum.owner.current, rank_options, radius = 36, require_near = TRUE)
		if(rank_response == "Yes")
			bloodsuckerdatum.SpendRank(vassaldatum.owner.current, cost_rank = FALSE, blood_cost = BLOODSUCKER_BLOOD_RANKUP_COST)
		return TRUE
	to_chat(bloodsuckerdatum.owner.current, span_danger("You don't have any levels or enough blood to rank [vassaldatum.owner.current] up with."))
	return TRUE

/datum/bloodsucker_clan/ventrue/on_favorite_vassal(datum/source, datum/antagonist/vassal/favorite/vassaldatum)
	to_chat(source, span_announce("* Bloodsucker Tip: You can now upgrade your favorite vassal with a persuassion rack!"))
	vassaldatum.BuyPower(new /datum/action/cooldown/bloodsucker/distress)

#undef BLOODSUCKER_BLOOD_RANKUP_COST
#undef VENTRUE_MAX_LEVEL

/**
 * Clan Objective
 * Ventrue's Clan objective is to upgrade the Favorite Vassal
 * enough to make them a Bloodsucker.
 */
/datum/objective/ventrue_clan_objective
	name = "embrace"
	explanation_text = "Use a persuasion rack to rank your favorite vassal up enough to become a Bloodsucker and keep them alive until the end."
	martyr_compatible = TRUE

/datum/objective/ventrue_clan_objective/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.current.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsuckerdatum)
		return FALSE
	for(var/datum/antagonist/vassal/vassaldatum as anything in bloodsuckerdatum.vassals)
		if(!vassaldatum.owner || !vassaldatum.owner.current)
			continue
		if(IS_FAVORITE_VASSAL(vassaldatum.owner.current) && vassaldatum.owner.has_antag_datum(/datum/antagonist/bloodsucker))
			return TRUE
	return FALSE
