


/datum/action/bloodsucker
	name = "Vampiric Gift"//"Cellular Emporium"
	desc = "A vampiric gift."
	button_icon = 'icons/Fulpicons/fulpicons.dmi'	//This is the file for the BACKGROUND icon
	background_icon_state = "vamp_power_off"		//And this is the state for the background icon
	var/background_icon_state_on = "vamp_power_on"		// FULP: Our "ON" icon alternative.
	var/background_icon_state_off = "vamp_power_off"	// FULP: Our "OFF" icon alternative.
	icon_icon = 'icons/Fulpicons/fulpicons.dmi'		//This is the file for the ACTION icon
	button_icon_state = "power_feed" 				//And this is the state for the action icon
	//background_icon_state = "bg_changeling"
	//icon_icon = 'icons/mob/actions/actions_changeling.dmi'

	// Action-Related
	var/active = FALSE
	var/amToggle = FALSE
	var/cooldown = 20 // 10 ticks, 1 second.
	var/cooldownUntil = 0 //  From action.dm:  	next_use_time = world.time + cooldown_time

	//icon_icon = 'icons/obj/drinks.dmi'
	//button_icon_state = "changelingsting"
	//background_icon_state = "bg_changeling"

	// Power-Related
	var/powerlevel = 1		// Can increase to yield new abilities
	var/bloodcost = 10
	var/needs_button = TRUE // Taken from Changeling - for passive abilities that dont need a button
	var/need_bloodsucker = TRUE // Must be a bloodsucker to use this power.


///datum/action/bloodsucker/proc/GivePower(mob/user)
//	Grant(user) // (from Changeling) how powers are added rather than the checks in mob.dm

///datum/action/bloodsucker/proc/RemovePower(mob/user)
//
//	Remove(user)




//							NOTES
//
// 	click.dm <--- Where we can take over mouse clicks to have
//	spells.dm  /add_ranged_ability()  <--- How we take over the mouse click to use a power on a target.


/datum/action/bloodsucker/Trigger()

	// Active? DEACTIVATE AND END!
	if (active && CheckCanDeactivate(TRUE))
		DeactivatePower(owner)
		return

	if(!owner || !owner.mind || need_bloodsucker && !owner.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		return

	if (!CheckCanUse(TRUE))
		return

	PayCost()

	if (amToggle)
		active = !active
		background_icon_state = active? background_icon_state_on : background_icon_state_off
		UpdateButtonIcon()

	if (!amToggle || !active)
		StartCooldown()

	ActivatePower()


/datum/action/bloodsucker/check


/datum/action/bloodsucker/proc/CheckCanUse(display_error)
	// owner for actions is the mob, not mind.
	var/mob/living/L = owner

	// Cooldown?
	if (cooldownUntil > world.time)
		if (display_error)
			to_chat(L, "[src] is unavailable. Wait [(cooldownUntil - world.time) / 10] seconds.")
		return FALSE
	// Have enough blood?
	if (L.blood_volume < bloodcost)
		if (display_error)
			to_chat(L, "You need at least [bloodcost] blood to activate [name]!</span>")
		return FALSE

	return TRUE

/datum/action/bloodsucker/proc/StartCooldown()
	set waitfor = FALSE
	// Alpha Out
	button.color = rgb(128,0,0,128)
	button.alpha = 100
	// Wait for cooldown
	cooldownUntil = world.time + cooldown
	spawn(cooldown)
		// Alpha In
		button.color = rgb(255,255,255,255)
		button.alpha = 255



/datum/action/bloodsucker/proc/CheckCanDeactivate(display_error)
	return TRUE



/datum/action/bloodsucker/proc/PayCost()
	// owner for actions is the mob, not mind.
	var/mob/living/L = owner
	L.blood_volume -= bloodcost


/datum/action/bloodsucker/proc/ActivatePower()



/datum/action/bloodsucker/proc/DeactivatePower(mob/living/user = owner, mob/living/target)
	active = FALSE
	background_icon_state = background_icon_state_off
	UpdateButtonIcon()
	StartCooldown()

/datum/action/bloodsucker/proc/ContinueActive(mob/living/user, mob/living/target) // Used by loops to make sure this power can stay active.
	return active && user.mind && user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
