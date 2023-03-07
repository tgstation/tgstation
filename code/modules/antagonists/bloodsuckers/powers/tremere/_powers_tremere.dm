/**
 *	# Tremere Powers
 *
 *	This file is for Tremere power procs and Bloodsucker procs that deals exclusively with Tremere.
 *	Tremere has quite a bit of unique things to it, so I thought it's own subtype would be nice
 */

/datum/action/bloodsucker/targeted/tremere
	name = "Tremere Gift"
	desc = "A Tremere exclusive gift."
	button_icon_state = "power_auspex"
	background_icon_state = "tremere_power_off"
	background_icon_state_on = "tremere_power_on"
	background_icon_state_off = "tremere_power_off"
	button_icon = 'icons/mob/actions/actions_tremere_bloodsucker.dmi'
	background_icon = 'icons/mob/actions/actions_tremere_bloodsucker.dmi'

	// Tremere powers don't level up, we have them hardcoded.
	level_current = 0
	// Re-defining these as we want total control over them
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	purchase_flags = TREMERE_CAN_BUY
	// Targeted stuff
	power_activates_immediately = FALSE

	///The upgraded version of this Power. 'null' means it's the max level.
	var/upgraded_power = null
	var/tremere_level = 0

/datum/antagonist/bloodsucker/proc/LevelUpTremerePower(mob/living/user)

	var/list/options = list()
	for(var/datum/action/bloodsucker/targeted/tremere/power in powers)
		if(!(locate(power) in powers))
			continue
		var/datum/action/bloodsucker/targeted/tremere/current_power = (locate(power) in powers)
		if(initial(power.tremere_level) >= current_power.tremere_level)
			options[initial(power.name)] = power

	if(options.len >= 1)
		var/choice = tgui_input_list(user, "You have the opportunity to grow more ancient. Select a power you wish to Upgrade.", "Your Blood Thickens...", options)
		/// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(user, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return FALSE
		if(bloodsucker_level_unspent <= 0)
			return FALSE

		var/datum/action/bloodsucker/targeted/tremere/P = options[choice]
		if(P.upgraded_power)
			BuyPower(new P.upgraded_power)
			if(P.active)
				P.DeactivatePower()
			powers -= P
			P.Remove(user)
			user.balloon_alert(user, "upgraded [P]!")
			to_chat(user, span_notice("You have upgraded [P]!"))
			return TRUE
		else
			user.balloon_alert(user, "cannot upgrade [P]!")
			to_chat(user, span_notice("[P] is already at max level!"))
	return FALSE
