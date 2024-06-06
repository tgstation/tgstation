/datum/bloodsucker_clan/tremere
	name = CLAN_TREMERE
	description = "The Tremere Clan is extremely weak to True Faith, and will burn when entering areas considered such, like the Chapel. \n\
		Additionally, a whole new moveset is learned, built on Blood magic rather than Blood abilities, which are upgraded overtime. \n\
		More ranks can be gained by Vassalizing crewmembers. \n\
		The Favorite Vassal gains the Batform spell, being able to morph themselves at will."
	clan_objective = /datum/objective/bloodsucker/tremere_power
	join_icon_state = "tremere"
	join_description = "You will burn if you enter the Chapel, lose all default powers, \
		but gain Blood Magic instead, powers you level up overtime."

/datum/bloodsucker_clan/tremere/New(mob/living/carbon/user)
	. = ..()
	bloodsuckerdatum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if((initial(power.purchase_flags) & TREMERE_CAN_BUY) && initial(power.level_current) == 1)
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/tremere/Destroy(force)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			bloodsuckerdatum.RemovePower(power)
	return ..()

/datum/bloodsucker_clan/tremere/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	var/area/current_area = get_area(bloodsuckerdatum.owner.current)
	if(istype(current_area, /area/station/service/chapel))
		to_chat(bloodsuckerdatum.owner.current, span_warning("You don't belong in holy areas! The Faith burns you!"))
		bloodsuckerdatum.owner.current.adjustFireLoss(10)
		bloodsuckerdatum.owner.current.adjust_fire_stacks(2)
		bloodsuckerdatum.owner.current.ignite_mob()

/datum/bloodsucker_clan/tremere/spend_rank(datum/antagonist/bloodsucker/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/bloodsucker/targeted/tremere/power as anything in bloodsuckerdatum.powers)
		if(!(power.purchase_flags & TREMERE_CAN_BUY))
			continue
		if(isnull(power.upgraded_power))
			continue
		options[initial(power.name)] = power

	if(length(options) < 1)
		to_chat(bloodsuckerdatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(bloodsuckerdatum.owner.current, "You have the opportunity to grow more ancient. Select a power you wish to upgrade.", "Your Blood Thickens...", options)
		// Prevent Bloodsuckers from closing/reopning their coffin to spam Levels.
		if(cost_rank && bloodsuckerdatum.bloodsucker_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(bloodsuckerdatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Bloodsuckers from purchasing a power while outside of their Coffin.
		if(!istype(bloodsuckerdatum.owner.current.loc, /obj/structure/closet/crate/coffin))
			to_chat(bloodsuckerdatum.owner.current, span_warning("You must be in your Coffin to purchase Powers."))
			return

		// Good to go - Buy Power!
		var/datum/action/cooldown/bloodsucker/purchased_power = options[choice]
		var/datum/action/cooldown/bloodsucker/targeted/tremere/tremere_power = purchased_power
		if(isnull(tremere_power.upgraded_power))
			bloodsuckerdatum.owner.current.balloon_alert(bloodsuckerdatum.owner.current, "cannot upgrade [choice]!")
			to_chat(bloodsuckerdatum.owner.current, span_notice("[choice] is already at max level!"))
			return
		bloodsuckerdatum.BuyPower(new tremere_power.upgraded_power)
		bloodsuckerdatum.RemovePower(tremere_power)
		bloodsuckerdatum.owner.current.balloon_alert(bloodsuckerdatum.owner.current, "upgraded [choice]!")
		to_chat(bloodsuckerdatum.owner.current, span_notice("You have upgraded [choice]!"))

	finalize_spend_rank(bloodsuckerdatum, cost_rank, blood_cost)

/datum/bloodsucker_clan/tremere/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	var/datum/action/cooldown/spell/shapeshift/bat/batform = new(vassaldatum.owner || vassaldatum.owner.current)
	batform.Grant(vassaldatum.owner.current)

/datum/bloodsucker_clan/tremere/on_vassal_made(datum/antagonist/bloodsucker/source, mob/living/user, mob/living/target)
	. = ..()
	to_chat(bloodsuckerdatum.owner.current, span_danger("You have now gained an additional Rank to spend!"))
	bloodsuckerdatum.bloodsucker_level_unspent++
